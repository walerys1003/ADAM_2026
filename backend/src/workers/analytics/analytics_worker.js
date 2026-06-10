const { Worker } = require('bullmq');
const { PrismaClient } = require('@prisma/client');
const { redisConnection } = require('../../config/redis');

const prisma = new PrismaClient();

const analyticsWorker = new Worker(
  'analytics',
  async (job) => {
    const { type, data } = job.data;

    switch (type) {
      case 'conversation_metrics':
        return await processConversationMetrics(data);
      case 'health_trends':
        return await processHealthTrends(data);
      case 'senior_activity':
        return await processSeniorActivity(data);
      case 'platform_stats':
        return await processPlatformStats();
      case 'cost_analysis':
        return await processCostAnalysis(data);
      default:
        throw new Error(`Unknown analytics type: ${type}`);
    }
  },
  {
    connection: redisConnection,
    concurrency: 2,
    limiter: { max: 5, duration: 1000 },
  }
);

async function processConversationMetrics(data) {
  const { seniorId, startDate, endDate } = data || {};
  const where = { createdAt: { gte: new Date(startDate || Date.now() - 86400000) } };
  if (seniorId) where.seniorId = seniorId;

  const [totalConvs, avgDuration, moodDistribution] = await Promise.all([
    prisma.conversation.count({ where }),
    prisma.conversation.aggregate({ where, _avg: { durationSeconds: true } }),
    prisma.conversation.groupBy({ by: ['mood'], where, _count: true }),
  ]);

  await prisma.analyticsEvent.create({
    data: {
      type: 'CONVERSATION_METRICS',
      payload: {
        totalConversations: totalConvs,
        avgDurationSeconds: avgDuration._avg.durationSeconds || 0,
        moodDistribution: moodDistribution.map((m) => ({ mood: m.mood, count: m._count })),
        period: { start: startDate, end: endDate },
      },
      timestamp: new Date(),
    },
  });

  return { totalConvs, avgDuration: avgDuration._avg.durationSeconds, moodDist: moodDistribution };
}

async function processHealthTrends(data) {
  const { seniorId, metric, days = 30 } = data || {};
  const since = new Date(Date.now() - days * 86400000);
  const where = { seniorId, recordedAt: { gte: since } };

  const records = await prisma.healthRecord.findMany({
    where,
    orderBy: { recordedAt: 'asc' },
    select: { heartRate: true, systolic: true, diastolic: true, spo2: true, steps: true, sleepHours: true, recordedAt: true },
  });

  const trend = calculateTrend(records, metric || 'heartRate');

  return { seniorId, metric, days, trend, recordCount: records.length };
}

function calculateTrend(records, metric) {
  if (records.length < 2) return { direction: 'stable', change: 0, data: records };

  const values = records.map((r) => r[metric]).filter((v) => v != null);
  if (values.length < 2) return { direction: 'stable', change: 0 };

  const firstHalf = values.slice(0, Math.floor(values.length / 2));
  const secondHalf = values.slice(Math.floor(values.length / 2));
  const avgFirst = firstHalf.reduce((a, b) => a + b, 0) / firstHalf.length;
  const avgSecond = secondHalf.reduce((a, b) => a + b, 0) / secondHalf.length;
  const change = avgSecond - avgFirst;

  return {
    direction: Math.abs(change) < 2 ? 'stable' : change > 0 ? 'increasing' : 'decreasing',
    change: Math.round(change * 100) / 100,
    current: values[values.length - 1],
    average: Math.round((avgFirst + avgSecond) / 2 * 100) / 100,
  };
}

async function processSeniorActivity(data) {
  const { seniorId } = data || {};
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  const [convToday, medsTaken, healthToday] = await Promise.all([
    prisma.conversation.count({ where: { seniorId, createdAt: { gte: today } } }),
    prisma.medication.count({ where: { seniorId } }),
    prisma.healthRecord.findFirst({ where: { seniorId }, orderBy: { recordedAt: 'desc' } }),
  ]);

  return {
    seniorId,
    conversationsToday: convToday,
    medicationsActive: medsTaken,
    lastHealthRecord: healthToday?.recordedAt || null,
    timestamp: new Date().toISOString(),
  };
}

async function processPlatformStats() {
  const [totalSeniors, totalFamilies, totalConversations, semaforDist, packageDist] = await Promise.all([
    prisma.senior.count(),
    prisma.family.count(),
    prisma.conversation.count(),
    prisma.senior.groupBy({ by: ['semaforLevel'], _count: true }),
    prisma.senior.groupBy({ by: ['package'], _count: true }),
  ]);

  await prisma.analyticsEvent.create({
    data: {
      type: 'PLATFORM_STATS',
      payload: { totalSeniors, totalFamilies, totalConversations, semaforDist, packageDist },
      timestamp: new Date(),
    },
  });

  return { totalSeniors, totalFamilies, totalConversations, semaforDist, packageDist };
}

async function processCostAnalysis(data) {
  const { startDate, endDate } = data || {};
  const since = new Date(startDate || Date.now() - 30 * 86400000);
  const until = new Date(endDate || Date.now());

  const conversations = await prisma.conversation.count({
    where: { createdAt: { gte: since, lte: until } },
  });

  const estimatedCost = conversations * 0.114; // $0.114/conversation
  const target = 1250; // $1,250/month for 180 seniors

  return {
    period: { start: since, end: until },
    totalConversations: conversations,
    estimatedCost: `$${estimatedCost.toFixed(2)}`,
    monthlyTarget: `$${target}`,
    variance: `$${(estimatedCost - target).toFixed(2)}`,
    perConversation: '$0.114',
  };
}

analyticsWorker.on('completed', (job) => {
  console.log(`[AnalyticsWorker] ✅ ${job.data.type} completed`);
});

analyticsWorker.on('failed', (job, err) => {
  console.error(`[AnalyticsWorker] ❌ ${job?.data?.type}: ${err.message}`);
});

module.exports = { analyticsWorker };
