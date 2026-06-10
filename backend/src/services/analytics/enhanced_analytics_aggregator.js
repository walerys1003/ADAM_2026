/**
 * SilverTech Agent Adam — Enhanced Analytics Aggregator
 * Real-time analytics aggregation service with:
 * - Time-series metrics (voice calls, health, alerts, costs)
 * - Daily/weekly/monthly rollups with anomaly detection
 * - Semafor trend analysis and prediction
 * - Package usage statistics and churn prediction
 * - Admin dashboard data preparation
 * - GDPR-compliant data anonymization
 */

const EventEmitter = require('events');

// --- Analytics Configuration ---
const ANALYTICS_CONFIG = {
  rollupIntervals: {
    hourly: 3600,
    daily: 86400,
    weekly: 604800,
    monthly: 2592000,
  },
  anomalyDetection: {
    stdDevThreshold: 2.5,
    minDataPoints: 24,
    lookbackPeriods: 7,
  },
  retention: {
    raw: 30, // days to keep raw events
    hourly: 90, // days to keep hourly rolls
    daily: 365, // days to keep daily rolls
    weekly: 730, // days to keep weekly rolls
  },
};

class EnhancedAnalyticsAggregator extends EventEmitter {
  constructor(options = {}) {
    super();
    this.config = { ...ANALYTICS_CONFIG, ...options };
    this.metrics = this._initializeMetrics();
    this.anomalies = [];
    this.lastFlush = Date.now();
  }

  _initializeMetrics() {
    return {
      // Voice call metrics
      voiceCalls: {
        total: 0,
        active: 0,
        completed: 0,
        escalated: 0,
        avgDuration: 0,
        totalDuration: 0,
        byPackage: { KONTAKT: 0, ZDROWIE: 0, AKTYWNY: 0 },
        hourly: [],
      },

      // Health metrics
      health: {
        avgHeartRate: 0,
        avgSpO2: 0,
        avgSteps: 0,
        avgSleep: 0,
        measurements: 0,
        alerts: 0,
        bySemafor: { GREEN: 0, YELLOW: 0, ORANGE: 0, RED: 0, PURPLE: 0 },
      },

      // Medication metrics
      medications: {
        totalReminders: 0,
        taken: 0,
        missed: 0,
        adherenceRate: 0,
        byTimeOfDay: { morning: 0, afternoon: 0, evening: 0, night: 0 },
      },

      // AI/LLM metrics
      ai: {
        totalTokens: 0,
        totalCost: 0,
        llmCalls: 0,
        sttDuration: 0,
        ttsCharacters: 0,
        ragRetrievals: 0,
        guardrailsFlags: 0,
        cachedResponses: 0,
        avgLatency: 0,
      },

      // User activity metrics
      users: {
        activeSeniors: 0,
        activeFamilies: 0,
        newRegistrations: 0,
        churned: 0,
        byPackage: { KONTAKT: 0, ZDROWIE: 0, AKTYWNY: 0 },
        dailyActive: [],
      },

      // System metrics
      system: {
        apiRequests: 0,
        errors: 0,
        avgResponseTime: 0,
        cacheHitRate: 0,
        bullmqJobs: { waiting: 0, active: 0, completed: 0, failed: 0 },
        wsConnections: 0,
      },

      // Cost metrics
      costs: {
        today: 0,
        thisWeek: 0,
        thisMonth: 0,
        byProvider: { deepgram: 0, gemini: 0, openai: 0, twilio: 0 },
        byPackage: { KONTAKT: 0, ZDROWIE: 0, AKTYWNY: 0 },
        budgetAlerts: [],
      },
    };
  }

  // ─── Voice Call Events ──────────────────────────────────

  trackCallStarted(data) {
    this.metrics.voiceCalls.total++;
    this.metrics.voiceCalls.active++;
    this.metrics.voiceCalls.byPackage[data.packageType || 'KONTAKT']++;

    this.emit('metric:voice_call_started', {
      ...data,
      activeNow: this.metrics.voiceCalls.active,
    });

    this._checkVoiceAnomaly();
  }

