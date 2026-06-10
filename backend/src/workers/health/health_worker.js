const { Worker, Queue } = require('bullmq');
const { PrismaClient } = require('@prisma/client');
const { redisConnection } = require('../../config/redis');

const prisma = new PrismaClient();

// ─── Semafor thresholds ────────────────────────────────────────────────
const SemaforLevel = {
  GREEN: { min: 0, label: 'ZIELONY', color: '#4CAF50', description: 'W normie' },
  YELLOW: { min: 1, label: 'ŻÓŁTY', color: '#FFC107', description: 'Lekkie odchylenie' },
  ORANGE: { min: 2, label: 'POMARAŃCZOWY', color: '#FF9800', description: 'Wymaga uwagi' },
  RED: { min: 3, label: 'CZERWONY', color: '#F44336', description: 'Pilna interwencja' },
  PURPLE: { min: 4, label: 'FIOLETOWY', color: '#9C27B0', description: 'Stan zagrożenia życia' },
};

// ─── Anomaly detection config ──────────────────────────────────────────
const ANOMALY_CONFIG = {
  heartRate: { high: 120, low: 45, delta: 30 },       // bpm
  systolic: { high: 180, low: 85, delta: 30 },         // mmHg
  diastolic: { high: 110, low: 55, delta: 20 },        // mmHg
  spo2: { low: 90 },                                    // %
  steps: { low: 200, deltaDecline: 0.5 },              // 50% drop in 3-day avg
  sleep: { low: 3, high: 14 },                          // hours
  temperature: { high: 38.0, low: 35.0 },               // Celsius
};

// ─── Health Worker ─────────────────────────────────────────────────────
const healthWorker = new Worker(
  'health-processing',
  async (job) => {
    const { seniorId, healthData } = job.data;

    // 1. Fetch senior profile
    const senior = await prisma.senior.findUnique({
      where: { id: seniorId },
      include: {
        healthRecords: {
          orderBy: { recordedAt: 'desc' },
          take: 14, // Last 14 records for baseline
        },
      },
    });

    if (!senior) {
      throw new Error(`Senior ${seniorId} not found`);
    }

    // 2. Calculate baseline from recent records
    const baseline = calculateBaseline(senior.healthRecords);

    // 3. Detect anomalies
    const anomalies = detectAnomalies(healthData, baseline);

    // 4. Calculate semafor score
    const semaforScore = calculateSemaforScore(anomalies);

    // 5. Store health record
    const record = await prisma.healthRecord.create({
      data: {
        seniorId,
        heartRate: healthData.heartRate,
        systolic: healthData.systolic,
        diastolic: healthData.diastolic,
        spo2: healthData.spo2,
        steps: healthData.steps,
        sleepHours: healthData.sleepHours,
        temperature: healthData.temperature,
        weight: healthData.weight,
        anomalies: JSON.stringify(anomalies),
        semaforLevel: Object.keys(SemaforLevel)[semaforScore],
        semaforScore,
        source: healthData.source || 'health_connect',
        recordedAt: new Date(healthData.timestamp || Date.now()),
      },
    });

    // 6. Trigger alerts if needed
    if (semaforScore >= 2) {
      await triggerAlerts(seniorId, semaforScore, anomalies, record.id);
    }

    // 7. Update senior's semafor status
    await prisma.senior.update({
      where: { id: seniorId },
      data: {
        semaforLevel: Object.keys(SemaforLevel)[semaforScore],
        lastHealthCheck: new Date(),
      },
    });

    return {
      seniorId,
      recordId: record.id,
      semaforLevel: Object.keys(SemaforLevel)[semaforScore],
      anomalyCount: anomalies.length,
      baseline: {
        avgHeartRate: baseline.avgHeartRate,
        avgSystolic: baseline.avgSystolic,
        avgSleep: baseline.avgSleep,
      },
      cost: {
        anomalyDetection: '$0.0002',
        storage: '$0.0001',
        total: '$0.0003',
      },
    };
  },
  {
    connection: redisConnection,
    concurrency: 4,
    limiter: { max: 20, duration: 1000 },
    settings: {
      backoffStrategy: (attemptsMade) => Math.min(attemptsMade * 1000, 10000),
    },
  }
);

// ─── Baseline calculation ──────────────────────────────────────────────
function calculateBaseline(records) {
  if (records.length === 0) {
    return {
      avgHeartRate: 72,
      avgSystolic: 120,
      avgDiastolic: 80,
      avgSleep: 7,
      avgSteps: 5000,
      avgSpo2: 98,
    };
  }

  const avg = (arr, field) => {
    const vals = arr.map((r) => r[field]).filter((v) => v != null);
    return vals.length > 0 ? vals.reduce((a, b) => a + b, 0) / vals.length : null;
  };

  return {
    avgHeartRate: avg(records, 'heartRate') || 72,
    avgSystolic: avg(records, 'systolic') || 120,
    avgDiastolic: avg(records, 'diastolic') || 80,
    avgSleep: avg(records, 'sleepHours') || 7,
    avgSteps: avg(records, 'steps') || 5000,
    avgSpo2: avg(records, 'spo2') || 98,
  };
}

