'use strict';

/**
 * Embeddings Service for Agent Adam.
 *
 * Generates text embeddings for:
 * - RAG (Retrieval-Augmented Generation) document indexing
 * - Semantic similarity search in conversation history
 * - Guardrails safety classification
 * - Mood and topic clustering
 *
 * Uses OpenAI text-embedding-3-small by default (cost-optimized).
 * Fallback: local sentence-transformers via Transformers.js.
 */

class EmbeddingsService {
  constructor(config = {}) {
    this.provider = config.provider || 'openai';
    this.model = config.model || 'text-embedding-3-small';
    this.dimensions = config.dimensions || 1536;
    this.batchSize = config.batchSize || 100;
    this.cacheEnabled = config.cacheEnabled !== false;

    // Simple in-memory cache for frequent embeddings
    this.cache = new Map();
    this.cacheMaxSize = 1000;
  }

  /**
   * Generate embedding for a single text string.
   */
  async embedText(text) {
    if (!text || text.trim().length === 0) {
      throw new Error('Cannot embed empty text');
    }

    // Check cache
    const cacheKey = this._cacheKey(text);
    if (this.cacheEnabled && this.cache.has(cacheKey)) {
      return this.cache.get(cacheKey);
    }

    try {
      let embedding;

      switch (this.provider) {
        case 'openai':
          embedding = await this._embedOpenAI([text]);
          break;
        case 'local':
          embedding = await this._embedLocal([text]);
          break;
        default:
          throw new Error(`Unknown embedding provider: ${this.provider}`);
      }

      const vector = embedding[0];

      // Cache the result
      if (this.cacheEnabled) {
        this._addToCache(cacheKey, vector);
      }

      return vector;
    } catch (err) {
      throw new Error(`Embedding generation failed: ${err.message}`);
    }
  }

  /**
   * Generate embeddings for multiple texts in batch.
   */
  async embedBatch(texts) {
    if (!texts || texts.length === 0) {
      return [];
    }

    const results = [];
    const toEmbed = [];
    const indices = [];

    // Check cache first
    for (let i = 0; i < texts.length; i++) {
      const cacheKey = this._cacheKey(texts[i]);
      if (this.cacheEnabled && this.cache.has(cacheKey)) {
        results[i] = this.cache.get(cacheKey);
      } else {
        toEmbed.push(texts[i]);
        indices.push(i);
      }
    }

    if (toEmbed.length === 0) return results;

    // Embed uncached texts in batches
    for (let i = 0; i < toEmbed.length; i += this.batchSize) {
      const batch = toEmbed.slice(i, i + this.batchSize);
      const batchIndices = indices.slice(i, i + this.batchSize);

      let embeddings;

      switch (this.provider) {
        case 'openai':
          embeddings = await this._embedOpenAI(batch);
          break;
        case 'local':
          embeddings = await this._embedLocal(batch);
          break;
        default:
          throw new Error(`Unknown embedding provider: ${this.provider}`);
      }

      for (let j = 0; j < embeddings.length; j++) {
        const idx = batchIndices[j];
        results[idx] = embeddings[j];

        if (this.cacheEnabled) {
          this._addToCache(this._cacheKey(batch[j]), embeddings[j]);
        }
      }
    }

    return results;
  }

  /**
   * Compute cosine similarity between two vectors.
   */
  cosineSimilarity(vecA, vecB) {
    if (vecA.length !== vecB.length) {
      throw new Error('Vectors must have same dimensions');
    }

    let dotProduct = 0;
    let normA = 0;
    let normB = 0;

    for (let i = 0; i < vecA.length; i++) {
      dotProduct += vecA[i] * vecB[i];
      normA += vecA[i] * vecA[i];
      normB += vecB[i] * vecB[i];
    }

    if (normA === 0 || normB === 0) return 0;

    return dotProduct / (Math.sqrt(normA) * Math.sqrt(normB));
  }

  /**
   * Find most similar texts from a corpus.
   */
  async findSimilar(query, corpus, topK = 5) {
    const queryEmbedding = await this.embedText(query);
    const corpusEmbeddings = await this.embedBatch(corpus);

    const similarities = corpusEmbeddings.map((emb, idx) => ({
      index: idx,
      text: corpus[idx],
      similarity: this.cosineSimilarity(queryEmbedding, emb),
    }));

    similarities.sort((a, b) => b.similarity - a.similarity);

    return similarities.slice(0, topK);
  }

  /**
   * Index documents for RAG by generating and storing embeddings.
   */
  async indexDocuments(documents, storeFn) {
    const texts = documents.map((doc) => doc.content);
    const embeddings = await this.embedBatch(texts);

    const indexed = [];

    for (let i = 0; i < documents.length; i++) {
      const doc = {
        ...documents[i],
        embedding: embeddings[i],
        indexedAt: new Date().toISOString(),
      };

      if (storeFn) {
        await storeFn(doc);
      }

      indexed.push(doc);
    }

    return indexed;
  }

  // ---- Provider Implementations ----

  async _embedOpenAI(texts) {
    const apiKey = process.env.OPENAI_API_KEY;
    if (!apiKey) {
      throw new Error('OPENAI_API_KEY not configured');
    }

    const response = await fetch('https://api.openai.com/v1/embeddings', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${apiKey}`,
      },
      body: JSON.stringify({
        model: this.model,
        input: texts,
        dimensions: this.dimensions,
      }),
    });

    if (!response.ok) {
      const error = await response.json().catch(() => ({}));
      throw new Error(`OpenAI API error: ${response.status} ${error.error?.message || ''}`);
    }

    const data = await response.json();
    return data.data.map((item) => item.embedding);
  }

  async _embedLocal(texts) {
    // In production: use @xenova/transformers with sentence-transformers
    // For development, return random vectors as placeholder
    console.log(`[EMBEDDINGS] Local embedding ${texts.length} texts (placeholder)`);

    return texts.map(() => {
      // Generate deterministic "random" vector based on text hash
      return Array.from({ length: this.dimensions }, (_, i) =>
        Math.sin(texts.length * i * 0.01) * 0.1
      );
    });
  }

  // ---- Cache Management ----

  _cacheKey(text) {
    // Simple hash for cache key
    let hash = 0;
    for (let i = 0; i < text.length; i++) {
      const char = text.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash |= 0;
    }
    return `${this.model}:${hash}`;
  }

  _addToCache(key, vector) {
    if (this.cache.size >= this.cacheMaxSize) {
      // Evict oldest entry (FIFO)
      const firstKey = this.cache.keys().next().value;
      this.cache.delete(firstKey);
    }
    this.cache.set(key, vector);
  }

  /**
   * Clear the embedding cache.
   */
  clearCache() {
    this.cache.clear();
  }

  /**
   * Get cache statistics.
   */
  getCacheStats() {
    return {
      size: this.cache.size,
      maxSize: this.cacheMaxSize,
      model: this.model,
      provider: this.provider,
    };
  }
}

module.exports = EmbeddingsService;
