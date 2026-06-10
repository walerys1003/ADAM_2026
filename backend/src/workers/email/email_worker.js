const { Worker } = require('bullmq');
const nodemailer = require('nodemailer');
const { redisConnection } = require('../../config/redis');

// ─── Email transporter (Hetzner SMTP or SendGrid fallback) ─────────────
const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST || 'smtp.sendgrid.net',
  port: parseInt(process.env.SMTP_PORT || '587', 10),
  secure: false,
  auth: {
    user: process.env.SMTP_USER || 'apikey',
    pass: process.env.SMTP_PASS || '',
  },
});

// ─── Templates ─────────────────────────────────────────────────────────
const templates = {
  medication_reminder: (data) => ({
    subject: `⏰ Przypomnienie o leku: ${data.medicationName}`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
        <h1 style="color: #1B5E20;">Agent Adam — Przypomnienie o leku</h1>
        <p>Dzień dobry ${data.seniorName},</p>
        <p>To automatyczne przypomnienie o przyjęciu leku:</p>
        <div style="background: #f5f5f5; padding: 16px; border-radius: 8px; margin: 16px 0;">
          <strong>${data.medicationName}</strong><br/>
          Dawka: ${data.dosage}<br/>
          Pora: ${data.timeSlot}
        </div>
        <p>Pamiętaj o regularnym przyjmowaniu leków! 🫶</p>
        <p style="color: #666; font-size: 12px;">
          Wiadomość automatyczna z systemu Agent Adam. Nie odpowiadaj na tego maila.
        </p>
      </div>
    `,
  }),

  weekly_report: (data) => ({
    subject: `📊 Raport tygodniowy — ${data.seniorName}`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
        <h1 style="color: #1B5E20;">Agent Adam — Raport Tygodniowy</h1>
        <p>Dzień dobry,</p>
        <p>Oto podsumowanie aktywności ${data.seniorName} w tym tygodniu:</p>
        <table style="width: 100%; border-collapse: collapse; margin: 16px 0;">
          <tr><td style="padding: 8px; border-bottom: 1px solid #eee;">Kroki</td><td>${data.steps} dziennie (śr.)</td></tr>
          <tr><td style="padding: 8px; border-bottom: 1px solid #eee;">Sen</td><td>${data.sleepHours}h dziennie (śr.)</td></tr>
          <tr><td style="padding: 8px; border-bottom: 1px solid #eee;">Przestrzeganie leków</td><td>${data.adherence}%</td></tr>
          <tr><td style="padding: 8px; border-bottom: 1px solid #eee;">Nastrój</td><td>${data.mood} (dominujący)</td></tr>
          <tr><td style="padding: 8px; border-bottom: 1px solid #eee;">Status</td><td style="color: ${data.semaforColor};">● ${data.semaforLabel}</td></tr>
        </table>
        <p style="color: #666; font-size: 12px;">Raport automatyczny z systemu Agent Adam.</p>
      </div>
    `,
  }),

  alert_notification: (data) => ({
    subject: `🚨 ALERT: ${data.semaforLabel} — ${data.seniorName}`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
        <h1 style="color: ${data.semaforColor};">🚨 ALERT — Agent Adam</h1>
        <p><strong>Status:</strong> ${data.semaforLabel}</p>
        <p><strong>Senior:</strong> ${data.seniorName}</p>
        <p><strong>Powód:</strong> ${data.reason}</p>
        <p><strong>Czas wykrycia:</strong> ${data.detectedAt}</p>
        <div style="background: #fff3e0; padding: 16px; border-radius: 8px; margin: 16px 0;">
          <strong>Szczegóły:</strong><br/>
          ${data.details}
        </div>
        <p>Proszę o pilny kontakt z seniorem.</p>
        <p style="color: #666; font-size: 12px;">Alert automatyczny z systemu Agent Adam.</p>
      </div>
    `,
  }),
};

// ─── Worker ────────────────────────────────────────────────────────────
const emailWorker = new Worker(
  'email',
  async (job) => {
    const { type, recipient, data } = job.data;

    if (!templates[type]) {
      throw new Error(`Unknown email template: ${type}`);
    }

    const template = templates[type](data);

    const mailOptions = {
      from: `"Agent Adam" <${process.env.SMTP_FROM || 'adam@silvertech.pl'}>`,
      to: recipient,
      subject: template.subject,
      html: template.html,
    };

    try {
      const info = await transporter.sendMail(mailOptions);

      return {
        success: true,
        messageId: info.messageId,
        recipient,
        type,
        sentAt: new Date().toISOString(),
      };
    } catch (error) {
      // Retry logic — throw to trigger BullMQ retry
      throw new Error(`Email send failed: ${error.message}`);
    }
  },
  {
    connection: redisConnection,
    concurrency: 5,
    limiter: { max: 50, duration: 1000 }, // 50 emails/sec max
    settings: {
      backoffStrategy: (attemptsMade) => Math.min(attemptsMade * 2000, 30000),
    },
  }
);

// ─── Event handlers ────────────────────────────────────────────────────
emailWorker.on('completed', (job) => {
  console.log(`[EmailWorker] ✅ Job ${job.id} completed: ${job.data.type} → ${job.data.recipient}`);
});

emailWorker.on('failed', (job, err) => {
  console.error(`[EmailWorker] ❌ Job ${job?.id} failed: ${err.message}`);
});

emailWorker.on('error', (err) => {
  console.error(`[EmailWorker] 🔥 Worker error: ${err.message}`);
});

module.exports = { emailWorker, templates };