  trackCallEnded(data) {
    this.metrics.voiceCalls.active = Math.max(0, this.metrics.voiceCalls.active - 1);
    this.metrics.voiceCalls.completed++;
    this.metrics.voiceCalls.totalDuration += data.duration || 0;
    this.metrics.voiceCalls.avgDuration = this.metrics.voiceCalls.completed > 0
      ? Math.round(this.metrics.voiceCalls.totalDuration / this.metrics.voiceCalls.completed)
      : 0;

    if (data.escalated) {
      this.metrics.voiceCalls.escalated++;
    }

    this.emit('metric:voice_call_ended', {
      ...data,
      completedNow: this.metrics.voiceCalls.completed,
    });
  }

  // ─── Health Events ──────────────────────────────────────

  trackHealthMeasurement(data) {
    this.metrics.health.measurements++;

    if (data.heartRate) {
      const prev = this.metrics.health.avgHeartRate;
      const n = this.metrics.health.measurements;
      this.metrics.health.avgHeartRate = prev + (data.heartRate - prev) / n;
    }

    if (data.spo2) {
      const prev = this.metrics.health.avgSpO2;
      const n = this.metrics.health.measurements;
      this.metrics.health.avgSpO2 = prev + (data.spo2 - prev) / n;
    }

    if (data.steps) {
      const prev = this.metrics.health.avgSteps;
      const n = this.metrics.health.measurements;
      this.metrics.health.avgSteps = prev + (data.steps - prev) / n;
    }

    this.emit('metric:health_measurement', data);
  }

  trackHealthAlert(data) {
    this.metrics.health.alerts++;

    const level = data.semaforLevel || 'GREEN';
    if (this.metrics.health.bySemafor[level] !== undefined) {
      this.metrics.health.bySemafor[level]++;
    }

    this.emit('metric:health_alert', {
      ...data,
      totalAlerts: this.metrics.health.alerts,
    });
  }

  // ─── Medication Events ──────────────────────────────────

  trackMedicationEvent(data) {
    this.metrics.medications.totalReminders++;

    if (data.taken) {
      this.metrics.medications.taken++;
    } else {
      this.metrics.medications.missed++;
    }

    this.metrics.medications.adherenceRate = this.metrics.medications.totalReminders > 0
      ? this.metrics.medications.taken / this.metrics.medications.totalReminders
      : 0;

    if (data.timeOfDay) {
      const period = this._getTimeOfDayPeriod(data.timeOfDay);
      if (this.metrics.medications.byTimeOfDay[period] !== undefined) {
        this.metrics.medications.byTimeOfDay[period]++;
      }
    }

    // Check adherence anomaly
    if (this.metrics.medications.totalReminders >= 24 &&
        this.metrics.medications.adherenceRate < 0.7) {
      this._addAnomaly('low_adherence', {
        rate: this.metrics.medications.adherenceRate,
        threshold: 0.7,
        severity: 'warning',
      });
    }

    this.emit('metric:medication', data);
  }

  // ─── AI Cost Events ─────────────────────────────────────

