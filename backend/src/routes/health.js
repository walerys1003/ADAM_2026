/**
 * SilverTech Agent Adam — Health Data Routes
 * Health records, wearable sync, anomaly detection, health summaries
 */

async function healthRoutes(fastify, options) {
  const { prisma } = fastify;

  // ── Record health snapshot ────────────────────────────
  fastify.post('/record', {
    preHandler: [fastify.authenticate],
  }, async (request, reply) => {
    const record = await prisma.healthRecord.create({
      data: {
        ...request.body,
        recordedAt: request.body.recorded_at
          ? new Date(request.body.recorded_at)
          : new Date(),
      },
    });

    // Run anomaly detection
    const anomalies = await _detectAnomalies(prisma, record);

    // Update senior's last health check
    await prisma.senior.update({
      where: { id: record.seniorId },
      data: { lastHealthCheck: new Date() },
    });

    reply.code(201).send({ record, anomalies });
  });

  // ── Sync wearable data ────────────────────────────────
  fastify.post('/wearable/sync', {
    preHandler: [fastify.authenticate],
  }, async (request, reply) => {
    const { senior_id, device_id, data } = request.body;

    const record = await prisma.healthRecord.create({
      data: {
        seniorId: senior_id,
        heartRate: data.heart_rate,
        restingHr: data.resting_heart_rate,
        steps: data.steps,
        spo2: data.spo2,
        temperature: data.temperature,
        sleepHours: data.sleep_hours,
        sleepQuality: data.sleep_quality,
        deviceName: 'Xiaomi Smart Band 9 Pro',
        source: 'wearable',
        recordedAt: new Date(),
      },
    });

    await prisma.senior.update({
      where: { id: senior_id },
      data: {
        lastWearableSync: new Date(),
        wearableConnected: true,
      },
    });

    reply.code(201).send(record);
  });

  // ── Get health records ────────────────────────────────
  fastify.get('/:seniorId', {
    preHandler: [fastify.authenticate],
    schema: {
      querystring: {
        type: 'object',
        properties: {
          days: { type: 'integer', default: 7 },
          limit: { type: 'integer', default: 100 },
        },
      },
    },
  }, async (request) => {
    const { seniorId } = request.params;
    const { days, limit } = request.query;

    const since = new Date(Date.now() - days * 24 * 60 * 60 * 1000);

    const records = await prisma.healthRecord.findMany({
      where: { seniorId, recordedAt: { gte: since } },
      orderBy: { recordedAt: 'desc' },
      take: limit,
    });

    return records;
  });

  // ── Weekly health summary ─────────────────────────────
  fastify.get('/:seniorId/summary', {
    preHandler: [fastify.authenticate],
  }, async (request) => {
    const { seniorId } = request.params;
    const since = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);

    const records = await prisma.healthRecord.findMany({
      where: { seniorId, recordedAt: { gte: since } },
      orderBy: { recordedAt: 'asc' },
    });

    if (records.length === 0) {
      return { message: 'No health data for this period' };
    }

    const heartRates = records.filter(r => r.heartRate).map(r => r.heartRate!);
    const steps = records.filter(r => r.steps != null).map(r => r.steps!);
    const spo2Values = records.filter(r => r.spo2).map(r => r.spo2!);
    const sleepValues = records.filter(r => r.sleepHours).map(r => r.sleepHours!);

    const avg = arr => arr.reduce((a, b) => a + b, 0) / arr.length;

    return {
      period: { from: since, to: new Date() },
      totalRecords: records.length,
      heartRate: {
        avg: Math.round(avg(heartRates)),
        min: Math.min(...heartRates),
        max: Math.max(...heartRates),
      },
      steps: {
        total: steps.reduce((a, b) => a + b, 0),
        dailyAvg: Math.round(avg(steps)),
        mostActiveDay: Math.max(...steps),
      },
      spo2: {
        avg: Math.round(avg(spo2Values) * 10) / 10,
        min: Math.min(...spo2Values),
      },
      sleep: {
        avgHours: Math.round(avg(sleepValues) * 10) / 10,
        totalHours: Math.round(sleepValues.reduce((a, b) => a + b, 0) * 10) / 10,
      },
      trend: _calculateTrend(records),
    };
  });

  // ── Anomaly detection report ──────────────────────────
  fastify.get('/:seniorId/anomalies', {
    preHandler: [fastify.authenticate],
  }, async (request) => {
    const { seniorId } = request.params;
    const since = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);

    const records = await prisma.healthRecord.findMany({
      where: { seniorId, recordedAt: { gte: since } },
      orderBy: { recordedAt: 'desc' },
    });

    const anomalies = [];
    for (const record of records) {
      if (record.heartRate && record.heartRate > 120) {
        anomalies.push({
          date: record.recordedAt,
          metric: 'heart_rate',
          value: record.heartRate,
          threshold: 120,
          severity: record.heartRate > 140 ? 'CRITICAL' : 'ALERT',
        });
      }
      if (record.spo2 && record.spo2 < 90) {
        anomalies.push({
          date: record.recordedAt,
          metric: 'spo2',
          value: record.spo2,
          threshold: 90,
          severity: record.spo2 < 85 ? 'CRITICAL' : 'ALERT',
        });
      }
    }

    return { seniorId, period: '30 days', totalAnomalies: anomalies.length, anomalies };
  });
}

// ── Anomaly Detection Helper ──────────────────────────
async function _detectAnomalies(prisma, record) {
  const anomalies = [];
  const senior = await prisma.senior.findUnique({
    where: { id: record.seniorId },
  });

  if (record.heartRate && record.heartRate > 120) {
    anomalies.push({
      metric: 'heart_rate',
      value: record.heartRate,
      threshold: 120,
      severity: record.heartRate > 140 ? 'RED' : 'ORANGE',
    });
    await _escalateIfNeeded(prisma, record.seniorId, anomalies[anomalies.length - 1]);
  }

  if (record.spo2 && record.spo2 < 90) {
    anomalies.push({
      metric: 'spo2',
      value: record.spo2,
      threshold: 90,
      severity: record.spo2 < 85 ? 'RED' : 'ORANGE',
    });
    await _escalateIfNeeded(prisma, record.seniorId, anomalies[anomalies.length - 1]);
  }

  return anomalies;
}

async function _escalateIfNeeded(prisma, seniorId, anomaly) {
  if (anomaly.severity === 'RED') {
    await prisma.senior.update({
      where: { id: seniorId },
      data: { semaforLevel: 'RED' },
    });
    await prisma.alert.create({
      data: {
        seniorId,
        type: 'HEALTH_ANOMALY',
        severity: 'RED',
        title: `Krytyczna anomalia: ${anomaly.metric}`,
        description: `Wartość: ${anomaly.value}, próg: ${anomaly.threshold}`,
      },
    });
  }
}

function _calculateTrend(records) {
  if (records.length < 2) return 'insufficient_data';

  const recent = records.slice(0, Math.floor(records.length / 2));
  const older = records.slice(Math.floor(records.length / 2));

  const recentAvgHr = recent.filter(r => r.heartRate).reduce((a, b) => a + b.heartRate!, 0) / recent.filter(r => r.heartRate).length;
  const olderAvgHr = older.filter(r => r.heartRate).reduce((a, b) => a + b.heartRate!, 0) / older.filter(r => r.heartRate).length;

  if (recentAvgHr > olderAvgHr + 5) return 'heart_rate_increasing';
  if (recentAvgHr < olderAvgHr - 5) return 'heart_rate_decreasing';
  return 'stable';
}

module.exports = healthRoutes;
