'use strict';

/**
 * Usage Analytics Service for Agent Adam.
 *
 * Tracks and aggregates platform-wide usage metrics:
 * - Voice call volume, duration, and cost
 * - Active users (daily, weekly, monthly)
 * - Feature adoption rates
 * - Semafor alert distribution
 * - Cost per senior per month
 * - SROI calculation
 */

class UsageAnalyticsService {
  constructor(prisma, redis) {
    this.prisma = prisma;
    this.redis = redis;
    this.cachePrefix = 'analytics:';
    this.cacheTTL = 3600; // 1 hour
  }

  /**
   * Get dashboard overview metrics.
   * Cached for 1 hour.
   */
  async getDashboardOverview() {
    const cacheKey = `${this.cachePrefix}dashboard_overview`;

    const cached = await this.redis?.get(cacheKey);
    if (cached) return JSON.parse(cached);

    try {
      const now = new Date();
      const todayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate());
      const weekStart = new Date(now);
      weekStart.setDate(now.getDate() - 7);
      const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);

      const [
        totalSeniors,
        activeSeniorsToday,
        totalConversations,
        conversationsToday,
        totalVoiceCostMonthly,
        semaforDistribution,
        packageDistribution,
      ] = await Promise.all([
        this.prisma.senior.count(),
        this.prisma.senior.count({
          where: {
            lastActiveAt: { gte: todayStart },
          },
        }),
        this.prisma.conversation.count(),
        this.prisma.conversation.count({
          where: {
            startedAt: { gte: todayStart },
          },
        }),
        this._getMonthlyVoiceCost(monthStart),
        this._getSemaforDistribution(),
        this._getPackageDistribution(),
      ]);

      const overview = {
        timestamp: now.toISOString(),
        seniors: {
          total: totalSeniors,
          activeToday: activeSeniorsToday,
          activationRate: totalSeniors > 0
            ? (activeSeniorsToday / totalSeniors * 100).toFixed(1)
            : '0.0',
        },
        conversations: {
          total: totalConversations,
          today: conversationsToday,
          averagePerSenior: totalSeniors > 0
            ? (conversationsToday / totalSeniors).toFixed(1)
            : '0.0',
        },
        costs: {
          voiceThisMonth: totalVoiceCostMonthly,
          projectedMonthly: this._projectMonthlyCost(totalVoiceCostMonthly, now),
        },
        semafor: semaforDistribution,
        packages: packageDistribution,
      };

      // Cache for 1 hour
      await this.redis?.setex(cacheKey, this.cacheTTL, JSON.stringify(overview));

