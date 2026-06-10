'use strict';

/**
 * Push Notification Service for Agent Adam.
 *
 * Sends push notifications to:
 * - Senior's mobile device (medication reminders, voice call prompts)
 * - Family members' devices (health alerts, missed meds, weekly reports)
 * - Admin devices (system alerts, cost overruns)
 *
 * Supports FCM (Firebase Cloud Messaging) for Android.
 * In production, integrates with firebase-admin SDK.
 */

class PushNotificationService {
  constructor(prisma, redis) {
    this.prisma = prisma;
    this.redis = redis;
    this.defaultIcon = 'notification_icon';
    this.defaultSound = 'default';
  }

  /**
   * Send medication reminder to a senior.
   */
  async sendMedicationReminder(seniorId, medication) {
    const tokens = await this._getDeviceTokens(seniorId);

    if (tokens.length === 0) {
      return { sent: false, reason: 'no_device_tokens' };
    }

    const message = {
      title: '⏰ Czas na lek!',
      body: `${medication.name} — ${medication.dosage || 'zgodnie z zaleceniem'}`,
      data: {
        type: 'MEDICATION_REMINDER',
        medicationId: medication.id,
        seniorId,
        timestamp: new Date().toISOString(),
      },
      android: {
        channelId: 'medication_reminders',
        priority: 'high',
        notification: {
          sound: this.defaultSound,
          icon: this.defaultIcon,
          color: '#059669',
        },
      },
    };

    return this._sendToTokens(tokens, message);
  }

  /**
   * Send medication missed alert to family members.
   */
  async sendMissedMedicationAlert(seniorId, medication, familyIds) {
    const allTokens = [];

    for (const familyId of familyIds) {
      const tokens = await this._getDeviceTokens(familyId);
      allTokens.push(...tokens);
    }

    if (allTokens.length === 0) {
      return { sent: false, reason: 'no_family_tokens' };
    }

    // Deduplicate tokens
    const uniqueTokens = [...new Set(allTokens)];

    const message = {
      title: '⚠️ Pominięta dawka leku',
      body: `${medication.name} nie został przyjęty o czasie. Skontaktuj się z seniorem.`,
      data: {
        type: 'MISSED_MEDICATION',
        medicationId: medication.id,
        seniorId,
        timestamp: new Date().toISOString(),
      },
      android: {
        channelId: 'health_alerts',
        priority: 'high',
        notification: {
          sound: this.defaultSound,
          icon: this.defaultIcon,
          color: '#DC2626',
        },
      },
    };

    return this._sendToTokens(uniqueTokens, message);
  }

  /**
   * Send health alert (semafor elevation) to family.
   */
  async sendHealthAlert(seniorId, semaforLevel, details, familyIds) {
    const allTokens = [];

    for (const familyId of familyIds) {
      const tokens = await this._getDeviceTokens(familyId);
      allTokens.push(...tokens);
    }

    const uniqueTokens = [...new Set(allTokens)];

    const semaforMessages = {
      YELLOW: {
        title: '🟡 Uwaga — zmiana parametrów',
        priority: 'default',
      },
      ORANGE: {
        title: '🟠 Alert — niepokojące parametry',
        priority: 'high',
      },
      RED: {
        title: '🔴 PILNE — krytyczne parametry zdrowotne!',
        priority: 'high',
      },
      PURPLE: {
        title: '🟣 ALARM — zagrożenie życia!',
        priority: 'high',
      },
    };

    const config = semaforMessages[semaforLevel] || semaforMessages.YELLOW;

    const message = {
      title: config.title,
      body: details || 'Sprawdź panel rodzinny, aby zobaczyć szczegóły.',
      data: {
        type: 'HEALTH_ALERT',
        semaforLevel,
        seniorId,
        timestamp: new Date().toISOString(),
      },
      android: {
        channelId: 'health_alerts',
        priority: config.priority,
        notification: {
          sound: semaforLevel === 'RED' || semaforLevel === 'PURPLE'
            ? 'emergency_alert'
            : this.defaultSound,
          icon: this.defaultIcon,
          color: semaforLevel === 'RED' || semaforLevel === 'PURPLE'
            ? '#DC2626'
            : '#D97706',
        },
      },
    };

    return this._sendToTokens(uniqueTokens, message);
  }

