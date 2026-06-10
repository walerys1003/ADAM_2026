/**
 * SilverTech Agent Adam — Fastify Backend Server
 * June 2026 optimized
 * Architecture: Fastify + Prisma + pgvector + Redis + BullMQ
 * 
 * 7-layer voice pipeline:
 *   Twilio → Deepgram Nova-3 → System Prompt + pgvector RAG
 *   → Gemini 3.2 Flash Live → Guardrails → OpenAI TTS-1 → Hetzner VPS
 */

const fastify = require('fastify')({
  logger: {
    level: process.env.LOG_LEVEL || 'info',
    transport: process.env.NODE_ENV === 'development'
      ? { target: 'pino-pretty', options: { colorize: true } }
      : undefined,
  },
  bodyLimit: 10 * 1024 * 1024, // 10MB
  requestTimeout: 30000,
});

const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// ── Plugins ────────────────────────────────────────────
fastify.register(require('@fastify/cors'), {
  origin: process.env.CORS_ORIGINS?.split(',') || ['http://localhost:5060', 'https://*.silvertech.ai'],
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  credentials: true,
});

fastify.register(require('@fastify/rate-limit'), {
  max: parseInt(process.env.RATE_LIMIT_MAX || '100'),
  timeWindow: '1 minute',
});

fastify.register(require('@fastify/helmet'), {
  contentSecurityPolicy: false,
});

fastify.register(require('@fastify/compress'), {
  global: true,
  threshold: 1024,
});

// ── JWT Authentication Plugin ──────────────────────────
fastify.register(require('@fastify/jwt'), {
  secret: process.env.JWT_SECRET || 'silvertech-adam-jwt-secret-2026',
  sign: { expiresIn: '24h' },
});

fastify.decorate('authenticate', async (request, reply) => {
  try {
    await request.jwtVerify();
  } catch (err) {
    reply.code(401).send({ error: 'Unauthorized', message: 'Invalid or expired token' });
  }
});

// ── Health Check ───────────────────────────────────────
fastify.get('/api/health', async () => ({
  status: 'ok',
  service: 'agent-adam-backend',
  version: '1.6.0',
  timestamp: new Date().toISOString(),
  uptime: process.uptime(),
  memory: process.memoryUsage().heapUsed / 1024 / 1024,
}));

// ── Route Registration ─────────────────────────────────
fastify.register(require('./routes/auth'), { prefix: '/api/auth' });
fastify.register(require('./routes/seniors'), { prefix: '/api/seniors' });
fastify.register(require('./routes/voice'), { prefix: '/api/voice' });
fastify.register(require('./routes/health'), { prefix: '/api/health' });
fastify.register(require('./routes/medications'), { prefix: '/api/medications' });
fastify.register(require('./routes/conversations'), { prefix: '/api/conversations' });
fastify.register(require('./routes/family'), { prefix: '/api/family' });
fastify.register(require('./routes/admin'), { prefix: '/api/admin' });
fastify.register(require('./routes/marketplace'), { prefix: '/api/marketplace' });
fastify.register(require('./routes/analytics'), { prefix: '/api/analytics' });
fastify.register(require('./routes/webhooks'), { prefix: '/api/webhooks' });

// ── WebSocket Setup ────────────────────────────────────
fastify.register(require('./websocket/voiceSocket'), { prefix: '/ws/voice' });

// ── Graceful Shutdown ──────────────────────────────────
const shutdown = async (signal) => {
  fastify.log.info(`Received ${signal}, shutting down gracefully...`);
  await fastify.close();
  await prisma.$disconnect();
  process.exit(0);
};

process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));

// ── Start Server ───────────────────────────────────────
const start = async () => {
  try {
    const port = parseInt(process.env.PORT || '3000');
    const host = process.env.HOST || '0.0.0.0';

    await fastify.listen({ port, host });
    fastify.log.info(`Agent Adam backend running on ${host}:${port}`);

    // Log available routes in development
    if (process.env.NODE_ENV === 'development') {
      fastify.log.info('Registered routes:');
      fastify.printRoutes();
    }
  } catch (err) {
    fastify.log.error(err);
    process.exit(1);
  }
};

start();

module.exports = fastify;
