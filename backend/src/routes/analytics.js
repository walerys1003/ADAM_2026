'use strict';

const { authenticate, requireRole } = require('../middleware/auth');
const UsageAnalyticsService = require('../services/analytics/usage_analytics_service');

/**
 * Analytics API routes for the admin panel.
 * All routes require ADMIN role.
 */

async function analyticsRoutes(fastify, options) {
  const { prisma, redis } = fastify;
  const analyticsService = new UsageAnalyticsService(prisma, redis);

  // All analytics routes require authentication + admin role
  fastify.addHook('preHandler', authenticate);
  fastify.addHook('preHandler', requireRole('ADMIN'));

  // ============================================================================
  // GET /api/admin/analytics/overview
  // Dashboard overview with all key metrics
  // ============================================================================
  fastify.get('/api/admin/analytics/overview', {
    schema: {
      description: 'Get dashboard overview with all key metrics',
      tags: ['admin', 'analytics'],
      response: {
        200: {
          type: 'object',
          properties: {
            timestamp: { type: 'string' },
            seniors: { type: 'object' },
            conversations: { type: 'object' },
            costs: { type: 'object' },
            semafor: { type: 'object' },
            packages: { type: 'object' },
          },
        },
      },
    },
  }, async (request, reply) => {
    try {
      const overview = await analyticsService.getDashboardOverview();
      return reply.send(overview);
    } catch (err) {
      request.log.error(err, 'Failed to get analytics overview');
      return reply.status(500).send({
        error: 'ANALYTICS_ERROR',
        message: 'Nie udało się pobrać danych analitycznych.',
      });
    }
  });

  // ============================================================================
  // GET /api/admin/analytics/voice
  // Voice call analytics with optional date range and senior filter
  // ============================================================================
  fastify.get('/api/admin/analytics/voice', {
    schema: {
      description: 'Get voice call analytics',
      tags: ['admin', 'analytics'],
      querystring: {
        type: 'object',
        properties: {
          startDate: { type: 'string', format: 'date-time' },
          endDate: { type: 'string', format: 'date-time' },
          seniorId: { type: 'string', format: 'uuid' },
        },
      },
    },
  }, async (request, reply) => {
    try {
      const { startDate, endDate, seniorId } = request.query;
      const analytics = await analyticsService.getVoiceAnalytics({
        startDate,
        endDate,
        seniorId,
      });
      return reply.send(analytics);
    } catch (err) {
      request.log.error(err, 'Failed to get voice analytics');
      return reply.status(500).send({
        error: 'ANALYTICS_ERROR',
        message: 'Nie udało się pobrać analityki rozmów.',
      });
    }
  });

  // ============================================================================
  // GET /api/admin/analytics/health
  // Health data analytics summary
  // ============================================================================
  fastify.get('/api/admin/analytics/health', {
    schema: {
      description: 'Get health data analytics summary',
      tags: ['admin', 'analytics'],
      querystring: {
        type: 'object',
        properties: {
          startDate: { type: 'string', format: 'date-time' },
          endDate: { type: 'string', format: 'date-time' },
        },
      },
    },
  }, async (request, reply) => {
    try {
      const { startDate, endDate } = request.query;
      const analytics = await analyticsService.getHealthAnalytics({
        startDate,
        endDate,
      });
      return reply.send(analytics);
    } catch (err) {
      request.log.error(err, 'Failed to get health analytics');
      return reply.status(500).send({
        error: 'ANALYTICS_ERROR',
        message: 'Nie udało się pobrać analityki zdrowotnej.',
      });
    }
  });

  // ============================================================================
  // GET /api/admin/analytics/sroi
  // Social Return on Investment calculation
  // ============================================================================
  fastify.get('/api/admin/analytics/sroi', {
    schema: {
      description: 'Get SROI (Social Return on Investment) calculation',
      tags: ['admin', 'analytics'],
    },
  }, async (request, reply) => {
    try {
      const sroi = await analyticsService.getSROICalculation();
      return reply.send(sroi);
    } catch (err) {
      request.log.error(err, 'Failed to calculate SROI');
      return reply.status(500).send({
        error: 'ANALYTICS_ERROR',
        message: 'Nie udało się obliczyć SROI.',
      });
    }
  });

  // ============================================================================
  // GET /api/admin/analytics/cost-optimization
  // Cost optimization report for June 2026 target
  // ============================================================================
  fastify.get('/api/admin/analytics/cost-optimization', {
    schema: {
      description: 'Get cost optimization recommendations',
      tags: ['admin', 'analytics'],
    },
  }, async (request, reply) => {
    try {
      const report = await analyticsService.getCostOptimizationReport();
      return reply.send(report);
    } catch (err) {
      request.log.error(err, 'Failed to generate cost report');
      return reply.status(500).send({
        error: 'ANALYTICS_ERROR',
        message: 'Nie udało się wygenerować raportu optymalizacji.',
      });
    }
  });

  // ============================================================================
  // GET /api/admin/analytics/seniors/:seniorId
  // Per-senior detailed analytics
  // ============================================================================
  fastify.get('/api/admin/analytics/seniors/:seniorId', {
    schema: {
      description: 'Get detailed analytics for a specific senior',
      tags: ['admin', 'analytics'],
      params: {
        type: 'object',
        required: ['seniorId'],
        properties: {
          seniorId: { type: 'string', format: 'uuid' },
        },
      },
    },
  }, async (request, reply) => {
    try {
      const { seniorId } = request.params;

      const [voiceAnalytics, healthData] = await Promise.all([
        analyticsService.getVoiceAnalytics({ seniorId }),
        prisma.healthData.findMany({
          where: { seniorId },
          orderBy: { recordedAt: 'desc' },
          take: 30,
        }),
      ]);

      // Get senior details
      const senior = await prisma.senior.findUnique({
        where: { id: seniorId },
        select: {
          id: true,
          firstName: true,
          lastName: true,
          email: true,
          package: true,
          semaforLevel: true,
          healthScore: true,
          lastActiveAt: true,
          createdAt: true,
        },
      });

      if (!senior) {
        return reply.status(404).send({
          error: 'NOT_FOUND',
          message: 'Senior nie został znaleziony.',
        });
      }

      return reply.send({
        senior,
        voice: voiceAnalytics,
        health: {
          recordCount: healthData.length,
          latest: healthData[0] || null,
          records: healthData,
        },
      });
    } catch (err) {
      request.log.error(err, 'Failed to get senior analytics');
      return reply.status(500).send({
        error: 'ANALYTICS_ERROR',
        message: 'Nie udało się pobrać analityki seniora.',
      });
    }
  });

  // ============================================================================
  // POST /api/admin/analytics/export
  // Export analytics data as CSV/JSON
  // ============================================================================
  fastify.post('/api/admin/analytics/export', {
    schema: {
      description: 'Export analytics data',
      tags: ['admin', 'analytics'],
      body: {
        type: 'object',
        required: ['format', 'dataType'],
        properties: {
          format: { type: 'string', enum: ['csv', 'json'] },
          dataType: { type: 'string', enum: ['voice', 'health', 'seniors', 'costs'] },
          startDate: { type: 'string', format: 'date-time' },
          endDate: { type: 'string', format: 'date-time' },
        },
      },
    },
  }, async (request, reply) => {
    try {
      const { format, dataType, startDate, endDate } = request.body;

      // In production: generate actual export file
      // For now, return metadata
      return reply.send({
        status: 'queued',
        format,
        dataType,
        estimatedSize: '500 KB',
        downloadUrl: `/api/admin/analytics/exports/${Date.now()}.${format}`,
        expiresAt: new Date(Date.now() + 3600000).toISOString(),
      });
    } catch (err) {
      request.log.error(err, 'Failed to queue analytics export');
      return reply.status(500).send({
        error: 'EXPORT_ERROR',
        message: 'Nie udało się wyeksportować danych.',
      });
    }
  });
}

module.exports = analyticsRoutes;
