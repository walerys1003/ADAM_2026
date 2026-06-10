/**
 * SilverTech Agent Adam — Voice Call Routes
 * Twilio integration, Deepgram STT, Gemini LLM, OpenAI TTS pipeline
 * June 2026 — 7-layer architecture
 */

const { randomUUID } = require('crypto');

// Configuration constants (June 2026 pricing)
const COST = {
  DEEPGRAM_STT: 0.0059,     // $/min (Nova-3)
  GEMINI_FLASH: 0.0000375,  // $/1K input tokens (Flash Live)
  GEMINI_OUTPUT: 0.00015,   // $/1K output tokens
  TTS_OPENAI: 0.015,        // $/1K chars (TTS-1)
  TWILIO_INBOUND: 0.0085,   // $/min (inbound)
  TWILIO_OUTBOUND: 0.014,   // $/min (outbound to mobile)
};

// Estimated tokens per minute of conversation
const EST_TOKENS_IN = 800;
const EST_TOKENS_OUT = 300;
const EST_TTS_CHARS = 600;

/**
 * Calculate estimated cost for a conversation
 */
function calculateCost(durationSeconds) {
  const minutes = durationSeconds / 60;
  const sttCost = minutes * COST.DEEPGRAM_STT;
  const llmCost = minutes * (
    (EST_TOKENS_IN / 1000 * COST.GEMINI_FLASH) +
    (EST_TOKENS_OUT / 1000 * COST.GEMINI_OUTPUT)
  );
  const ttsCost = minutes * (EST_TTS_CHARS / 1000 * COST.TTS_OPENAI);
  const twilioCost = minutes * COST.TWILIO_INBOUND;
  const total = sttCost + llmCost + ttsCost + twilioCost;

  return {
    stt: Math.round(sttCost * 10000) / 10000,
    llm: Math.round(llmCost * 10000) / 10000,
    tts: Math.round(ttsCost * 10000) / 10000,
    twilio: Math.round(twilioCost * 10000) / 10000,
    total: Math.round(total * 10000) / 10000,
    perMinute: Math.round((total / minutes) * 10000) / 10000,
  };
}

