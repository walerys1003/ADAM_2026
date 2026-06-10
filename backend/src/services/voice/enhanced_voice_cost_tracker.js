'use strict';

/**
 * Enhanced Voice Cost Tracker — June 2026
 * Real-time per-conversation cost tracking with budget alerts
 * Multi-provider: Twilio PSTN + Deepgram STT + Gemini LLM + OpenAI TTS
 */
class EnhancedVoiceCostTracker {
  constructor() {
    // Per-minute pricing (June 2026)
    this.rates = {
      telecom: {
        provider: 'Twilio',
        inboundPL: 0.0036,
        outboundPL: 0.012,
        inboundEU: 0.006,
        outboundEU: 0.018,
      },
      stt: {
        provider: 'Deepgram Nova-3',
        perMinute: 0.0048,
      },
      llm: {
        provider: 'Gemini 3.2 Flash Live',
        per1kInputTokens: 0.000075,
        per1kOutputTokens: 0.00030,
        avgInputTokensPerConversation: 800,
        avgOutputTokensPerConversation: 500,
      },
      tts: {
        provider: 'OpenAI TTS-1',
        per1kChars: 0.015,
        avgCharsPerResponse: 300,
      },
    };

    // Budget thresholds (monthly per senior)
    this.budgetThresholds = {
      KONTAKT: { maxMonthly: 12.0, warnAt: 9.0 },
      ZDROWIE: { maxMonthly: 18.0, warnAt: 14.0 },
      AKTYWNY: { maxMonthly: 25.0, warnAt: 20.0 },
    };

    // In-memory tracking
    this.conversations = new Map();
    this.monthlyTotals = new Map(); // seniorId -> { month: total }
    this.budgetAlerts = [];
  }

  /**
   * Start tracking a new conversation
   */
  startConversation({ conversationId, seniorId, package: pkg, phoneNumber, callDirection }) {
    const conversation = {
      conversationId,
      seniorId,
      package: pkg || 'KONTAKT',
      phoneNumber,
      callDirection: callDirection || 'outbound',
      startTime: Date.now(),
      costs: {
        telecom: 0,
        stt: 0,
        llm: 0,
        tts: 0,
        total: 0,
      },
      metrics: {
        durationSeconds: 0,
        sttSeconds: 0,
        llmInputTokens: 0,
        llmOutputTokens: 0,
        ttsChars: 0,
      },
      completed: false,
    };

    this.conversations.set(conversationId, conversation);
    return conversation;
  }

  /**
   * Track STT usage (called during conversation)
   */
  trackSTT(conversationId, audioSeconds) {
    const conv = this.conversations.get(conversationId);
    if (!conv) return;

    const cost = (audioSeconds / 60) * this.rates.stt.perMinute;
    conv.costs.stt += cost;
    conv.metrics.sttSeconds += audioSeconds;
    this._updateTotal(conv);
  }

  /**
   * Track LLM token usage
   */
  trackLLM(conversationId, { inputTokens, outputTokens }) {
    const conv = this.conversations.get(conversationId);
    if (!conv) return;

    const inputCost = (inputTokens / 1000) * this.rates.llm.per1kInputTokens;
    const outputCost = (outputTokens / 1000) * this.rates.llm.per1kOutputTokens;

    conv.costs.llm += inputCost + outputCost;
    conv.metrics.llmInputTokens += inputTokens;
    conv.metrics.llmOutputTokens += outputTokens;
    this._updateTotal(conv);
  }

  /**
   * Track TTS character usage
   */
  trackTTS(conversationId, charsUsed) {
    const conv = this.conversations.get(conversationId);
    if (!conv) return;

    const cost = (charsUsed / 1000) * this.rates.tts.per1kChars;
    conv.costs.tts += cost;
    conv.metrics.ttsChars += charsUsed;
    this._updateTotal(conv);
  }

  /**
   * Complete a conversation and finalize costs
   */
  async completeConversation(conversationId) {
    const conv = this.conversations.get(conversationId);
    if (!conv) return null;

    const durationMs = Date.now() - conv.startTime;
    conv.metrics.durationSeconds = Math.round(durationMs / 1000);

    // Calculate telecom cost
    const minutes = durationMs / 60000;
    const rate = conv.callDirection === 'inbound'
      ? this.rates.telecom.inboundPL
      : this.rates.telecom.outboundPL;
    conv.costs.telecom = minutes * rate;

    this._updateTotal(conv);
    conv.completed = true;

    // Update monthly total
    const month = new Date().toISOString().substring(0, 7); // YYYY-MM
    const key = `${conv.seniorId}:${month}`;
    this.monthlyTotals.set(key, (this.monthlyTotals.get(key) || 0) + conv.costs.total);

    // Check budget
    await this._checkBudget(conv);

    return this._toReport(conv);
  }

