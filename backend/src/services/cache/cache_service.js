/**
 * Cache Service — Multi-level caching for Agent Adam
 *
 * Architecture:
 *  - L1: In-memory LRU cache (fastest, ~1ms)
 *  - L2: Redis cache (shared, ~5ms)
 *  - L3: PostgreSQL materialized cache (persistent, ~20ms)
 *
 * Cache strategies:
 *  - Cache-Aside: Check cache → miss → fetch from DB → populate cache
 *  - Write-Through: Write to DB → update cache synchronously
 *  - TTL-based expiration with staggered refresh
 */

const IORedis = require('ioredis');

// ─── L1: In-memory LRU cache ───────────────────────────────────────────
class LRUCache {
  constructor(maxSize = 1000) {
    this.maxSize = maxSize;
    this.cache = new Map();
    this.hits = 0;
    this.misses = 0;
  }

  get(key) {
    if (!this.cache.has(key)) {
      this.misses++;
      return undefined;
    }
    // Move to end (most recently used)
    const value = this.cache.get(key);
    this.cache.delete(key);
    this.cache.set(key, value);
    this.hits++;
    return value;
  }

  set(key, value) {
    if (this.cache.has(key)) {
      this.cache.delete(key);
    } else if (this.cache.size >= this.maxSize) {
      // Evict oldest (least recently used)
      const firstKey = this.cache.keys().next().value;
      this.cache.delete(firstKey);
    }
    this.cache.set(key, value);
  }

  delete(key) {
    this.cache.delete(key);
  }

  clear() {
    this.cache.clear();
  }

  get stats() {
    const total = this.hits + this.misses;
    return {
      size: this.cache.size,
      maxSize: this.maxSize,
      hits: this.hits,
      misses: this.misses,
      hitRate: total > 0 ? ((this.hits / total) * 100).toFixed(1) + '%' : '0%',
    };
  }
}

// ─── Redis client ──────────────────────────────────────────────────────
const redis = new IORedis({
  host: process.env.REDIS_HOST || 'localhost',
  port: parseInt(process.env.REDIS_PORT || '6379', 10),
  password: process.env.REDIS_PASSWORD || undefined,
  maxRetriesPerRequest: 3,
  retryStrategy: (times) => Math.min(times * 100, 3000),
  lazyConnect: true,
});

// ─── Cache service ─────────────────────────────────────────────────────
class CacheService {
  constructor() {
    this.l1 = new LRUCache(2000);
    this.defaultTTL = parseInt(process.env.CACHE_TTL || '300', 10); // 5 min default
    this.connected = false;
  }

  async connect() {
    if (!this.connected) {
      await redis.connect();
      this.connected = true;
      console.log('[CacheService] Redis connected');
    }
  }

  async disconnect() {
    if (this.connected) {
      await redis.quit();
      this.connected = false;
    }
  }

  // ─── Multi-level get ───────────────────────────────────────────────
  async get(key, options = {}) {
    const { ttl = this.defaultTTL, fetcher } = options;

    // L1 check
    const l1Value = this.l1.get(key);
    if (l1Value !== undefined) {
      if (l1Value.expiresAt && l1Value.expiresAt < Date.now()) {
        this.l1.delete(key);
      } else {
        return l1Value.data;
      }
    }

    // L2 check (Redis)
    try {
      const redisValue = await redis.get(`cache:${key}`);
      if (redisValue) {
        const parsed = JSON.parse(redisValue);
        // Populate L1
        this.l1.set(key, {
          data: parsed,
          expiresAt: Date.now() + (ttl * 1000),
        });
        return parsed;
      }
    } catch (err) {
      console.warn('[CacheService] Redis get failed:', err.message);
    }

    // L3: Fetch from source
    if (fetcher) {
      try {
        const data = await fetcher();
        // Populate both caches
        await this.set(key, data, { ttl });
        return data;
      } catch (err) {
        console.error('[CacheService] Fetcher failed:', err.message);
        throw err;
      }
    }

    return null;
  }

  // ─── Multi-level set ───────────────────────────────────────────────
  async set(key, value, options = {}) {
    const { ttl = this.defaultTTL } = options;

    // L1
    this.l1.set(key, {
      data: value,
      expiresAt: Date.now() + (ttl * 1000),
    });

    // L2 (Redis)
    try {
      await redis.set(
        `cache:${key}`,
        JSON.stringify(value),
        'EX',
        ttl
      );
    } catch (err) {
      console.warn('[CacheService] Redis set failed:', err.message);
    }

    return true;
  }

  // ─── Delete ──────────────────────────────────────────────────────────
  async delete(key) {
    this.l1.delete(key);
    try {
      await redis.del(`cache:${key}`);
    } catch (err) {
      console.warn('[CacheService] Redis del failed:', err.message);
    }
  }

  // ─── Invalidate by pattern ──────────────────────────────────────────
  async invalidatePattern(pattern) {
    // L1: scan and delete
    const l1Keys = [];
    const regex = new RegExp(pattern.replace(/\*/g, '.*'));
    for (const key of this.l1.cache.keys()) {
      if (regex.test(key)) l1Keys.push(key);
    }
    for (const key of l1Keys) {
      this.l1.delete(key);
    }

    // L2: SCAN and delete
    try {
      let cursor = '0';
      do {
        const result = await redis.scan(
          cursor,
          'MATCH',
          `cache:${pattern}`,
          'COUNT',
          100
        );
        cursor = result[0];
        const keys = result[1];
        if (keys.length > 0) {
          await redis.del(keys);
        }
      } while (cursor !== '0');
    } catch (err) {
      console.warn('[CacheService] Pattern invalidation failed:', err.message);
    }

    console.log(`[CacheService] Pattern invalidated: ${pattern} (L1: ${l1Keys.length} keys)`);
  }

  // ─── Warm-up cache ──────────────────────────────────────────────────
  async warmUp(warmUpTasks) {
    console.log(`[CacheService] Warming up ${warmUpTasks.length} cache entries...`);
    const results = [];

    for (const task of warmUpTasks) {
      try {
        const data = await task.fetcher();
        await this.set(task.key, data, { ttl: task.ttl || 3600 });
        results.push({ key: task.key, status: 'OK' });
      } catch (err) {
        results.push({ key: task.key, status: 'FAILED', error: err.message });
      }
    }

    console.log(`[CacheService] Warm-up complete: ${results.filter((r) => r.status === 'OK').length}/${results.length} OK`);
    return results;
  }

  // ─── Pre-computed cache keys ────────────────────────────────────────
  static keys = {
    seniorProfile: (id) => `senior:profile:${id}`,
    seniorHealthHistory: (id) => `senior:health:${id}:30d`,
    seniorMedications: (id) => `senior:medications:${id}`,
    seniorConversations: (id, days = 7) => `senior:conversations:${id}:${days}d`,
    familyDashboard: (familyId) => `family:dashboard:${familyId}`,
    adminStats: () => 'admin:stats:dashboard',
    adminSeniors: (page) => `admin:seniors:page:${page}`,
    marketplaceProducts: (category) => `marketplace:products:${category || 'all'}`,
    blogPosts: (page) => `blog:posts:page:${page}`,
    ragContext: (seniorId) => `rag:context:${seniorId}`,
    voicePrompt: (seniorId) => `voice:prompt:${seniorId}`,
  };

  // ─── Stats ──────────────────────────────────────────────────────────
  getStats() {
    return {
      l1: this.l1.stats,
      l2: { connected: this.connected },
      config: { defaultTTL: this.defaultTTL },
    };
  }
}

// Singleton
const cacheService = new CacheService();

module.exports = { cacheService, CacheService, LRUCache };
