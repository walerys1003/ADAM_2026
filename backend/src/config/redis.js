// ─────────────────────────────────────────────────────────────────
// Agent Adam — Redis Configuration
// SilverTech | June 2026
// ─────────────────────────────────────────────────────────────────
const IORedis = require('ioredis');

const REDIS_CONFIG = {
  host: process.env.REDIS_HOST || 'localhost',
  port: parseInt(process.env.REDIS_PORT || '6379', 10),
  password: process.env.REDIS_PASSWORD || undefined,
  db: parseInt(process.env.REDIS_DB || '0', 10),
  maxRetriesPerRequest: null, // Required for BullMQ
  enableReadyCheck: false,    // Faster startup with BullMQ
  retryStrategy: (times) => {
    if (times > 10) {
      console.error('[Redis] Max retries exceeded');
      return null;
    }
    return Math.min(times * 200, 3000);
  },
  lazyConnect: false,
};

const redisConnection = new IORedis(REDIS_CONFIG);

redisConnection.on('connect', () => {
  console.log('[Redis] Connected');
});

redisConnection.on('error', (err) => {
  console.error('[Redis] Connection error:', err.message);
});

redisConnection.on('close', () => {
  console.warn('[Redis] Connection closed');
});

// Health check
async function redisHealthCheck() {
  try {
    await redisConnection.ping();
    return { status: 'ok', latency: 'connected' };
  } catch (err) {
    return { status: 'error', message: err.message };
  }
}

module.exports = { redisConnection, REDIS_CONFIG, redisHealthCheck };