  /**
   * Send weekly report notification to family.
   */
  async sendWeeklyReportReady(familyId, seniorId, weekEnding) {
    const tokens = await this._getDeviceTokens(familyId);

    if (tokens.length === 0) {
      return { sent: false, reason: 'no_tokens' };
    }

    const message = {
      title: '📊 Raport tygodniowy gotowy',
      body: `Raport za tydzień kończący się ${weekEnding} jest już dostępny.`,
      data: {
        type: 'WEEKLY_REPORT',
        seniorId,
        weekEnding,
        timestamp: new Date().toISOString(),
      },
      android: {
        channelId: 'reports',
        priority: 'default',
        notification: {
          sound: this.defaultSound,
          icon: this.defaultIcon,
          color: '#6366F1',
        },
      },
    };

    return this._sendToTokens(tokens, message);
  }

  /**
   * Send system alert to admin devices.
   */
  async sendAdminAlert(title, body, priority = 'default') {
    // In production: fetch admin device tokens
    const adminTokens = []; // placeholder

    if (adminTokens.length === 0) {
      // Log to console for development
      console.log(`[ADMIN ALERT] ${title}: ${body}`);
      return { sent: false, reason: 'no_admin_tokens', logged: true };
    }

    const message = {
      title: `[ADMIN] ${title}`,
      body,
      data: {
        type: 'ADMIN_ALERT',
        priority,
        timestamp: new Date().toISOString(),
      },
      android: {
        channelId: 'admin_alerts',
        priority,
        notification: {
          sound: priority === 'high' ? 'emergency_alert' : this.defaultSound,
          icon: this.defaultIcon,
        },
      },
    };

    return this._sendToTokens(adminTokens, message);
  }

  /**
   * Send a notification to a specific topic (seniors, family, all).
   */
  async sendToTopic(topic, title, body, data = {}) {
    try {
      // In production: use Firebase Admin SDK
      // const response = await admin.messaging().send({
      //   topic,
      //   notification: { title, body },
      //   data,
      // });

      // For development, log it
      console.log(`[PUSH TOPIC ${topic}] ${title}: ${body}`);

      // Track in analytics
      await this.redis?.hincrby('analytics:push_sent', topic, 1);

      return { sent: true, topic };
    } catch (err) {
      console.error(`Failed to send to topic ${topic}:`, err.message);
      return { sent: false, error: err.message };
    }
  }

  // ---- Private Helpers ----

  /**
   * Get FCM device tokens for a user.
   * In production: fetch from database.
   */
  async _getDeviceTokens(userId) {
    try {
      const devices = await this.prisma.deviceToken.findMany({
        where: {
          userId,
          isActive: true,
        },
        select: {
          token: true,
        },
      });

      return devices.map((d) => d.token);
    } catch {
      // During development when table might not exist
      return [];
    }
  }

  /**
   * Send a message to multiple device tokens.
   * In production: use Firebase Admin SDK multicast.
   */
  async _sendToTokens(tokens, message) {
    if (tokens.length === 0) return { sent: false, reason: 'no_tokens' };

    try {
      // In production:
      // const response = await admin.messaging().sendEachForMulticast({
      //   tokens,
      //   notification: {
      //     title: message.title,
      //     body: message.body,
      //   },
      //   data: message.data,
      //   android: message.android,
      // });

      // For development, log:
      console.log(`[PUSH] Sending to ${tokens.length} devices: ${message.title}`);

      // Track metrics
      await this.redis?.hincrby('analytics:push_sent', 'total', tokens.length);

      return {
        sent: true,
        tokenCount: tokens.length,
        message: message.title,
      };
    } catch (err) {
      console.error('Push notification failed:', err.message);
      return { sent: false, error: err.message };
    }
  }
}

module.exports = PushNotificationService;
