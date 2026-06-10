'use strict';

const { authenticate } = require('../middleware/auth');

/**
 * Webhook routes for external service integrations.
 *
 * Endpoints:
 * - POST /webhooks/twilio/status    — Twilio call status callbacks
 * - POST /webhooks/twilio/recording — Twilio recording ready callback
 * - POST /webhooks/deepgram/result  — Deepgram async transcription result
 * - POST /webhooks/stripe           — Stripe payment events
 * - POST /webhooks/health-connect   — Google Health Connect data sync
 * - POST /webhooks/healthchecks     — Healthchecks.io ping endpoint
 */

async function webhookRoutes(fastify, options) {
  const { prisma, redis } = fastify;

  // ============================================================================
  // TWILIO — Call Status Callback
  // ============================================================================
  fastify.post('/webhooks/twilio/status', {
    config: { rawBody: true },
    schema: {
      description: 'Twilio voice call status callback',
      tags: ['webhooks', 'twilio'],
    },
  }, async (request, reply) => {
    const {
      CallSid,
      CallStatus,
      CallDuration,
      From,
      To,
      RecordingUrl,
    } = request.body;

    request.log.info({ CallSid, CallStatus }, 'Twilio call status update');

    try {
      // Update conversation record in database
      if (CallSid) {
        await prisma.conversation.updateMany({
          where: { twilioCallSid: CallSid },
          data: {
            status: CallStatus.toLowerCase(),
            durationSeconds: CallDuration ? parseInt(CallDuration) : null,
            recordingUrl: RecordingUrl || null,
            endedAt: ['completed', 'failed', 'busy', 'no-answer'].includes(CallStatus)
              ? new Date()
              : undefined,
          },
        });
      }

      // If call failed, queue retry or alert
      if (['failed', 'busy', 'no-answer'].includes(CallStatus)) {
        await redis?.lpush('voice:retry_queue', JSON.stringify({
          seniorId: From,
          reason: CallStatus,
          timestamp: new Date().toISOString(),
          callSid: CallSid,
        }));
      }

      return reply.send({ received: true });
    } catch (err) {
      request.log.error(err, 'Failed to process Twilio status callback');
      // Always return 200 to Twilio to prevent retries
      return reply.send({ received: true, error: 'processing_failed' });
    }
  });

  // ============================================================================
  // TWILIO — Recording Ready Callback
  // ============================================================================
  fastify.post('/webhooks/twilio/recording', {
    config: { rawBody: true },
    schema: {
      description: 'Twilio recording ready callback',
      tags: ['webhooks', 'twilio'],
    },
  }, async (request, reply) => {
    const { CallSid, RecordingUrl, RecordingDuration } = request.body;

    request.log.info({ CallSid }, 'Twilio recording ready');

    try {
      await prisma.conversation.updateMany({
        where: { twilioCallSid: CallSid },
        data: {
          recordingUrl: RecordingUrl,
          recordingDurationSeconds: RecordingDuration
            ? parseInt(RecordingDuration)
            : null,
        },
      });

      // Queue transcription if async
      await redis?.lpush('voice:transcription_queue', JSON.stringify({
        callSid: CallSid,
        recordingUrl: RecordingUrl,
        timestamp: new Date().toISOString(),
      }));

      return reply.send({ received: true });
    } catch (err) {
      request.log.error(err, 'Failed to process recording callback');
      return reply.send({ received: true });
    }
  });

  // ============================================================================
  // STRIPE — Payment Events
  // ============================================================================
  fastify.post('/webhooks/stripe', {
    config: { rawBody: true },
    schema: {
      description: 'Stripe webhook for payment events',
      tags: ['webhooks', 'stripe'],
      body: {
        type: 'object',
      },
    },
  }, async (request, reply) => {
    const stripeSignature = request.headers['stripe-signature'];
    const stripeWebhookSecret = process.env.STRIPE_WEBHOOK_SECRET;

    if (!stripeWebhookSecret) {
      return reply.status(500).send({ error: 'Stripe webhook not configured' });
    }

    try {
      // In production: verify Stripe signature
      // const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
      // const event = stripe.webhooks.constructEvent(
      //   request.rawBody, stripeSignature, stripeWebhookSecret
      // );

      const event = request.body;

      request.log.info({ type: event.type }, 'Stripe webhook received');

      switch (event.type) {
        case 'checkout.session.completed': {
          const session = event.data.object;
          const seniorId = session.metadata?.seniorId;
          const packageName = session.metadata?.package;

          if (seniorId && packageName) {
            await prisma.senior.update({
              where: { id: seniorId },
              data: {
                package: packageName,
                subscriptionStatus: 'ACTIVE',
                subscriptionId: session.subscription,
                stripeCustomerId: session.customer,
              },
            });

            request.log.info({ seniorId, packageName }, 'Subscription activated');
          }
          break;
        }

        case 'customer.subscription.deleted': {
          const subscription = event.data.object;

          await prisma.senior.updateMany({
            where: { subscriptionId: subscription.id },
            data: {
              subscriptionStatus: 'CANCELLED',
              package: 'KONTAKT', // Fallback to free tier
            },
          });

          request.log.info({ subscriptionId: subscription.id }, 'Subscription cancelled');
          break;
        }

        case 'invoice.payment_failed': {
          const invoice = event.data.object;

          const senior = await prisma.senior.findFirst({
            where: { stripeCustomerId: invoice.customer },
          });

          if (senior) {
            // Alert family about payment failure
            await redis?.publish('notifications:payment_failed', JSON.stringify({
              seniorId: senior.id,
              seniorName: `${senior.firstName} ${senior.lastName}`,
              timestamp: new Date().toISOString(),
            }));
          }
          break;
        }

        default:
          request.log.info({ type: event.type }, 'Unhandled Stripe event type');
      }

      return reply.send({ received: true });
    } catch (err) {
      request.log.error(err, 'Stripe webhook error');
      return reply.status(400).send({ error: 'Webhook verification failed' });
    }
  });

  // ============================================================================
  // GOOGLE HEALTH CONNECT — Data Sync
  // ============================================================================
  fastify.post('/webhooks/health-connect', {
    preHandler: [authenticate],
    schema: {
      description: 'Receive health data from Google Health Connect API',
      tags: ['webhooks', 'health'],
      body: {
        type: 'object',
        required: ['seniorId', 'healthData'],
        properties: {
          seniorId: { type: 'string' },
          healthData: { type: 'object' },
        },
      },
    },
  }, async (request, reply) => {
    const { seniorId, healthData } = request.body;

    try {
      const record = await prisma.healthData.create({
        data: {
          seniorId,
          heartRate: healthData.heartRate,
          bloodPressureSystolic: healthData.bloodPressureSystolic,
          bloodPressureDiastolic: healthData.bloodPressureDiastolic,
          bloodOxygen: healthData.bloodOxygen,
          steps: healthData.steps,
          sleepHours: healthData.sleepHours,
          sleepQuality: healthData.sleepQuality,
          temperature: healthData.temperature,
          weight: healthData.weight,
          source: 'GOOGLE_HEALTH_CONNECT',
          recordedAt: new Date(healthData.timestamp || Date.now()),
        },
      });

      // Queue health analysis
      await redis?.lpush('health:analysis_queue', JSON.stringify({
        healthDataId: record.id,
        seniorId,
        timestamp: new Date().toISOString(),
      }));

      return reply.status(201).send({
        id: record.id,
        message: 'Health data synced successfully',
      });
    } catch (err) {
      request.log.error(err, 'Failed to sync health data');
      return reply.status(500).send({
        error: 'SYNC_FAILED',
        message: 'Nie udało się zapisać danych zdrowotnych.',
      });
    }
  });

  // ============================================================================
  // HEALTHCHECKS.IO — Monitoring Ping
  // ============================================================================
  fastify.get('/webhooks/healthchecks/:checkId', {
    schema: {
      description: 'Healthchecks.io monitoring ping endpoint',
      tags: ['webhooks', 'monitoring'],
      params: {
        type: 'object',
        properties: {
          checkId: { type: 'string' },
        },
      },
    },
  }, async (request, reply) => {
    const { checkId } = request.params;

    // Verify the check ID matches expected
    const expectedCheckId = process.env.HEALTHCHECK_IO_CHECK_ID;
    if (expectedCheckId && checkId !== expectedCheckId) {
      return reply.status(404).send({ error: 'Check not found' });
    }

    // Report health status
    const healthStatus = {
      timestamp: new Date().toISOString(),
      services: {
        api: 'healthy',
        database: await checkDatabase(prisma),
        redis: await checkRedis(redis),
      },
    };

    return reply.send(healthStatus);
  });
}

// ---- Health Check Helpers ----

async function checkDatabase(prisma) {
  try {
    await prisma.$queryRaw`SELECT 1`;
    return 'healthy';
  } catch {
    return 'unhealthy';
  }
}

async function checkRedis(redis) {
  try {
    if (!redis) return 'not_configured';
    await redis.ping();
    return 'healthy';
  } catch {
    return 'unhealthy';
  }
}

module.exports = webhookRoutes;
