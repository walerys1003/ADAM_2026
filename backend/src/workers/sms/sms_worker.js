const { Worker } = require('bullmq');
const twilio = require('twilio');
const { redisConnection } = require('../../config/redis');

// ─── Twilio client ─────────────────────────────────────────────────────
const twilioClient = twilio(
  process.env.TWILIO_ACCOUNT_SID || '',
  process.env.TWILIO_AUTH_TOKEN || ''
);

const TWILIO_FROM = process.env.TWILIO_PHONE_NUMBER || '+48123456789';

// ─── SMS templates (short, accessible — Polish) ────────────────────────
const smsTemplates = {
  medication_reminder: (data) =>
    `[Agent Adam] ⏰ ${data.seniorName}, czas na ${data.medicationName}! ` +
    `Dawka: ${data.dosage}. Pamiętaj o regularnym przyjmowaniu leków. 🫶`,

  appointment_reminder: (data) =>
    `[Agent Adam] 📅 Jutro o ${data.time} masz wizytę: ${data.doctorName} ` +
    `(${data.clinicName}). Adres: ${data.address}.`,

  sos_alert: (data) =>
    `[Agent Adam] 🚨 ALERT SOS od ${data.seniorName}! ` +
    `Lokalizacja: ${data.location || 'nieznana'}. ` +
    `Prosimy o natychmiastowy kontakt! Status: ${data.semaforLabel}`,

  wellness_check: (data) =>
    `[Agent Adam] 👋 ${data.seniorName}, jak się dziś czujesz? ` +
    `Odpowiedz: 1-Bardzo dobrze, 2-Dobrze, 3-Średnio, 4-Źle, 5-Bardzo źle.`,

  daily_motivation: (data) =>
    `[Agent Adam] 🌟 ${data.message}. ` +
    `Pamiętaj, że jesteś ważny/a! Miłego dnia! 🫶`,

  emergency_contact: (data) =>
    `[Agent Adam] 🚨 AWARYJNY ALERT! ` +
    `${data.seniorName} (${data.seniorPhone}) wymaga pomocy! ` +
    `Powód: ${data.reason}. Lokalizacja: ${data.location || 'GPS nieaktywne'}.`,
};

// ─── Worker ────────────────────────────────────────────────────────────
const smsWorker = new Worker(
  'sms',
  async (job) => {
    const { type, recipient, data } = job.data;

    if (!smsTemplates[type]) {
      throw new Error(`Unknown SMS template: ${type}`);
    }

    const body = smsTemplates[type](data);

    // SMS length check (160 chars GSM-7, 70 UCS-2)
    if (body.length > 1600) {
      console.warn(`[SMSWorker] ⚠️ Long message (${body.length} chars), may be split`);
    }

    try {
      const message = await twilioClient.messages.create({
        body,
        from: TWILIO_FROM,
        to: recipient,
        // statusCallback for delivery tracking
        statusCallback: `${process.env.API_BASE_URL}/webhooks/sms/status`,
      });

      // Cost tracking: ~$0.0075/SMS (Twilio Poland)
      const estimatedCost = body.length > 160 ? 0.015 : 0.0075;

      return {
        success: true,
        messageSid: message.sid,
        recipient,
        type,
        bodyLength: body.length,
        estimatedCost: `$${estimatedCost.toFixed(4)}`,
        sentAt: new Date().toISOString(),
      };
    } catch (error) {
      // Twilio error codes: https://www.twilio.com/docs/api/errors
      if (error.code === 21211) {
        // Invalid phone number — don't retry
        console.error(`[SMSWorker] ❌ Invalid number: ${recipient}`);
        return { success: false, error: 'INVALID_NUMBER', recipient };
      }

      if (error.code === 21610) {
        // STOP message received — don't retry
        console.error(`[SMSWorker] ❌ Recipient opted out: ${recipient}`);
        return { success: false, error: 'OPTED_OUT', recipient };
      }

      // Other errors — throw for retry
      throw new Error(`SMS send failed [${error.code}]: ${error.message}`);
    }
  },
  {
    connection: redisConnection,
    concurrency: 3, // Twilio recommends max 3 concurrent for standard accounts
    limiter: { max: 10, duration: 1000 }, // 10 SMS/sec
    settings: {
      backoffStrategy: (attemptsMade) => Math.min(attemptsMade * 3000, 60000),
      attempts: 3, // Max 3 retries for SMS
    },
  }
);

// ─── Event handlers ────────────────────────────────────────────────────
smsWorker.on('completed', (job) => {
  const { result } = job;
  if (result?.success) {
    console.log(`[SMSWorker] ✅ Job ${job.id} sent: ${job.data.type} → ${job.data.recipient} (${result.estimatedCost})`);
  } else {
    console.log(`[SMSWorker] ⚠️ Job ${job.id} skipped: ${result?.error} → ${job.data.recipient}`);
  }
});

smsWorker.on('failed', (job, err) => {
  console.error(`[SMSWorker] ❌ Job ${job?.id} failed after retries: ${err.message}`);
});

smsWorker.on('error', (err) => {
  console.error(`[SMSWorker] 🔥 Worker error: ${err.message}`);
});

// ─── Helper: Send SMS via queue ────────────────────────────────────────
async function sendSMS(type, recipient, data) {
  const { Queue } = require('bullmq');
  const smsQueue = new Queue('sms', { connection: redisConnection });

  const job = await smsQueue.add(type, { type, recipient, data }, {
    priority: type.includes('emergency') || type.includes('sos') ? 1 : 3,
    attempts: type.includes('sos') ? 5 : 3,
    backoff: { type: 'exponential', delay: 2000 },
  });

  await smsQueue.close();
  return job.id;
}

module.exports = { smsWorker, smsTemplates, sendSMS };