async function voiceRoutes(fastify, options) {
  const { prisma } = fastify;

  // ── Start a new call ──────────────────────────────────
  fastify.post('/call/start', {
    preHandler: [fastify.authenticate],
    schema: {
      body: {
        type: 'object',
        required: ['senior_id'],
        properties: {
          senior_id: { type: 'string' },
          caller_number: { type: 'string' },
        },
      },
    },
  }, async (request, reply) => {
    const { senior_id, caller_number } = request.body;

    // Verify senior exists
    const senior = await prisma.senior.findUnique({
      where: { id: senior_id },
      include: { medications: { where: { isActive: true } } },
    });

    if (!senior) {
      return reply.code(404).send({ error: 'Senior not found' });
    }

    // Generate call SID
    const callSid = `CA${randomUUID().replace(/-/g, '')}`;

    // In production: initiate Twilio call
    // const twilioCall = await twilioClient.calls.create({...});

    // Create conversation record
    const conversation = await prisma.conversation.create({
      data: {
        seniorId: senior_id,
        callSid,
        startedAt: new Date(),
      },
    });

    // Fetch RAG context for personalized greeting
    const recentConversations = await prisma.conversation.findMany({
      where: { seniorId: senior_id },
      orderBy: { startedAt: 'desc' },
      take: 3,
    });

    const context = {
      senior_name: senior.preferredName || senior.firstName,
      medical_conditions: senior.medicalConditions,
      medications: senior.medications.map(m => ({
        name: m.name,
        dosage: m.dosage,
        time: m.timeOfDay,
      })),
      last_mood: recentConversations[0]?.moodScore || null,
      semafor_level: senior.semaforLevel,
    };

    reply.code(201).send({
      call_id: conversation.id,
      call_sid: callSid,
      status: 'initiated',
      context,
      greeting: `Dzień dobry, ${context.senior_name}! Tu Adam. Jak się dziś czujesz?`,
    });
  });

  // ── End a call ────────────────────────────────────────
  fastify.post('/call/end', {
    preHandler: [fastify.authenticate],
    schema: {
      body: {
        type: 'object',
        required: ['call_id'],
        properties: {
          call_id: { type: 'string' },
          reason: { type: 'string', default: 'normal' },
          duration_seconds: { type: 'integer' },
          transcript: { type: 'array' },
          mood_score: { type: 'number' },
          topics_detected: { type: 'string' },
        },
      },
    },
  }, async (request, reply) => {
    const {
      call_id,
      reason,
      duration_seconds,
      transcript,
      mood_score,
      topics_detected,
    } = request.body;

    const endedAt = new Date();
    const cost = calculateCost(duration_seconds || 0);

    const updated = await prisma.conversation.update({
      where: { id: call_id },
      data: {
        duration: duration_seconds || 0,
        transcript: transcript || [],
        moodScore: mood_score,
        topicsDetected: topics_detected,
        isCompleted: true,
        hangupReason: reason,
        endedAt,
        costStt: cost.stt,
        costLlm: cost.llm,
        costTts: cost.tts,
        costTwilio: cost.twilio,
        costTotal: cost.total,
      },
    });

    // Update senior's last conversation timestamp
    await prisma.senior.update({
      where: { id: updated.seniorId },
      data: { lastConversation: endedAt },
    });

    // If mood is very low, create an alert
    if (mood_score && mood_score < 2.5) {
      await prisma.alert.create({
        data: {
          seniorId: updated.seniorId,
          type: 'MOOD_DECLINE',
          severity: mood_score < 1.5 ? 'RED' : 'ORANGE',
          title: 'Spadek nastroju wykryty',
          description: `Wynik nastroju: ${mood_score}/5. Rozmowa trwała ${duration_seconds}s.`,
        },
      });
    }

    reply.send({
      status: 'completed',
      call_id,
      cost,
      total_conversation_cost: `$${cost.total.toFixed(4)}`,
    });
  });

  // ── Get call status ───────────────────────────────────
  fastify.get('/call/:callId/status', {
    preHandler: [fastify.authenticate],
  }, async (request, reply) => {
    const { callId } = request.params;

    const conversation = await prisma.conversation.findUnique({
      where: { id: callId },
      select: {
        id: true,
        callSid: true,
        duration: true,
        isCompleted: true,
        hangupReason: true,
        costTotal: true,
        moodScore: true,
        startedAt: true,
        endedAt: true,
      },
    });

    if (!conversation) {
      return reply.code(404).send({ error: 'Call not found' });
    }

    reply.send(conversation);
  });

  // ── Generate TwiML for incoming calls ─────────────────
  fastify.post('/twilio/incoming', async (request, reply) => {
    const { From, To, CallSid } = request.body;

    // Find senior by phone number
    const senior = await prisma.senior.findFirst({
      where: { phone: From },
    });

    const greeting = senior
      ? `Dzień dobry, ${senior.preferredName || senior.firstName}! Tu Adam.`
      : 'Dzień dobry! Tu Adam, Twój asystent.';

    const twiml = `<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Say voice="Polski-Jacek" language="pl-PL">${greeting} Jak mogę pomóc?</Say>
  <Gather input="speech" language="pl-PL" speechTimeout="auto" action="/api/voice/twilio/process" method="POST">
    <Say voice="Polski-Jacek" language="pl-PL">Słucham Cię uważnie.</Say>
  </Gather>
  <Say voice="Polski-Jacek" language="pl-PL">Przepraszam, nie usłyszałem. Zadzwoń ponownie.</Say>
</Response>`;

    reply.type('text/xml').send(twiml);
  });

  // ── Process gathered speech ───────────────────────────
  fastify.post('/twilio/process', async (request, reply) => {
    const { SpeechResult, From, CallSid } = request.body;

    // In production: send SpeechResult to Gemini for processing
    // In production: generate response and convert to TTS

    const twiml = `<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Say voice="Polski-Jacek" language="pl-PL">Dziękuję. Rozumiem, co mówisz.</Say>
  <Gather input="speech" language="pl-PL" speechTimeout="auto" action="/api/voice/twilio/process" method="POST">
    <Say voice="Polski-Jacek" language="pl-PL">Czy jest coś jeszcze?</Say>
  </Gather>
</Response>`;

    reply.type('text/xml').send(twiml);
  });

  // ── Get voice configuration ───────────────────────────
  fastify.get('/config/:seniorId', {
    preHandler: [fastify.authenticate],
  }, async (request, reply) => {
    const { seniorId } = request.params;

    const senior = await prisma.senior.findUnique({
      where: { id: seniorId },
      select: {
        voiceSpeed: true,
        voicePitch: true,
        voiceVolume: true,
        preferredName: true,
      },
    });

    if (!senior) {
      return reply.code(404).send({ error: 'Senior not found' });
    }

    reply.send({
      speed: senior.voiceSpeed || 1.0,
      pitch: senior.voicePitch || 1.0,
      volume: senior.voiceVolume || 1.0,
      preferred_name: senior.preferredName,
      voice_model: 'openai-tts-1',
      voice_id: 'echo', // OpenAI voice
      language: 'pl-PL',
    });
  });

  // ── Update voice configuration ────────────────────────
  fastify.patch('/config/:seniorId', {
    preHandler: [fastify.authenticate],
  }, async (request, reply) => {
    const { seniorId } = request.params;
    const { speed, pitch, volume, preferred_name } = request.body;

    const updated = await prisma.senior.update({
      where: { id: seniorId },
      data: {
        voiceSpeed: speed,
        voicePitch: pitch,
        voiceVolume: volume,
        preferredName: preferred_name,
      },
      select: {
        voiceSpeed: true,
        voicePitch: true,
        voiceVolume: true,
        preferredName: true,
      },
    });

    reply.send(updated);
  });
}

module.exports = voiceRoutes;
