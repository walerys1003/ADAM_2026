/**
 * Rate Limiter Middleware — Token Bucket + IP-based throttling
 * SilverTech Agent Adam | June 2026
 */

const RATE_LIMITS = {
  global: { windowMs: 60_000, max: 100 },       // 100 req/min global
  voice: { windowMs: 60_000, max: 10 },          // 10 voice calls/min
  auth: { windowMs: 300_000, max: 5 },            // 5 login attempts/5min
  admin: { windowMs: 60_000, max: 30 },           // 30 admin req/min
  health: { windowMs: 10_000, max: 50 },          // 50 health pings/10s
};

const buckets = new Map();

function getBucketKey(req, tier) {
  const ip = req.headers['x-forwarded-for'] || req.ip || 'unknown';
  return `${tier}:${ip}`;
}

function rateLimiter(tier = 'global') {
  const limit = RATE_LIMITS[tier] || RATE_LIMITS.global;

  return async (request, reply) => {
    const key = getBucketKey(request, tier);
    const now = Date.now();

    if (!buckets.has(key)) {
      buckets.set(key, { tokens: limit.max, lastRefill: now });
    }

    const bucket = buckets.get(key);
    const elapsed = now - bucket.lastRefill;
    const refillRate = limit.max / limit.windowMs;
    bucket.tokens = Math.min(limit.max, bucket.tokens + elapsed * refillRate);
    bucket.lastRefill = now;

    if (bucket.tokens < 1) {
      reply.code(429).send({
        error: 'Too Many Requests',
        retryAfter: Math.ceil((1 - bucket.tokens) / refillRate),
        tier,
      });
      return;
    }

    bucket.tokens -= 1;
  };
}

// Cleanup stale buckets every 5 min
setInterval(() => {
  const now = Date.now();
  for (const [key, bucket] of buckets) {
    if (now - bucket.lastRefill > 300_000) buckets.delete(key);
  }
}, 300_000);

module.exports = { rateLimiter, RATE_LIMITS };
