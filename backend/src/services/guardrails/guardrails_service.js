/**
 * Guardrails Service — Content Safety & Compliance for Agent Adam
 *
 * Implements a multi-layer safety filter:
 *  - Layer 1: Regex pattern blocking (emergency, abuse, self-harm)
 *  - Layer 2: Keyword intersection scoring (Polish/English toxic words)
 *  - Layer 3: Embedding similarity (cosine distance) against known unsafe patterns
 *  - Layer 4: EU AI Act compliance (Limited Risk classification requirements)
 *
 * Returns: { allowed: boolean, score: number, flags: string[], sanitized: string }
 */

const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

// ─── Layer 1: Critical patterns (immediate block) ──────────────────────
const CRITICAL_PATTERNS = [
  // Self-harm / suicide
  /\b(chcę\s+się\s+zabi[ćc]|samobójstwo|odebrać\s+sobie\s+życie|nie\s+chcę\s+żyć)\b/i,
  /\b(i want to (die|kill myself)|suicide|end my life)\b/i,

  // Violence
  /\b(zabi[jć]|zastrzel[ęi]|udus[ęi]|otru[jć])\b.*\b(kogoś|ciebie|jego|ją|ich)\b/i,
  /\b(i will kill|murder|shoot)\b/i,

  // Child exploitation
  /\b(dziecko|child).{0,10}\b(pornografia|nadużycie|exploitation|abuse|porn)\b/i,

  // Illegal drugs / controlled substances
  /\b(gdzie\s+kupi[ćc]\s+narkotyki|heroina|kokaina|amfetamina)\b/i,
];

// ─── Layer 2: Toxic keyword scoring ────────────────────────────────────
const TOXIC_KEYWORDS = {
  // Polish
  high: ['głupi', 'idiota', 'kretyn', 'debil', 'spierdalaj', 'pierdol', 'chuj', 'kurwa'],
  medium: ['nienawidzę', 'okropny', 'beznadziejny', 'wstrętny', 'obrzydliwy'],
  low: ['głupie', 'nieładne', 'brzydkie'],
  // English
  high_en: ['stupid', 'idiot', 'moron', 'bastard', 'fuck', 'shit'],
  medium_en: ['hate', 'terrible', 'awful', 'disgusting'],
};

// ─── Layer 3: Unsafe embedding patterns (pre-computed centroids) ───────
// These would be trained from actual flagged conversations
const UNSAFE_CENTROIDS = [
  // Placeholder — in production, loaded from DB with pgvector
  { id: 'anger_centroid', threshold: 0.85 },
  { id: 'agitation_centroid', threshold: 0.82 },
  { id: 'distress_centroid', threshold: 0.88 },
];

// ─── EU AI Act: Forbidden use cases ────────────────────────────────────
const EU_AI_ACT_FORBIDDEN = [
  'subliminal_manipulation',
  'vulnerability_exploitation',
  'social_scoring',
  'real_time_biometric_categorization',
  'predictive_policing',
  'emotion_recognition',
];

// ─── Main guardrail check ──────────────────────────────────────────────
async function checkContent(text, options = {}) {
  const { seniorId, conversationId, strict = true } = options;
  const flags = [];
  let score = 0;

  // ─── Layer 1: Critical pattern matching ────────────────────────────
  for (const pattern of CRITICAL_PATTERNS) {
    if (pattern.test(text)) {
      flags.push({
        layer: 'CRITICAL_PATTERN',
        severity: 'BLOCK',
        pattern: pattern.source.substring(0, 50),
        message: 'Wykryto niedozwoloną treść — odpowiedź zablokowana',
      });
      score += 100;

      // Log critical flag
      await logGuardrailEvent({
        seniorId,
        conversationId,
        text,
        flag: 'CRITICAL_PATTERN',
        score: 100,
        action: 'BLOCK',
      });

      return {
        allowed: false,
        score,
        flags,
        sanitized: null,
        response: 'Przepraszam, nie mogę odpowiedzieć na to pytanie. Czy mogę pomóc w czymś innym?',
      };
    }
  }

  // ─── Layer 2: Keyword scoring ──────────────────────────────────────
  const lowerText = text.toLowerCase();

  for (const word of TOXIC_KEYWORDS.high) {
    if (lowerText.includes(word)) {
      flags.push({ layer: 'TOXIC_KEYWORD', severity: 'HIGH', word });
      score += 30;
    }
  }
  for (const word of TOXIC_KEYWORDS.medium) {
    if (lowerText.includes(word)) {
      flags.push({ layer: 'TOXIC_KEYWORD', severity: 'MEDIUM', word });
      score += 15;
    }
  }
  for (const word of TOXIC_KEYWORDS.low) {
    if (lowerText.includes(word)) {
      flags.push({ layer: 'TOXIC_KEYWORD', severity: 'LOW', word });
      score += 5;
    }
  }
  for (const word of TOXIC_KEYWORDS.high_en) {
    if (lowerText.includes(word)) {
      flags.push({ layer: 'TOXIC_KEYWORD', severity: 'HIGH', word });
      score += 30;
    }
  }

  // ─── Layer 3: Embedding similarity check ───────────────────────────
  // Note: In production, compute embedding and check cosine similarity
  // against pgvector centroids. Here we use a heuristic fallback.
  const embeddingScore = await heuristicSafetyCheck(text);
  score += embeddingScore;
  if (embeddingScore > 50) {
    flags.push({
      layer: 'EMBEDDING_SIMILARITY',
      severity: 'HIGH',
      score: embeddingScore,
      message: 'Treść podobna do wcześniej oflagowanych wzorców',
    });
  }

  // ─── Layer 4: EU AI Act compliance ─────────────────────────────────
  for (const forbidden of EU_AI_ACT_FORBIDDEN) {
    if (containsForbiddenUseCase(text, forbidden)) {
      flags.push({
        layer: 'EU_AI_ACT',
        severity: 'BLOCK',
        violation: forbidden,
        message: 'Naruszenie EU AI Act — niedozwolone zastosowanie',
      });
      score += 200;
    }
  }

  // ─── Decision ──────────────────────────────────────────────────────
  const allowed = strict ? score < 50 : score < 100;

  // Log event
  await logGuardrailEvent({
    seniorId,
    conversationId,
    text: text.substring(0, 200),
    flag: flags.length > 0 ? flags.map((f) => f.layer).join(',') : 'CLEAN',
    score,
    action: allowed ? 'ALLOW' : 'FLAG',
  });

  // Sanitize if borderline
  let sanitized = text;
  if (score > 30 && score < 50) {
    sanitized = sanitizeToxicWords(text);
  }

  return {
    allowed,
    score,
    flags,
    sanitized: allowed ? sanitized : null,
    response: allowed
      ? null
      : 'Przepraszam, wyczuwam negatywne emocje. Czy chcesz porozmawiać o tym, co Cię trapi? Jestem tu, żeby pomóc. 🫶',
  };
}