// ─── Anomaly detection ─────────────────────────────────────────────────
function detectAnomalies(current, baseline) {
  const anomalies = [];

  // Heart rate
  if (current.heartRate && baseline.avgHeartRate) {
    if (current.heartRate > ANOMALY_CONFIG.heartRate.high) {
      anomalies.push({
        type: 'HEART_RATE_HIGH',
        severity: 'warning',
        value: current.heartRate,
        threshold: ANOMALY_CONFIG.heartRate.high,
        message: `Tętno zbyt wysokie: ${current.heartRate} bpm`,
      });
    }
    if (current.heartRate < ANOMALY_CONFIG.heartRate.low) {
      anomalies.push({
        type: 'HEART_RATE_LOW',
        severity: 'critical',
        value: current.heartRate,
        threshold: ANOMALY_CONFIG.heartRate.low,
        message: `Tętno zbyt niskie: ${current.heartRate} bpm`,
      });
    }
    const hrdelta = Math.abs(current.heartRate - baseline.avgHeartRate);
    if (hrdelta > ANOMALY_CONFIG.heartRate.delta) {
      anomalies.push({
        type: 'HEART_RATE_DELTA',
        severity: 'info',
        value: hrdelta,
        threshold: ANOMALY_CONFIG.heartRate.delta,
        message: `Znaczna zmiana tętna: +/-${hrdelta.toFixed(0)} bpm`,
      });
    }
  }

  // Blood pressure
  if (current.systolic && current.systolic > ANOMALY_CONFIG.systolic.high) {
    anomalies.push({
      type: 'BP_SYSTOLIC_HIGH',
      severity: 'warning',
      value: current.systolic,
      threshold: ANOMALY_CONFIG.systolic.high,
      message: `Ciśnienie skurczowe zbyt wysokie: ${current.systolic} mmHg`,
    });
  }
  if (current.diastolic && current.diastolic > ANOMALY_CONFIG.diastolic.high) {
    anomalies.push({
      type: 'BP_DIASTOLIC_HIGH',
      severity: 'warning',
      value: current.diastolic,
      threshold: ANOMALY_CONFIG.diastolic.high,
      message: `Ciśnienie rozkurczowe zbyt wysokie: ${current.diastolic} mmHg`,
    });
  }

  // SpO2
  if (current.spo2 != null && current.spo2 < ANOMALY_CONFIG.spo2.low) {
    anomalies.push({
      type: 'SPO2_LOW',
      severity: 'critical',
      value: current.spo2,
      threshold: ANOMALY_CONFIG.spo2.low,
      message: `Saturacja zbyt niska: ${current.spo2}%`,
    });
  }

  // Sleep
  if (current.sleepHours != null && current.sleepHours < ANOMALY_CONFIG.sleep.low) {
    anomalies.push({
      type: 'SLEEP_LOW',
      severity: 'warning',
      value: current.sleepHours,
      threshold: ANOMALY_CONFIG.sleep.low,
      message: `Zbyt mało snu: ${current.sleepHours}h`,
    });
  }

  // Steps decline
  if (current.steps != null && baseline.avgSteps > 0) {
    const decline = (baseline.avgSteps - current.steps) / baseline.avgSteps;
    if (decline > ANOMALY_CONFIG.steps.deltaDecline) {
      anomalies.push({
        type: 'ACTIVITY_DECLINE',
        severity: 'info',
        value: current.steps,
        threshold: baseline.avgSteps,
        message: `Znaczny spadek aktywności: ${(decline * 100).toFixed(0)}%`,
      });
    }
  }

  // Temperature
  if (current.temperature != null && current.temperature > ANOMALY_CONFIG.temperature.high) {
    anomalies.push({
      type: 'FEVER',
      severity: 'warning',
      value: current.temperature,
      threshold: ANOMALY_CONFIG.temperature.high,
      message: `Gorączka: ${current.temperature}°C`,
    });
  }

  return anomalies;
}

// ─── Semafor scoring ───────────────────────────────────────────────────
function calculateSemaforScore(anomalies) {
  if (anomalies.length === 0) return 0;

  let score = 0;
  for (const a of anomalies) {
    switch (a.severity) {
      case 'critical':
        score += 3;
        break;
      case 'warning':
        score += 2;
        break;
      case 'info':
        score += 1;
        break;
    }
  }

  if (score >= 7) return 4; // PURPLE
  if (score >= 5) return 3; // RED
  if (score >= 3) return 2; // ORANGE
  if (score >= 1) return 1; // YELLOW
  return 0; // GREEN
}

// ─── Alert triggering ──────────────────────────────────────────────────
async function triggerAlerts(seniorId, semaforScore, anomalies, recordId) {
  const alertQueue = new Queue('alert', { connection: redisConnection });

  await alertQueue.add(
    'health-alert',
    {
      seniorId,
      semaforLevel: Object.keys(SemaforLevel)[semaforScore],
      semaforLabel: SemaforLevel[Object.keys(SemaforLevel)[semaforScore]].label,
      anomalies: anomalies.map((a) => a.message),
      recordId,
      timestamp: new Date().toISOString(),
    },
    {
      priority: semaforScore >= 3 ? 1 : 3,
      attempts: 3,
      backoff: { type: 'exponential', delay: 5000 },
    }
  );

  await alertQueue.close();
}

// ─── Event handlers ────────────────────────────────────────────────────
healthWorker.on('completed', (job) => {
  const { semaforLevel, anomalyCount } = job.returnvalue;
  console.log(
    `[HealthWorker] ✅ ${job.data.seniorId}: ${semaforLevel} (${anomalyCount} anomalies)`
  );
});

healthWorker.on('failed', (job, err) => {
  console.error(`[HealthWorker] ❌ ${job?.data?.seniorId}: ${err.message}`);
});

module.exports = { healthWorker, SemaforLevel, ANOMALY_CONFIG };
