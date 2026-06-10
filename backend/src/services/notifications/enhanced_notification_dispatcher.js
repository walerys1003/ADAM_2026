/**
 * SilverTech Agent Adam — Enhanced Notification Dispatcher
 * Multi-channel notification delivery with priority queuing:
 * - Push notifications (FCM/APNs)
 * - SMS (Twilio) for critical alerts
 * - Email (SendGrid) for weekly reports
 * - In-app notifications for family dashboard
 * - Semafor-based escalation routing
 * - Rate limiting and deduplication
 * - Delivery status tracking and retry logic
 */

const EventEmitter = require('events');

// --- Notification Priority Levels ---
const PRIORITY = {
  CRITICAL: 1,  // Immediate — all channels, no delay
  HIGH: 2,      // Within 1 minute — push + in-app
  MEDIUM: 3,    // Within 5 minutes — push
  LOW: 4,       // Within 30 minutes — in-app only
  DIGEST: 5,    // Daily/weekly digest — email
};

// --- Notification Channel Types ---
const CHANNEL = {
  PUSH: 'push',
  SMS: 'sms',
  EMAIL: 'email',
  IN_APP: 'in_app',
  VOICE: 'voice',
};

// --- Semafor-to-Channel Routing ---
const SEMAFOR_ROUTING = {
  GREEN: {
    channels: [CHANNEL.IN_APP],
    priority: PRIORITY.LOW,
    throttle: 60, // max per hour
  },
  YELLOW: {
    channels: [CHANNEL.IN_APP, CHANNEL.PUSH],
    priority: PRIORITY.MEDIUM,
    throttle: 30,
  },
  ORANGE: {
    channels: [CHANNEL.IN_APP, CHANNEL.PUSH],
    priority: PRIORITY.HIGH,
    throttle: 15,
  },
  RED: {
    channels: [CHANNEL.IN_APP, CHANNEL.PUSH, CHANNEL.SMS],
    priority: PRIORITY.CRITICAL,
    throttle: 0, // no throttle for critical
  },
  PURPLE: {
    channels: [CHANNEL.IN_APP, CHANNEL.PUSH, CHANNEL.SMS, CHANNEL.VOICE],
    priority: PRIORITY.CRITICAL,
    throttle: 0,
  },
};

class EnhancedNotificationDispatcher extends EventEmitter {
  constructor(options = {}) {
    super();
    this.deliveryLog = [];
    this.dedupCache = new Map();
    this.rateLimiters = new Map();
    this.retryQueue = [];
    this.pushService = options.pushService || null;

    // Dedup TTL: 5 minutes
    this.dedupTtl = options.dedupTtl || 300_000;

    // Start retry processor
    this._retryInterval = setInterval(() => this._processRetryQueue(), 30_000);
  }