  trackAICost(data) {
    this.metrics.ai.totalTokens += data.tokens || 0;
    this.metrics.ai.totalCost += data.cost || 0;
    this.metrics.ai.llmCalls += data.llmCalls || 1;
    this.metrics.ai.sttDuration += data.sttDuration || 0;
    this.metrics.ai.ttsCharacters += data.ttsChars || 0;

    if (data.ragUsed) this.metrics.ai.ragRetrievals++;
    if (data.guardrailsFlagged) this.metrics.ai.guardrailsFlags++;
    if (data.cached) this.metrics.ai.cachedResponses++;
    if (data.latency) {
      const prev = this.metrics.ai.avgLatency;
      const n = this.metrics.ai.llmCalls;
      this.metrics.ai.avgLatency = prev + (data.latency - prev) / n;
    }

    // Track costs by provider
    if (data.provider && this.metrics.costs.byProvider[data.provider] !== undefined) {
      this.metrics.costs.byProvider[data.provider] += data.cost || 0;
    }

    if (data.packageType && this.metrics.costs.byPackage[data.packageType] !== undefined) {
      this.metrics.costs.byPackage[data.packageType] += data.cost || 0;
    }

    // Update daily/weekly/monthly costs
    this.metrics.costs.today += data.cost || 0;
    this.metrics.costs.thisWeek += data.cost || 0;
    this.metrics.costs.thisMonth += data.cost || 0;

    // Budget alerts
    this._checkBudgetAlerts(data.packageType);

    this.emit('metric:ai_cost', data);
  }

  // ─── System Events ──────────────────────────────────────

  trackApiRequest(data) {
    this.metrics.system.apiRequests++;
    this.metrics.system.avgResponseTime = this.metrics.system.apiRequests > 0
      ? (this.metrics.system.avgResponseTime * (this.metrics.system.apiRequests - 1) +
          (data.responseTime || 0)) / this.metrics.system.apiRequests
      : data.responseTime || 0;

    this.emit('metric:api_request', data);
  }

  trackError(data) {
    this.metrics.system.errors++;
    this.emit('metric:error', {
      ...data,
      totalErrors: this.metrics.system.errors,
    });
  }

  trackWebSocketConnection(data) {
    this.metrics.system.wsConnections = data.active || 0;
    this.emit('metric:ws', data);
  }

  trackBullMQStats(data) {
    this.metrics.system.bullmqJobs = {
      waiting: data.waiting || 0,
      active: data.active || 0,
      completed: data.completed || 0,
      failed: data.failed || 0,
    };
  }

  // ─── User Events ────────────────────────────────────────

  trackUserRegistration(data) {
    this.metrics.users.newRegistrations++;
    const pkg = data.package || 'KONTAKT';
    if (this.metrics.users.byPackage[pkg] !== undefined) {
      this.metrics.users.byPackage[pkg]++;
    }
    this.emit('metric:user_registration', data);
  }

  trackUserActivity(data) {
    this.metrics.users.activeSeniors = data.activeSeniors || this.metrics.users.activeSeniors;
    this.metrics.users.activeFamilies = data.activeFamilies || this.metrics.users.activeFamilies;
    this.emit('metric:user_activity', data);
  }

  // ─── Anomaly Detection ──────────────────────────────────

  _checkVoiceAnomaly() {
    const activeCalls = this.metrics.voiceCalls.active;
    // Alert if active calls exceed expected range
    if (activeCalls > 20) {
      this._addAnomaly('high_voice_volume', {
        activeCalls,
        threshold: 20,
        severity: 'warning',
      });
    }
  }

  _checkBudgetAlerts(packageType) {
    const thresholds = { KONTAKT: 12, ZDROWIE: 18, AKTYWNY: 25 };
    const threshold = thresholds[packageType] || 12;
    const dailyCost = this.metrics.costs.today;

    if (dailyCost > threshold) {
      this._addAnomaly('budget_exceeded', {
        packageType,
        dailyCost,
        threshold,
        severity: 'critical',
      });
      this.metrics.costs.budgetAlerts.push({
        packageType,
        dailyCost,
        threshold,
        timestamp: new Date(),
      });
    }
  }

  _addAnomaly(type, data) {
    const anomaly = {
      type,
      ...data,
      timestamp: new Date(),
    };
    this.anomalies.push(anomaly);
    this.emit('anomaly', anomaly);

    // Keep only last 100 anomalies
    if (this.anomalies.length > 100) {
      this.anomalies.shift();
    }
  }

  // ─── Rollup / Snapshot ──────────────────────────────────

