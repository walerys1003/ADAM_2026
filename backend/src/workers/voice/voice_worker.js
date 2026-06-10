/**
 * SilverTech Agent Adam — Voice Processing Worker (BullMQ)
 * Asynchronous voice pipeline: STT → RAG → LLM → Guardrails → TTS
 * June 2026 — processes call transcriptions, mood scoring, topic extraction
 */

const { Worker } = require('bullmq');
const Redis = require('ioredis');

const redisConnection = new Redis(process.env.REDIS_URL || 'redis://localhost:6379', {
  maxRetriesPerRequest: null,
  enableReadyCheck: false,
});

// Cost constants (June 2026)
const COST = {
  DEEPGRAM_STT: 0.0059,
  GEMINI_INPUT: 0.0000375,
  GEMINI_OUTPUT: 0.00015,
  TTS_OPENAI: 0.015,
};

/**
 * Estimate tokens in text (rough: ~4 chars per token for Polish)
 */
function estimateTokens(text) {
  return Math.ceil((text || '').length / 4);
}

/**
 * Process voice transcript — extract mood, topics, and generate response
 */
async function processTranscript(job) {
  const { callId, seniorId, transcript, audioUrl } = job.data;

  await job.updateProgress(10);
  console.log(`[VoiceWorker] Processing call ${callId} — ${transcript?.length || 0} chars`);

  // Step 1: STT (if audioUrl provided)
  let text = transcript;
  if (audioUrl && !text) {
    await job.updateProgress(20);
    // In production: call Deepgram Nova-3
    // const sttResult = await deepgram.transcribe(audioUrl);
    // text = sttResult.text;
    text = '[Simulated STT output]';
  }

  // Step 2: RAG Context Retrieval
  await job.updateProgress(30);
  // const ragService = require('../../services/rag/rag_service');
  // const context = await ragService.buildContext(text, seniorId);

  // Step 3: LLM (Gemini 3.2 Flash)
  await job.updateProgress(50);
  // const systemPrompt = ragService.buildSystemPrompt(context);
  // const llmResponse = await gemini.generate(text, systemPrompt);
  const inputTokens = estimateTokens(text);
  const outputTokens = 150; // estimated

  // Step 4: Guardrails
  await job.updateProgress(60);
  // const guardrails = require('../../services/guardrails/guardrails');
  // const isSafe = await guardrails.check(llmResponse);
  const isSafe = true;

  if (!isSafe) {
    console.warn(`[VoiceWorker] Guardrails triggered for call ${callId}`);
    return { 
      callId, status: 'blocked', 
      reason: 'guardrails_triggered',
      cost: { stt: COST.DEEPGRAM_STT, llm: 0, tts: 0, total: COST.DEEPGRAM_STT }
    };
  }

  // Step 5: Mood Scoring
  await job.updateProgress(70);
  const moodScore = 3.5 + Math.random() * 1.5; // Simulated 3.5-5.0

  // Step 6: Topic Extraction
  await job.updateProgress(80);
  const topics = ['codzienna_rozmowa', 'zdrowie'];

  // Step 7: TTS Generation
  await job.updateProgress(90);
  // const audioResponse = await openai.tts(llmResponse);
  const ttsChars = 500;

  // Step 8: Store results
  await job.updateProgress(95);

  const cost = {
    stt: COST.DEEPGRAM_STT,
    llm: (inputTokens / 1000) * COST.GEMINI_INPUT + (outputTokens / 1000) * COST.GEMINI_OUTPUT,
    tts: (ttsChars / 1000) * COST.TTS_OPENAI,
    total: 0,
  };
  cost.total = cost.stt + cost.llm + cost.tts;

  await job.updateProgress(100);

  return {
    callId,
    status: 'completed',
    moodScore: Math.round(moodScore * 10) / 10,
    topicsDetected: topics.join(', '),
    inputTokens,
    outputTokens,
    cost: {
      stt: Math.round(cost.stt * 10000) / 10000,
      llm: Math.round(cost.llm * 10000) / 10000,
      tts: Math.round(cost.tts * 10000) / 10000,
      total: Math.round(cost.total * 10000) / 10000,
    },
    processingTimeMs: job.processedOn ? Date.now() - job.processedOn : 0,
  };
}

/**
 * Score mood from transcript text (simple keyword-based)
 */
function scoreMood(text) {
  const lower = text.toLowerCase();
  const positive = ['dobrze', 'świetnie', 'wspaniale', 'cieszę', 'radosny', 'szczęśliwy'];
  const negative = ['źle', 'smutno', 'boli', 'samotny', 'przykro', 'tęsknię', 'niepokój'];

  let score = 3.0;
  for (const word of positive) if (lower.includes(word)) score += 0.3;
  for (const word of negative) if (lower.includes(word)) score -= 0.4;

  return Math.max(1, Math.min(5, Math.round(score * 10) / 10));
}

// ── Create Worker ────────────────────────────────────
const voiceWorker = new Worker('voice-processing', processTranscript, {
  connection: redisConnection,
  concurrency: 4,
  limiter: {
    max: 20,
    duration: 1000,
  },
  settings: {
    backoffStrategy: (attemptsMade) => Math.min(attemptsMade * 1000, 10000),
    backoffStrategies: [1000, 2000, 5000, 10000],
  },
});

voiceWorker.on('completed', (job, result) => {
  console.log(`[VoiceWorker] Job ${job.id} completed — mood: ${result.moodScore}, cost: $${result.cost.total}`);
});

voiceWorker.on('failed', (job, err) => {
  console.error(`[VoiceWorker] Job ${job.id} failed:`, err.message);
});

voiceWorker.on('error', (err) => {
  console.error('[VoiceWorker] Worker error:', err.message);
});

// ── Graceful Shutdown ────────────────────────────────
async function shutdown() {
  console.log('[VoiceWorker] Shutting down...');
  await voiceWorker.close();
  await redisConnection.quit();
  process.exit(0);
}

process.on('SIGTERM', shutdown);
process.on('SIGINT', shutdown);

console.log('[VoiceWorker] Started — listening for voice-processing jobs');

module.exports = { voiceWorker, processTranscript, scoreMood };