  /**
   * Dispatch a notification through appropriate channels based on:
   * - Semafor level (determines channels and priority)
   * - Notification type (health alert, medication, system, etc.)
   * - Recipient preferences (family members' contact methods)
   */
  async dispatch(notification) {
    const {
      id = `notif_${Date.now()}`,
      type,
      seniorId,
      seniorName,
      semaforLevel = 'GREEN',
      title,
      body,
      data = {},
      recipients = [],
      channels: overrideChannels,
    } = notification;

    // Deduplication check
    const dedupKey = `${type}:${seniorId}:${title}`;
    if (this.dedupCache.has(dedupKey)) {
      this.emit('notification:deduped', { id, dedupKey });
      return { status: 'deduped', id };
    }
    this.dedupCache.set(dedupKey, Date.now());
    setTimeout(() => this.dedupCache.delete(dedupKey), this.dedupTtl);

    // Determine routing
    const routing = SEMAFOR_ROUTING[semaforLevel] || SEMAFOR_ROUTING.GREEN;
    const channels = overrideChannels || routing.channels;

    // Rate limit check
    const rateLimitKey = `rate:${seniorId}:${type}`;
    if (routing.throttle > 0 && this._isRateLimited(rateLimitKey, routing.throttle)) {
      this.emit('notification:rate_limited', { id, rateLimitKey });
      return { status: 'rate_limited', id };
    }

    // Build notification packet
    const packet = {
      id,
      type,
      seniorId,
      seniorName,
      semaforLevel,
      priority: routing.priority,
      title,
      body,
      data: {
        ...data,
        semafor: semaforLevel,
        timestamp: new Date().toISOString(),
      },
      recipients,
      channels,
      createdAt: new Date(),
    };

    // Dispatch to each channel
    const results = await Promise.allSettled(
      channels.map((channel) => this._sendToChannel(channel, packet)),
    );

    // Log delivery
    const delivery = {
      id,
      type,
      seniorId,
      channels,
      results: results.map((r, i) => ({
        channel: channels[i],
        status: r.status === 'fulfilled' ? 'sent' : 'failed',
        error: r.status === 'rejected' ? r.reason?.message : null,
      })),
      timestamp: new Date(),
    };

    this.deliveryLog.push(delivery);
    this.emit('notification:dispatched', delivery);

    // Enqueue failed for retry
    const failed = results
      .map((r, i) => ({ channel: channels[i], result: r }))
      .filter((r) => r.result.status === 'rejected');

    if (failed.length > 0) {
      this.retryQueue.push({
        packet,
        failedChannels: failed.map((f) => f.channel),
        attempts: 1,
        nextRetry: Date.now() + 60_000,
      });
    }

    return {
      status: failed.length === channels.length ? 'failed' : 'partial',
      id,
      delivery,
    };
  }

  /**
   * Send notification through a specific channel
   */
  async _sendToChannel(channel, packet) {
    switch (channel) {
      case CHANNEL.PUSH:
        return this._sendPush(packet);
      case CHANNEL.SMS:
        return this._sendSms(packet);
      case CHANNEL.EMAIL:
        return this._sendEmail(packet);
      case CHANNEL.IN_APP:
        return this._sendInApp(packet);
      case CHANNEL.VOICE:
        return this._sendVoice(packet);
      default:
        throw new Error(`Unknown channel: ${channel}`);
    }
  }

  async _sendPush(packet) {
    if (!this.pushService) {
      // Simulated push delivery
      this.emit('push:sent', {
        id: packet.id,
        title: packet.title,
        body: packet.body,
        tokens: packet.recipients.length,
      });
      return { channel: CHANNEL.PUSH, status: 'sent', provider: 'fcm_simulated' };
    }

    return this.pushService.send({
      tokens: packet.recipients.map((r) => r.pushToken).filter(Boolean),
      title: packet.title,
      body: packet.body,
      data: packet.data,
      priority: packet.priority <= PRIORITY.HIGH ? 'high' : 'normal',
    });
  }

  async _sendSms(packet) {
    // Simulated SMS via Twilio
    const phoneNumbers = packet.recipients
      .map((r) => r.phone)
      .filter(Boolean);

    if (phoneNumbers.length === 0) {
      return { channel: CHANNEL.SMS, status: 'skipped', reason: 'no_phone_numbers' };
    }

    this.emit('sms:sent', {
      id: packet.id,
      to: phoneNumbers,
      body: `[Adam Alert - ${packet.semaforLevel}] ${packet.title}: ${packet.body}`,
    });

    return {
      channel: CHANNEL.SMS,
      status: 'sent',
      provider: 'twilio_simulated',
      recipients: phoneNumbers.length,
    };
  }

  async _sendEmail(packet) {
    const emails = packet.recipients
      .map((r) => r.email)
      .filter(Boolean);

    if (emails.length === 0) {
      return { channel: CHANNEL.EMAIL, status: 'skipped', reason: 'no_emails' };
    }

    this.emit('email:sent', {
      id: packet.id,
      to: emails,
      subject: `[Agent Adam] ${packet.title}`,
      html: this._buildEmailHtml(packet),
    });

    return {
      channel: CHANNEL.EMAIL,
      status: 'sent',
      provider: 'sendgrid_simulated',
      recipients: emails.length,
    };
  }

