/**
 * SilverTech Agent Adam — RAG (Retrieval-Augmented Generation) Service
 * pgvector semantic search for context-aware conversations
 * June 2026 — 1536-dim embeddings, cosine similarity, top-5 retrieval
 */

const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// Configuration
const RAG_CONFIG = {
  topK: 5,
  similarityThreshold: 0.75,
  maxContextTokens: 4000,
  embeddingModel: 'text-embedding-3-small',
  dimensions: 1536,
  categories: {
    MEDICAL: 'medical_knowledge',
    MEDICATION: 'medication_info',
    EMERGENCY: 'emergency_protocols',
    WELLNESS: 'wellness_advice',
    SOCIAL: 'social_engagement',
    SERVICES: 'available_services',
  },
};

/**
 * Vectorize text using embedding model
 * In production: calls OpenAI embeddings API
 */
async function vectorize(text) {
  // Simulated — in production calls OpenAI /v1/embeddings
  // Returns 1536-dim float array
  const vector = new Array(RAG_CONFIG.dimensions).fill(0);
  // Simple hash-based deterministic embedding for dev
  const hash = text.split('').reduce((acc, c, i) => acc + c.charCodeAt(0) * (i + 1), 0);
  for (let i = 0; i < RAG_CONFIG.dimensions; i++) {
    vector[i] = Math.sin(hash * (i + 1) * 0.001) * 0.1;
  }
  return vector;
}

/**
 * Semantic search for relevant context
 */
async function searchSimilar(query, seniorId, options = {}) {
  const { topK = RAG_CONFIG.topK, threshold = RAG_CONFIG.similarityThreshold, categories = null } = options;

  const queryVector = await vectorize(query);
  const vectorStr = `[${queryVector.slice(0, RAG_CONFIG.dimensions).join(',')}]`;

  const results = await prisma.$queryRawUnsafe(`
    SELECT id, content, metadata, source,
           1 - (embedding <=> '${vectorStr}'::vector) AS similarity
    FROM document_embeddings
    WHERE 1 - (embedding <=> '${vectorStr}'::vector) > ${threshold}
    ORDER BY similarity DESC
    LIMIT ${topK}
  `);

  return results.map(r => ({
    ...r,
    similarity: parseFloat(r.similarity),
  }));
}

/**
 * Build conversation context from RAG results + senior profile
 */
async function buildContext(query, seniorId) {
  // Get senior profile
  const senior = await prisma.senior.findUnique({
    where: { id: seniorId },
    select: {
      firstName: true, preferredName: true, medicalConditions: true,
      allergies: true, semaforLevel: true, medications: {
        where: { isActive: true }, select: { name: true, dosage: true, timeOfDay: true }
      },
    },
  });

  // Search for relevant knowledge
  const ragResults = await searchSimilar(query, seniorId);

  // Get recent conversations for continuity
  const recentConversations = await prisma.conversation.findMany({
    where: { seniorId },
    orderBy: { startedAt: 'desc' },
    take: 3,
    select: { moodScore: true, topicsDetected: true, startedAt: true },
  });

  return {
    senior: {
      name: senior?.preferredName || senior?.firstName || 'Senior',
      medicalConditions: senior?.medicalConditions || 'brak',
      allergies: senior?.allergies || 'brak',
      medications: senior?.medications || [],
      semaforLevel: senior?.semaforLevel || 'GREEN',
    },
    recentMood: recentConversations.map(c => ({
      date: c.startedAt, mood: c.moodScore, topics: c.topicsDetected
    })),
    relevantKnowledge: ragResults.map(r => ({
      content: r.content, source: r.source, similarity: r.similarity
    })),
  };
}

/**
 * Generate system prompt with RAG context
 */
function buildSystemPrompt(context) {
  const { senior, recentMood, relevantKnowledge } = context;

  const knowledgeText = relevantKnowledge
    .map(k => `[${k.source || 'wiedza'}]: ${k.content}`)
    .join('\n');

  const medsText = senior.medications
    .map(m => `- ${m.name} ${m.dosage} (${m.timeOfDay})`)
    .join('\n');

  return `Jesteś ADAM, ciepły i empatyczny asystent AI dla seniorów w Polsce.
Mówisz po polsku, prostym i zrozumiałym językiem.

## Profil seniora:
- Imię: ${senior.name}
- Stan zdrowia: ${senior.medicalConditions}
- Alergie: ${senior.allergies}
- Leki: ${medsText || 'brak'}
- Status Semafor: ${senior.semaforLevel}

## Ostatni nastrój:
${recentMood.map(m => `- ${m.date.toISOString().split('T')[0]}: ${m.mood}/5, tematy: ${m.topics || 'brak'}`).join('\n')}

## Wiedza kontekstowa:
${knowledgeText || 'Brak dodatkowej wiedzy kontekstowej.'}

## Zasady:
1. ZAWSZE bądź ciepły, cierpliwy i empatyczny
2. Używaj prostego języka — żadnego żargonu medycznego
3. Jeśli senior zgłasza ból lub problem zdrowotny — zaoferuj kontakt z lekarzem
4. Jeśli nastrój jest niski — zaproponuj rozmowę, aktywność lub kontakt z rodziną
5. NIGDY nie stawiaj diagnozy — zawsze odsyłaj do lekarza
6. Przypominaj o lekach naturalnie, nie jak robot
7. W sytuacji awaryjnej (SOS) — natychmiast eskaluj`;
}