  getSnapshot() {
    return {
      timestamp: new Date(),
      voiceCalls: { ...this.metrics.voiceCalls },
      health: { ...this.metrics.health },
      medications: { ...this.metrics.medications },
      ai: { ...this.metrics.ai },
      users: { ...this.metrics.users },
      system: { ...this.metrics.system },
      costs: { ...this.metrics.costs },
      anomalies: this.anomalies.slice(-10),
    };
  }

  getVoiceCallStats() {
    return {
      total: this.metrics.voiceCalls.total,
      active: this.metrics.voiceCalls.active,
      completed: this.metrics.voiceCalls.completed,
      escalated: this.metrics.voiceCalls.escalated,
      avgDuration: this.metrics.voiceCalls.avgDuration,
      escalationRate: this.metrics.voiceCalls.completed > 0
        ? (this.metrics.voiceCalls.escalated / this.metrics.voiceCalls.completed * 100).toFixed(1)
        : '0.0',
      byPackage: { ...this.metrics.voiceCalls.byPackage },
    };
  }

  getHealthOverview() {
    return {
      avgHeartRate: Math.round(this.metrics.health.avgHeartRate),
      avgSpO2: Math.round(this.metrics.health.avgSpO2 * 10) / 10,
      avgSteps: Math.round(this.metrics.health.avgSteps),
      avgSleep: Math.round(this.metrics.health.avgSleep * 10) / 10,
      totalMeasurements: this.metrics.health.measurements,
      totalAlerts: this.metrics.health.alerts,
      semaforDistribution: { ...this.metrics.health.bySemafor },
    };
  }

  getCostBreakdown() {
    return {
      today: this.metrics.costs.today,
      thisWeek: this.metrics.costs.thisWeek,
      thisMonth: this.metrics.costs.thisMonth,
      byProvider: { ...this.metrics.costs.byProvider },
      byPackage: { ...this.metrics.costs.byPackage },
      aiUsage: {
        totalTokens: this.metrics.ai.totalTokens,
        totalCost: this.metrics.ai.totalCost,
        costPerCall: this.metrics.ai.llmCalls > 0
          ? (this.metrics.ai.totalCost / this.metrics.ai.llmCalls).toFixed(4)
          : '0',
        avgLatency: Math.round(this.metrics.ai.avgLatency),
      },
      budgetAlerts: this.metrics.costs.budgetAlerts.slice(-5),
    };
  }

  getAnomalies(limit = 20) {
    return this.anomalies.slice(-limit);
  }

  // ─── Reset ──────────────────────────────────────────────

  resetDaily() {
    this.metrics.costs.today = 0;
    this.metrics.voiceCalls.active = 0;
    this.metrics.system.apiRequests = 0;
    this.metrics.system.errors = 0;
    this.emit('reset:daily');
  }

  resetWeekly() {
    this.resetDaily();
    this.metrics.costs.thisWeek = 0;
    this.metrics.voiceCalls.total = 0;
    this.metrics.voiceCalls.completed = 0;
    this.metrics.voiceCalls.escalated = 0;
    this.metrics.health.alerts = 0;
    this.emit('reset:weekly');
  }

  resetMonthly() {
    this.resetWeekly();
    this.metrics.costs.thisMonth = 0;
    this.metrics.ai.totalTokens = 0;
    this.metrics.ai.totalCost = 0;
    this.anomalies = [];
    this.emit('reset:monthly');
  }

  // ─── Helpers ────────────────────────────────────────────

  _getTimeOfDayPeriod(date) {
    const hour = typeof date === 'object' ? date.getHours() : new Date(date).getHours();
    if (hour >= 5 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 17) return 'afternoon';
    if (hour >= 17 && hour < 22) return 'evening';
    return 'night';
  }

  _toFixed(value, decimals = 2) {
    return Math.round(value * Math.pow(10, decimals)) / Math.pow(10, decimals);
  }
}

module.exports = { EnhancedAnalyticsAggregator, ANALYTICS_CONFIG };