  async _sendInApp(packet) {
    // In-app notification — stored for family dashboard
    const inAppNotification = {
      id: packet.id,
      type: packet.type,
      seniorId: packet.seniorId,
      seniorName: packet.seniorName,
      title: packet.title,
      body: packet.body,
      data: packet.data,
      semaforLevel: packet.semaforLevel,
      read: false,
      createdAt: new Date(),
    };

    this.emit('in_app:created', inAppNotification);
    return { channel: CHANNEL.IN_APP, status: 'sent' };
  }

  async _sendVoice(packet) {
    // Emergency voice call via Twilio
    const phoneNumbers = packet.recipients
      .map((r) => r.phone)
      .filter(Boolean);

    if (phoneNumbers.length === 0) {
      return { channel: CHANNEL.VOICE, status: 'skipped', reason: 'no_phone_numbers' };
    }

    this.emit('voice:call_initiated', {
      id: packet.id,
      to: phoneNumbers,
      message: `Uwaga! ${packet.title}. ${packet.body}`,
    });

    return {
      channel: CHANNEL.VOICE,
      status: 'sent',
      provider: 'twilio_voice_simulated',
    };
  }

  // ─── Retry Queue ────────────────────────────────────────

  async _processRetryQueue() {
    const now = Date.now();
    const toRetry = [];

    for (let i = this.retryQueue.length - 1; i >= 0; i--) {
      const item = this.retryQueue[i];
      if (item.nextRetry <= now) {
        toRetry.push(item);
        this.retryQueue.splice(i, 1);
      }
    }

    for (const item of toRetry) {
      if (item.attempts >= 3) {
        this.emit('notification:permanent_failure', {
          id: item.packet.id,
          attempts: item.attempts,
          channels: item.failedChannels,
        });
        continue;
      }

      // Retry with backoff
      const results = await Promise.allSettled(
        item.failedChannels.map((channel) => this._sendToChannel(channel, item.packet)),
      );

      const stillFailed = results
        .map((r, i) => ({ channel: item.failedChannels[i], result: r }))
        .filter((r) => r.result.status === 'rejected');

      if (stillFailed.length > 0) {
        // Exponential backoff: 60s, 120s, 240s
        this.retryQueue.push({
          packet: item.packet,
          failedChannels: stillFailed.map((f) => f.channel),
          attempts: item.attempts + 1,
          nextRetry: Date.now() + Math.pow(2, item.attempts) * 60_000,
        });
      }
    }
  }

  // ─── Rate Limiting ──────────────────────────────────────

  _isRateLimited(key, maxPerHour) {
    const now = Date.now();
    const window = 3600_000; // 1 hour

    if (!this.rateLimiters.has(key)) {
      this.rateLimiters.set(key, []);
    }

    const timestamps = this.rateLimiters.get(key);
    // Remove old entries
    const recent = timestamps.filter((t) => now - t < window);

    if (recent.length >= maxPerHour) {
      return true;
    }

    recent.push(now);
    this.rateLimiters.set(key, recent);
    return false;
  }

  // ─── Email Templates ────────────────────────────────────

  _buildEmailHtml(packet) {
    const borderColor = this._semaforColor(packet.semaforLevel);

    return `
    <div style="max-width:600px;margin:0 auto;font-family:Arial,sans-serif">
      <div style="background:${borderColor};padding:20px;border-radius:12px 12px 0 0">
        <h2 style="color:#fff;margin:0">Agent Adam</h2>
        <p style="color:#fff;opacity:0.9">Powiadomienie o statusie: <strong>${packet.semaforLevel}</strong></p>
      </div>
      <div style="border:2px solid ${borderColor};border-top:0;padding:24px;border-radius:0 0 12px 12px">
        <h3 style="color:#1a237e;margin-top:0">${packet.title}</h3>
        <p style="color:#333;font-size:16px;line-height:1.6">${packet.body}</p>
        <hr style="border-color:#e0e0e0;margin:24px 0">
        <p style="color:#666;font-size:14px">
          Senior: <strong>${packet.seniorName || '—'}</strong><br>
          Status Semafor: <span style="color:${borderColor};font-weight:bold">${packet.semaforLevel}</span><br>
          ${packet.data.timestamp ? `Czas: ${packet.data.timestamp}<br>` : ''}
        </p>
        <a href="https://app.silvertech.ai/family" style="display:inline-block;background:${borderColor};color:#fff;padding:12px 28px;border-radius:8px;text-decoration:none;font-weight:bold;margin-top:8px">
          Otwórz panel rodzinny
        </a>
      </div>
    </div>`;
  }