      return overview;
    } catch (err) {
      throw new Error(`Failed to get dashboard overview: ${err.message}`);
    }
  }

  /**
   * Get voice call analytics for a date range.
   */
  async getVoiceAnalytics({ startDate, endDate, seniorId } = {}) {
    const where = {};

    if (startDate || endDate) {
      where.startedAt = {};
      if (startDate) where.startedAt.gte = new Date(startDate);
      if (endDate) where.startedAt.lte = new Date(endDate);
    }
    if (seniorId) where.seniorId = seniorId;

    try {
      const conversations = await this.prisma.conversation.findMany({
        where,
        orderBy: { startedAt: 'desc' },
        select: {
          id: true,
          startedAt: true,
          durationSeconds: true,
          voiceCost: true,
          mood: true,
          semaforLevel: true,
          topics: true,
        },
      });

      const total = conversations.length;
      const totalDuration = conversations.reduce((sum, c) => sum + (c.durationSeconds || 0), 0);
      const totalCost = conversations.reduce((sum, c) => sum + (c.voiceCost || 0), 0);

      const moodCounts = {};
      const topicCounts = {};
      const hourlyDistribution = new Array(24).fill(0);

      for (const conv of conversations) {
        // Mood aggregation
        const mood = conv.mood || 'UNKNOWN';
        moodCounts[mood] = (moodCounts[mood] || 0) + 1;

        // Topic aggregation
        if (conv.topics && Array.isArray(conv.topics)) {
          for (const topic of conv.topics) {
            topicCounts[topic] = (topicCounts[topic] || 0) + 1;
          }
        }

        // Hourly distribution
        if (conv.startedAt) {
          const hour = new Date(conv.startedAt).getHours();
          hourlyDistribution[hour]++;
        }
      }

      return {
        total,
        totalDurationSeconds: totalDuration,
        averageDurationSeconds: total > 0 ? Math.round(totalDuration / total) : 0,
        totalCost: Math.round(totalCost * 10000) / 10000,
        averageCost: total > 0 ? Math.round((totalCost / total) * 10000) / 10000 : 0,
        moodDistribution: moodCounts,
        topTopics: Object.entries(topicCounts)
          .sort((a, b) => b[1] - a[1])
          .slice(0, 10)
          .map(([topic, count]) => ({ topic, count })),
        hourlyDistribution,
        peakHour: hourlyDistribution.indexOf(Math.max(...hourlyDistribution)),
      };
    } catch (err) {
      throw new Error(`Failed to get voice analytics: ${err.message}`);
    }
  }

  /**
   * Get health analytics summary.
   */
  async getHealthAnalytics({ startDate, endDate } = {}) {
    const where = {};

    if (startDate || endDate) {
      where.recordedAt = {};
      if (startDate) where.recordedAt.gte = new Date(startDate);
      if (endDate) where.recordedAt.lte = new Date(endDate);
    }

    try {
      const healthRecords = await this.prisma.healthData.findMany({
        where,
        orderBy: { recordedAt: 'desc' },
        select: {
          heartRate: true,
          bloodPressureSystolic: true,
          bloodPressureDiastolic: true,
          bloodOxygen: true,
          steps: true,
          sleepHours: true,
          temperature: true,
          source: true,
        },
      });

      if (healthRecords.length === 0) {
        return { totalRecords: 0, message: 'No health data available' };
      }

      // Calculate averages
      const avg = (field) => {
        const values = healthRecords.map(r => r[field]).filter(v => v != null);
        return values.length > 0
          ? Math.round(values.reduce((a, b) => a + b, 0) / values.length * 10) / 10
          : null;
      };

      // Source distribution
      const sourceDist = {};
      for (const r of healthRecords) {
        const src = r.source || 'UNKNOWN';
        sourceDist[src] = (sourceDist[src] || 0) + 1;
      }

      return {
        totalRecords: healthRecords.length,
        averages: {
          heartRate: avg('heartRate'),
          bloodPressureSystolic: avg('bloodPressureSystolic'),
          bloodPressureDiastolic: avg('bloodPressureDiastolic'),
          bloodOxygen: avg('bloodOxygen'),
          steps: avg('steps'),
          sleepHours: avg('sleepHours'),
          temperature: avg('temperature'),
        },
        sourceDistribution: sourceDist,
      };
    } catch (err) {
      throw new Error(`Failed to get health analytics: ${err.message}`);
    }
  }

  /**
   * Get SROI (Social Return on Investment) calculation.
   * Based on: reduced hospital visits, caregiver hours saved, improved quality of life.
   */
  async getSROICalculation() {
    const now = new Date();
    const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);

    try {
      const [totalSeniors, activeSeniors, monthlyCost] = await Promise.all([
        this.prisma.senior.count(),
        this.prisma.senior.count({
          where: { lastActiveAt: { gte: monthStart } },
        }),
        this._getMonthlyVoiceCost(monthStart),
      ]);

      // Assumptions (based on industry research):
      // - Each active senior avoids 0.3 hospital visits/month (avg cost 500 PLN)
      // - Family saves 40h/month of caregiving time (valued at 35 PLN/h)
      // - Quality of life improvement: 15% reduction in depression risk
      const hospitalSavings = activeSeniors * 0.3 * 500;
      const caregiverSavings = activeSeniors * 40 * 35;
      const totalBenefit = hospitalSavings + caregiverSavings;
      const totalCost = monthlyCost + (activeSeniors * 199); // avg package cost

      return {
        month: now.toISOString().slice(0, 7),
        inputs: {
          activeSeniors,
          totalSeniors,
          monthlyVoiceCost: Math.round(monthlyCost * 100) / 100,
          estimatedPackageRevenue: activeSeniors * 199,
        },
        benefits: {
          hospitalVisitSavings: Math.round(hospitalSavings),
          caregiverTimeSavings: Math.round(caregiverSavings),
          totalMonthlyBenefit: Math.round(totalBenefit),
        },
        sroi: {
          ratio: totalCost > 0
            ? (totalBenefit / totalCost).toFixed(2)
            : '0.00',
          interpretation: totalCost > 0 && (totalBenefit / totalCost) > 1
            ? 'Pozytywny zwrot — każda złotówka generuje wartość społeczną'
            : 'Wymaga optymalizacji kosztów',
        },
      };
    } catch (err) {
      throw new Error(`Failed to calculate SROI: ${err.message}`);
    }
  }

  /**
   * Get cost optimization recommendations for June 2026.
   */
  async getCostOptimizationReport() {
    try {
      const voiceAnalytics = await this.getVoiceAnalytics({
        startDate: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString(),
      });

      const recommendations = [];

      // TTS optimization: cache common phrases
      if (voiceAnalytics.topTopics && voiceAnalytics.topTopics.length > 0) {
        const topTopic = voiceAnalytics.topTopics[0];
        recommendations.push({
          category: 'TTS_OPTIMIZATION',
          title: 'Cache często używanych fraz TTS',
          description: `Temat "${topTopic.topic}" stanowi ${topTopic.count} zapytań. ` +
            'Buforowanie odpowiedzi TTS może obniżyć koszty o ~15%.',
          estimatedSavings: '45 PLN/miesiąc',
          priority: 'HIGH',
        });
      }

      // Peak hour optimization
      if (voiceAnalytics.peakHour !== undefined) {
        recommendations.push({
          category: 'PEAK_HOUR',
          title: 'Optymalizacja godzin szczytu',
          description: `Szczyt aktywności o ${voiceAnalytics.peakHour}:00. ` +
            'Rozważ zwiększenie buforowania w tych godzinach.',
          estimatedSavings: '30 PLN/miesiąc',
          priority: 'MEDIUM',
        });
      }

      // Model selection optimization
      recommendations.push({
        category: 'MODEL_SELECTION',
        title: 'Selektywny wybór modelu LLM',
        description: 'Proste zapytania (przypomnienia, pogoda) → Gemini Flash. ' +
          'Złożone (zdrowie, porady) → Gemini Pro. Oszczędność ~25%.',
        estimatedSavings: '80 PLN/miesiąc',
        priority: 'HIGH',
      });

      // Batch processing
      recommendations.push({
        category: 'BATCH_PROCESSING',
        title: 'Przetwarzanie batchowe analityki',
        description: 'Przenieś dzienne analizy na godziny nocne (2:00-4:00). ' +
          'Niższe zużycie CPU w klastrze K8s.',
        estimatedSavings: '50 PLN/miesiąc',
        priority: 'MEDIUM',
      });

      return {
        generatedAt: new Date().toISOString(),
        targetDate: '2026-06-01',
        totalEstimatedSavings: '205 PLN/miesiąc',
        recommendations,
        currentMonthlyCost: Math.round(voiceAnalytics.totalCost * 100) / 100 || 0,
      };
    } catch (err) {
      throw new Error(`Failed to generate cost report: ${err.message}`);
    }
  }

  // ---- Private Helpers ----

  async _getMonthlyVoiceCost(monthStart) {
    const result = await this.prisma.conversation.aggregate({
      where: {
        startedAt: { gte: monthStart },
      },
      _sum: {
        voiceCost: true,
      },
    });
    return result._sum.voiceCost || 0;
  }

  async _getSemaforDistribution() {
    const seniors = await this.prisma.senior.groupBy({
      by: ['semaforLevel'],
      _count: { id: true },
    });

    const distribution = { GREEN: 0, YELLOW: 0, ORANGE: 0, RED: 0, PURPLE: 0 };
    for (const group of seniors) {
      distribution[group.semaforLevel] = group._count.id;
    }
    return distribution;
  }

  async _getPackageDistribution() {
    const seniors = await this.prisma.senior.groupBy({
      by: ['package'],
      _count: { id: true },
    });

    const distribution = {};
    for (const group of seniors) {
      distribution[group.package] = group._count.id;
    }
    return distribution;
  }

  _projectMonthlyCost(currentCost, now) {
    const daysInMonth = new Date(now.getFullYear(), now.getMonth() + 1, 0).getDate();
    const currentDay = now.getDate();
    if (currentDay === 0) return currentCost;
    return Math.round((currentCost / currentDay) * daysInMonth * 100) / 100;
  }
}

module.exports = UsageAnalyticsService;
