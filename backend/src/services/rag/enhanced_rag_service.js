'use strict';

const { ChromaClient } = require('chromadb');
const { RecursiveCharacterTextSplitter } = require('langchain/text_splitter');

/**
 * Enhanced RAG Service — June 2026
 * Hybrid retrieval: pgvector (semantic) + keyword (BM25) + recency boost
 * Context window: optimized for Gemini 3.2 Flash Live (1M tokens)
 */
class EnhancedRagService {
  constructor() {
    this.chroma = null;
    this.collection = null;
    this.textSplitter = new RecursiveCharacterTextSplitter({
      chunkSize: 512,
      chunkOverlap: 64,
      separators: ['\n\n', '\n', '. ', '! ', '? ', ' ', ''],
    });
    this.cache = new Map();
    this.cacheMaxSize = 1000;
  }

  async initialize() {
    this.chroma = new ChromaClient({ path: process.env.CHROMA_URL || 'http://localhost:8000' });
    this.collection = await this.chroma.getOrCreateCollection({
      name: 'senior_knowledge',
      metadata: { 'hnsw:space': 'cosine' },
    });
  }

  /**
   * Index a new document (RODO policy, medication info, senior profile, etc.)
   */
  async indexDocument({ docId, content, metadata = {}, namespace = 'general' }) {
    const chunks = await this.textSplitter.splitText(content);
    const ids = chunks.map((_, i) => `${docId}_chunk_${i}`);
    const metadatas = chunks.map((_, i) => ({
      ...metadata,
      doc_id: docId,
      chunk_index: i,
      namespace,
      indexed_at: new Date().toISOString(),
    }));

    await this.collection.add({ ids, documents: chunks, metadatas });
    return { docId, chunks: chunks.length, namespace };
  }

  /**
   * Hybrid retrieval: semantic + keyword + recency
   */
  async retrieve({ query, seniorId, topK = 5, namespace = null, recencyDays = 30 }) {
    const cacheKey = `${query}:${seniorId}:${topK}:${namespace}`;
    if (this.cache.has(cacheKey)) return this.cache.get(cacheKey);

    // Semantic search via ChromaDB
    const whereFilter = {};
    if (namespace) whereFilter.namespace = namespace;

    const semanticResults = await this.collection.query({
      queryTexts: [query],
      nResults: topK * 2,
      where: Object.keys(whereFilter).length > 0 ? whereFilter : undefined,
    });

    // Keyword boost (simple BM25-like)
    const queryTerms = query.toLowerCase().split(/\s+/).filter(t => t.length > 2);
    const keywordScores = semanticResults.documents[0].map((doc) => {
      const docLower = (doc || '').toLowerCase();
      const matchCount = queryTerms.filter(t => docLower.includes(t)).length;
      return matchCount / Math.max(queryTerms.length, 1);
    });

    // Recency boost
    const now = Date.now();
    const recencyWindow = recencyDays * 86400000;
    const recencyScores = (semanticResults.metadatas[0] || []).map(meta => {
      const indexedAt = meta?.indexed_at ? new Date(meta.indexed_at).getTime() : now;
      const age = now - indexedAt;
      return Math.exp(-age / recencyWindow);
    });

    // Combine scores (0.5 semantic + 0.3 keyword + 0.2 recency)
    const distances = semanticResults.distances?.[0] || new Array(topK * 2).fill(0);
    const combinedScores = semanticResults.documents[0].map((_, i) => {
      const semanticScore = 1.0 / (1.0 + (distances[i] || 0));
      return 0.5 * semanticScore + 0.3 * keywordScores[i] + 0.2 * recencyScores[i];
    });

    // Sort and take topK
    const ranked = semanticResults.documents[0]
      .map((doc, i) => ({
        content: doc,
        metadata: semanticResults.metadatas[0]?.[i] || {},
        score: combinedScores[i],
        distance: distances[i],
      }))
      .sort((a, b) => b.score - a.score)
      .slice(0, topK);

    if (this.cache.size >= this.cacheMaxSize) {
      const firstKey = this.cache.keys().next().value;
      this.cache.delete(firstKey);
    }
    this.cache.set(cacheKey, ranked);

    return ranked;
  }

  /**
   * Build RAG context string for LLM prompt injection
   */
  buildContextString(results, maxTokens = 4000) {
    if (!results || results.length === 0) return '';

    const contextParts = [];
    let totalChars = 0;
    const charLimit = maxTokens * 3; // ~3 chars per token

    for (const r of results) {
      const part = `[Źródło: ${r.metadata.doc_id || 'dokument'} | Trafność: ${(r.score * 100).toFixed(0)}%]\n${r.content}`;
      if (totalChars + part.length > charLimit) break;
      contextParts.push(part);
      totalChars += part.length;
    }

    return `KONTEKST (dokumenty SilverTech):\n${contextParts.join('\n\n---\n\n')}`;
  }

  /**
   * Health-specific RAG for vital signs context
   */
  async retrieveHealthContext(seniorId, vitalSigns) {
    const healthQuery = `Senior ${seniorId} vital signs: HR=${vitalSigns.heartRate || '?'} SpO2=${vitalSigns.spo2 || '?'} BP=${vitalSigns.systolic || '?'}/${vitalSigns.diastolic || '?'}`;
    const results = await this.retrieve({
      query: healthQuery,
      seniorId,
      topK: 3,
      namespace: 'health_guidelines',
    });

    return this.buildContextString(results, 2000);
  }

  /**
   * Medication-specific RAG
   */
  async retrieveMedicationContext(seniorId, medicationName) {
    const results = await this.retrieve({
      query: `lek ${medicationName} dawkowanie skutki uboczne interakcje`,
      seniorId,
      topK: 3,
      namespace: 'medications',
    });

    return this.buildContextString(results, 1500);
  }

  /**
   * Delete documents by docId
   */
  async deleteDocument(docId) {
    const results = await this.collection.get({ where: { doc_id: docId } });
    if (results.ids.length > 0) {
      await this.collection.delete({ ids: results.ids });
    }
    return { docId, deleted: results.ids.length };
  }

  /**
   * Get collection stats
   */
  async getStats() {
    const count = await this.collection.count();
    return {
      totalDocuments: count,
      cacheSize: this.cache.size,
      cacheMaxSize: this.cacheMaxSize,
    };
  }
}

module.exports = new EnhancedRagService();