  _semaforColor(level) {
    const colors = {
      GREEN: '#4CAF50',
      YELLOW: '#FFC107',
      ORANGE: '#FF9800',
      RED: '#F44336',
      PURPLE: '#9C27B0',
    };
    return colors[level] || '#757575';
  }

  // ─── Convenience Methods ────────────────────────────────

  async notifyHealthAlert({ seniorId, seniorName, semaforLevel, title, body, recipients }) {
    return this.dispatch({
      type: 'health_alert',
      seniorId,
      seniorName,
      semaforLevel,
      title: title || 'Alert zdrowotny',
      body: body || 'Wykryto nieprawidłowości w danych zdrowotnych.',
      recipients,
    });
  }

  async notifyMedicationMissed({ seniorId, seniorName, medicationName, recipients }) {
    return this.dispatch({
      type: 'medication_missed',
      seniorId,
      seniorName,
      semaforLevel: 'YELLOW',
      title: 'Pominięta dawka leku',
      body: `${seniorName} nie przyjął/a leku: ${medicationName}.`,
      recipients,
    });
  }

  async notifyEmergency({ seniorId, seniorName, reason, recipients, location }) {
    return this.dispatch({
      type: 'emergency',
      seniorId,
      seniorName,
      semaforLevel: 'RED',
      title: 'ALARM — Sygnał SOS!',
      body: `${seniorName} uruchomił/a SOS. Powód: ${reason}.${location ? ` Lokalizacja: ${location}` : ''}`,
      recipients,
      data: { location, emergencyType: 'sos' },
    });
  }

  async notifyWeeklyReport({ seniorId, seniorName, reportData, recipients }) {
    return this.dispatch({
      type: 'weekly_report',
      seniorId,
      seniorName,
      semaforLevel: reportData.semaforLevel || 'GREEN',
      priority: PRIORITY.DIGEST,
      title: `Raport tygodniowy — ${seniorName}`,
      body: `Dostępny jest nowy raport tygodniowy dla ${seniorName}.`,
      recipients,
      data: reportData,
      channels: [CHANNEL.EMAIL, CHANNEL.IN_APP],
    });
  }

  async notifyLowMood({ seniorId, seniorName, moodScore, recipients }) {
    return this.dispatch({
      type: 'low_mood_alert',
      seniorId,
      seniorName,
      semaforLevel: moodScore <= 2 ? 'ORANGE' : 'YELLOW',
      title: 'Niski nastrój',
      body: `${seniorName} zgłosił/a niski nastrój (${moodScore}/5). Warto zadzwonić.`,
      recipients,
    });
  }

  // ─── Stats ──────────────────────────────────────────────

  getStats() {
    const last24h = this.deliveryLog.filter(
      (d) => Date.now() - d.timestamp.getTime() < 86_400_000,
    );

    return {
      total: this.deliveryLog.length,
      last24h: last24h.length,
      byType: this._groupBy(last24h, 'type'),
      retryQueue: this.retryQueue.length,
      successes: last24h.filter(
        (d) => d.results.every((r) => r.status === 'sent'),
      ).length,
      failures: last24h.filter(
        (d) => d.results.some((r) => r.status === 'failed'),
      ).length,
    };
  }

  _groupBy(array, key) {
    return array.reduce((acc, item) => {
      const val = item[key];
      acc[val] = (acc[val] || 0) + 1;
      return acc;
    }, {});
  }

  // ─── Cleanup ────────────────────────────────────────────

  destroy() {
    if (this._retryInterval) clearInterval(this._retryInterval);
    this.removeAllListeners();
    this.deliveryLog = [];
    this.dedupCache.clear();
    this.rateLimiters.clear();
    this.retryQueue = [];
  }
}

module.exports = {
  EnhancedNotificationDispatcher,
  PRIORITY,
  CHANNEL,
  SEMAFOR_ROUTING,
};