/**
 * Ingest new knowledge document
 */
async function ingestDocument(content, metadata = {}) {
  const embedding = await vectorize(content);
  const vectorStr = `[${embedding.slice(0, RAG_CONFIG.dimensions).join(',')}]`;

  await prisma.$executeRawUnsafe(`
    INSERT INTO document_embeddings (content, embedding, metadata, source)
    VALUES ('${content.replace(/'/g, "''")}', '${vectorStr}'::vector, '${JSON.stringify(metadata).replace(/'/g, "''")}', '${metadata.source || 'manual'}')
  `);

  return { ingested: true, contentLength: content.length };
}

/**
 * Seed initial knowledge base
 */
async function seedKnowledgeBase() {
  const documents = [
    {
      content: 'W przypadku bólu w klatce piersiowej należy natychmiast wezwać pogotowie (112). Nie zwlekać. Opisać objawy: ucisk, pieczenie, duszność.',
      metadata: { category: 'EMERGENCY', topic: 'chest_pain' }
    },
    {
      content: 'Objawy udaru: asymetria twarzy, osłabienie jednej strony ciała, problemy z mową. Natychmiast dzwoń 112. Liczy się każda minuta.',
      metadata: { category: 'EMERGENCY', topic: 'stroke' }
    },
    {
      content: 'W przypadku upadku: nie ruszać seniora, sprawdzić przytomność, wezwać pogotowie. Jeśli senior jest przytomny — uspokoić, przykryć kocem.',
      metadata: { category: 'EMERGENCY', topic: 'fall' }
    },
    {
      content: 'Metformina — lek na cukrzycę. Przyjmować z posiłkiem. Nie pomijać dawek. Może powodować nudności na początku leczenia.',
      metadata: { category: 'MEDICATION', topic: 'metformin' }
    },
    {
      content: 'Aktywność fizyczna dla seniorów: spacery 30 min dziennie, lekkie ćwiczenia rozciągające, nordic walking. Unikać przeciążeń.',
      metadata: { category: 'WELLNESS', topic: 'exercise' }
    },
    {
      content: 'Dieta dla seniorów: dużo warzyw i owoców, pełnoziarniste produkty, ryby 2x tygodniowo. Pić minimum 1.5l wody dziennie.',
      metadata: { category: 'WELLNESS', topic: 'nutrition' }
    },
    {
      content: 'Samotność u seniorów — jak pomóc: regularne rozmowy, zachęcanie do aktywności społecznych, kontakt z rodziną, grupy wsparcia.',
      metadata: { category: 'SOCIAL', topic: 'loneliness' }
    },
    {
      content: 'Higiena snu: stałe godziny snu, unikanie ekranów przed snem, temperatura w sypialni 18-20°C, unikanie kofeiny po 16:00.',
      metadata: { category: 'WELLNESS', topic: 'sleep' }
    },
    {
      content: 'Usługi dostępne w Marketplace: lekarz domowy (150 zł), pielęgniarka (80 zł), fizjoterapeuta (120 zł), sprzątanie (100 zł), zakupy (40 zł), transport medyczny (60 zł).',
      metadata: { category: 'SERVICES', topic: 'marketplace' }
    },
    {
      content: 'Numery alarmowe: 112 — ogólny, 999 — pogotowie, 998 — straż pożarna, 997 — policja. W razie wątpliwości zawsze dzwoń 112.',
      metadata: { category: 'EMERGENCY', topic: 'emergency_numbers' }
    },
  ];

  for (const doc of documents) {
    await ingestDocument(doc.content, doc.metadata);
  }

  return { seeded: documents.length, categories: [...new Set(documents.map(d => d.metadata.category))] };
}

module.exports = { vectorize, searchSimilar, buildContext, buildSystemPrompt, ingestDocument, seedKnowledgeBase };