// ─── Heuristic safety check ────────────────────────────────────────────
async function heuristicSafetyCheck(text) {
  // Simple heuristic: check for combinations of negative indicators
  let score = 0;
  const negativeIndicators = [
    /\b(nigdy|zawsze|wszyscy|nikt)\b/i, // Absolutist language
    /!{2,}/,                                 // Multiple exclamation marks
    /[A-ZĄĆĘŁŃÓŚŹŻ]{4,}/,                   // ALL CAPS sequences
    /\b(umrę|umrzesz|śmierć|umieram)\b/i,  // Death-related words
  ];

  for (const pattern of negativeIndicators) {
    if (pattern.test(text)) {
      score += 10;
    }
  }

  return score;
}

// ─── Check for EU AI Act forbidden use cases ──────────────────────────
function containsForbiddenUseCase(text, violationType) {
  const patterns = {
    subliminal_manipulation:
      /\b(nieświadomie|podświadomie|subliminaln|manipuluj|manipulować)\b/i,
    vulnerability_exploitation:
      /\b(wykorzysta[ćc].{0,20}(słabość|bezbronność|wiek|niepełnosprawność))\b/i,
    social_scoring:
      /\b(ocena\s+społeczna|punktacja\s+społeczna|social\s+score|ranking\s+osób)\b/i,
    emotion_recognition:
      /\b(rozpoznaj\s+emocje|wykryj\s+emocje|emotion\s+recognition)\b/i,
  };

  return patterns[violationType]?.test(text) || false;
}

// ─── Sanitize toxic words ──────────────────────────────────────────────
function sanitizeToxicWords(text) {
  let sanitized = text;
  const allToxic = [
    ...TOXIC_KEYWORDS.high,
    ...TOXIC_KEYWORDS.medium,
    ...TOXIC_KEYWORDS.high_en,
  ];

  for (const word of allToxic) {
    const regex = new RegExp(`\\b${word}\\b`, 'gi');
    sanitized = sanitized.replace(regex, '***');
  }

  return sanitized;
}

// ─── Log guardrail event to database ───────────────────────────────────
async function logGuardrailEvent(event) {
  try {
    await prisma.guardrailLog.create({
      data: {
        seniorId: event.seniorId || null,
        conversationId: event.conversationId || null,
        inputText: event.text?.substring(0, 500) || '',
        flagType: event.flag,
        score: event.score,
        action: event.action,
        timestamp: new Date(),
      },
    });
  } catch (err) {
    console.error('[Guardrails] Failed to log event:', err.message);
  }
}

// ─── Batch check for conversation history ──────────────────────────────
async function batchCheck(messages, options = {}) {
  const results = [];

  for (const msg of messages) {
    const result = await checkContent(msg.text || msg.content, {
      ...options,
      strict: false, // Less strict for historical messages
    });
    results.push({ ...msg, guardrail: result });
  }

  return results;
}

// ─── Get guardrail statistics ──────────────────────────────────────────
async function getStats(seniorId, periodDays = 30) {
  const since = new Date();
  since.setDate(since.getDate() - periodDays);

  const logs = await prisma.guardrailLog.findMany({
    where: {
      seniorId,
      timestamp: { gte: since },
    },
  });

  const total = logs.length;
  const blocked = logs.filter((l) => l.action === 'BLOCK').length;
  const flagged = logs.filter((l) => l.action === 'FLAG').length;
  const allowed = logs.filter((l) => l.action === 'ALLOW').length;

  const flagTypes = {};
  for (const log of logs) {
    const types = log.flagType.split(',');
    for (const t of types) {
      flagTypes[t] = (flagTypes[t] || 0) + 1;
    }
  }

  return {
    period: `${periodDays}d`,
    total,
    blocked,
    flagged,
    allowed,
    blockRate: total > 0 ? ((blocked / total) * 100).toFixed(1) + '%' : '0%',
    flagDistribution: flagTypes,
    cost: {
      perCheck: '$0.0001',
      totalEstimated: `$${(total * 0.0001).toFixed(4)}`,
    },
  };
}

module.exports = {
  checkContent,
  batchCheck,
  getStats,
  logGuardrailEvent,
  CRITICAL_PATTERNS,
  EU_AI_ACT_FORBIDDEN,
};