  /**
   * Generate cost report for a conversation
   */
  _toReport(conv) {
    return {
      conversationId: conv.conversationId,
      seniorId: conv.seniorId,
      package: conv.package,
      duration: this._formatDuration(conv.metrics.durationSeconds),
      costs: {
        telecom: this._round(conv.costs.telecom),
        stt: this._round(conv.costs.stt),
        llm: this._round(conv.costs.llm),
        tts: this._round(conv.costs.tts),
        total: this._round(conv.costs.total),
      },
      metrics: {
        durationSeconds: conv.metrics.durationSeconds,
        sttMinutes: this._round(conv.metrics.sttSeconds / 60, 1),
        llmTokens: conv.metrics.llmInputTokens + conv.metrics.llmOutputTokens,
        ttsChars: conv.metrics.ttsChars,
      },
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * Get monthly spending for a senior
   */
  getMonthlyTotal(seniorId, month = null) {
    const m = month || new Date().toISOString().substring(0, 7);
    return this.monthlyTotals.get(`${seniorId}:${m}`) || 0;
  }

  /**
   * Get all budget alerts
   */
  getBudgetAlerts() {
    const alerts = [...this.budgetAlerts];
    this.budgetAlerts = [];
    return alerts;
  }

  /**
   * Cost optimization recommendations
   */
  getOptimizationReport() {
    const allConversations = [...this.conversations.values()].filter(c => c.completed);
    if (allConversations.length === 0) return { avgCost: 0, recommendations: [] };

    const avgCost = allConversations.reduce((s, c) => s + c.costs.total, 0) / allConversations.length;

    const recommendations = [];

    if (avgCost > 0.15) {
      recommendations.push({
        type: 'TTL_REDUCTION',
        impact: 'HIGH',
        description: 'Consider reducing average response length by 20% to cut TTS costs.',
        estimatedSavings: this._round(avgCost * 0.08),
      });
    }

    const highSttConvs = allConversations.filter(c => c.metrics.sttSeconds > 600);
    if (highSttConvs.length > allConversations.length * 0.3) {
      recommendations.push({
        type: 'CALL_DURATION',
        impact: 'MEDIUM',
        description: `${highSttConvs.length} conversations exceed 10 minutes. Consider summarizing earlier.`,
        estimatedSavings: this._round(avgCost * 0.05),
      });
    }

    recommendations.push({
      type: 'BATCH_PROCESSING',
      impact: 'LOW',
      description: 'Switch to batched LLM calls for welfare checks to reduce per-call overhead.',
      estimatedSavings: 0.002,
    });

    return { avgCost: this._round(avgCost, 4), recommendations };
  }

  // ── Internal ──
  _updateTotal(conv) {
    conv.costs.total = conv.costs.telecom + conv.costs.stt + conv.costs.llm + conv.costs.tts;
  }

  async _checkBudget(conv) {
    const monthlyTotal = this.getMonthlyTotal(conv.seniorId);
    const threshold = this.budgetThresholds[conv.package] || this.budgetThresholds.KONTAKT;

    if (monthlyTotal >= threshold.warnAt) {
      const alert = {
        seniorId: conv.seniorId,
        package: conv.package,
        monthlyTotal: this._round(monthlyTotal, 2),
        limit: threshold.maxMonthly,
        usagePercent: this._round((monthlyTotal / threshold.maxMonthly) * 100, 1),
        severity: monthlyTotal >= threshold.maxMonthly ? 'CRITICAL' : 'WARNING',
        timestamp: new Date().toISOString(),
      };
      this.budgetAlerts.push(alert);
    }
  }

  _round(val, decimals = 4) {
    const factor = Math.pow(10, decimals);
    return Math.round(val * factor) / factor;
  }

  _formatDuration(seconds) {
    const m = Math.floor(seconds / 60);
    const s = seconds % 60;
    return `${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`;
  }
}

module.exports = new EnhancedVoiceCostTracker();
