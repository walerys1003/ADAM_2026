'use strict';

/**
 * Enhanced Guardrails Service — June 2026
 * EU AI Act (Limited Risk) compliance layer
 * 5-layer pipeline: input sanitization → PII redaction → medical safety →
 * emotional crisis detection → output moderation
 */
class EnhancedGuardrailsService {
  constructor() {
    // PII patterns (Polish-specific)
    this.piiPatterns = {
      pesel: /\b\d{11}\b/g,
      phone: /(\+48\s?)?\d{3}[\s-]?\d{3}[\s-]?\d{3}\b/g,
      email: /\b[\w.+-]+@[\w-]+\.[\w.-]+\b/g,
      address: /\bul\.\s+[A-ZĘÓĄŚŁŻŹĆŃ][a-zęóąśłżźćń]+.*?\d+/gi,
      name: null, // Context-dependent
    };

    // Crisis keywords (Polish)
    this.crisisKeywords = [
      { pattern: /samobój|nie chce mi się żyć|chcę umrzeć|odebrać sobie życie/i, level: 'CRITICAL' },
      { pattern: /upadł.*nie mogę wstać|złamał.*nogę|krew.*leci|wypadek|pogotowie/i, level: 'CRITICAL' },
      { pattern: /bardzo źle się czuję|silny ból.*klatce|nie mogę oddychać|duszno/i, level: 'HIGH' },
      { pattern: /boję się|samotn.*bardzo|nikt mnie nie odwiedza|przygnębion/i, level: 'MEDIUM' },
    ];

    // Medical safety boundaries
    this.medicalSafetyRules = [
      { pattern: /dawka|dawkowanie|ile.*brać|zwiększ.*dawkę/i, action: 'WARN_DOSAGE' },
      { pattern: /przesta.*brać.*lek|odstawi.*lek/i, action: 'WARN_DISCONTINUE' },
      { pattern: /objaw.*niepokojąc|skutek.*uboczn/i, action: 'FLAG_SYMPTOM' },
    ];

    // Output moderation - forbidden response patterns
    this.forbiddenOutputPatterns = [
      /diagnoz|choroba to|według mnie masz/i,
      /powinieneś.*odstawić|radzę.*przestać.*brać/i,
      /polecam.*lek[ui]|spróbuj.*tabletk/i,
      /to nic poważnego|nie martw się.*zdrowiem/i,
    ];
  }

  /**
   * Layer 1: Input sanitization
   */
  sanitizeInput(text) {
    if (!text || typeof text !== 'string') return { sanitized: '', issues: ['EMPTY_INPUT'] };

    let sanitized = text.trim();

    // Trim to max 2000 chars (prevent prompt injection)
    if (sanitized.length > 2000) {
      sanitized = sanitized.substring(0, 2000);
    }

    // Remove control characters
    sanitized = sanitized.replace(/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/g, '');

    // Detect prompt injection attempts
    const injectionPatterns = [
      /ignore.*instruction/i,
      /system.*prompt/i,
      /you are now/i,
      /\[INST\]|<<SYS>>/i,
    ];

    const issues = [];
    for (const p of injectionPatterns) {
      if (p.test(text)) issues.push('PROMPT_INJECTION_DETECTED');
    }

    return { sanitized, issues };
  }

  /**
   * Layer 2: PII redaction
   */
  redactPII(text) {
    let redacted = text;

    for (const [type, pattern] of Object.entries(this.piiPatterns)) {
      if (pattern) {
        redacted = redacted.replace(pattern, (match) => `[${type.toUpperCase()}]`);
      }
    }

    return {
      redacted,
      hasPII: redacted !== text,
    };
  }

  /**
   * Layer 3: Medical safety check
   */
  checkMedicalSafety(text) {
    const flags = [];

    for (const rule of this.medicalSafetyRules) {
      if (rule.pattern.test(text)) {
        flags.push({
          action: rule.action,
          severity: rule.action === 'WARN_DISCONTINUE' ? 'HIGH' : 'MEDIUM',
          message: this._getMedicalWarning(rule.action),
          timestamp: new Date().toISOString(),
        });
      }
    }

    return { flags, requiresEscalation: flags.some(f => f.severity === 'HIGH') };
  }

  /**
   * Layer 4: Emotional crisis detection
   */
  detectCrisis(text, seniorSemafor = 'GREEN') {
    const detectedLevels = [];

    for (const kw of this.crisisKeywords) {
      if (kw.pattern.test(text)) {
        detectedLevels.push(kw.level);
      }
    }

    // Determine escalation
    const hasCritical = detectedLevels.includes('CRITICAL');
    const hasHigh = detectedLevels.includes('HIGH');
    const hasMedium = detectedLevels.includes('MEDIUM');

    let recommendedLevel = null;
    if (hasCritical) recommendedLevel = 'RED';
    else if (hasHigh) recommendedLevel = 'ORANGE';
    else if (hasMedium) recommendedLevel = 'YELLOW';

    // Only escalate if new level is higher than current
    const semaforOrder = { GREEN: 0, YELLOW: 1, ORANGE: 2, RED: 3, PURPLE: 4 };
    const shouldEscalate = recommendedLevel &&
      (semaforOrder[recommendedLevel] || 0) > (semaforOrder[seniorSemafor] || 0);

    return {
      detectedLevels: [...new Set(detectedLevels)],
      recommendedLevel,
      shouldEscalate,
      seniorSemafor,
      requiresImmediateAction: hasCritical,
    };
  }

  /**
   * Layer 5: Output moderation
   */
  moderateOutput(response) {
    const violations = [];

    for (const pattern of this.forbiddenOutputPatterns) {
      if (pattern.test(response)) {
        violations.push({
          pattern: pattern.source,
          severity: 'BLOCK',
        });
      }
    }

    if (violations.length > 0) {
      return {
        passed: false,
        violations,
        safeResponse: 'Przepraszam, nie mogę udzielić porady medycznej. '
          + 'Proszę skontaktować się z lekarzem prowadzącym lub zadzwonić '
          + 'pod numer 112 w nagłych przypadkach.',
      };
    }

    return { passed: true, violations: [] };
  }

  /**
   * Full pipeline execution
   */
  async executePipeline({ userInput, seniorId, seniorSemafor, conversationType }) {
    const pipelineResult = {
      seniorId,
      conversationType,
      timestamp: new Date().toISOString(),
      layers: {},
      passed: true,
      escalationNeeded: false,
      newSemaforLevel: null,
    };

    // Layer 1: Sanitize
    const { sanitized, issues } = this.sanitizeInput(userInput);
    pipelineResult.layers.sanitization = { issues };

    // Layer 2: PII
    const { redacted, hasPII } = this.redactPII(sanitized);
    pipelineResult.layers.pii = { hasPII, redacted };

    // Layer 3: Medical safety
    const medicalCheck = this.checkMedicalSafety(redacted);
    pipelineResult.layers.medical = medicalCheck;
    if (medicalCheck.requiresEscalation) {
      pipelineResult.passed = false;
    }

    // Layer 4: Crisis detection
    const crisisResult = this.detectCrisis(redacted, seniorSemafor);
    pipelineResult.layers.crisis = crisisResult;
    if (crisisResult.shouldEscalate) {
      pipelineResult.escalationNeeded = true;
      pipelineResult.newSemaforLevel = crisisResult.recommendedLevel;
    }
    if (crisisResult.requiresImmediateAction) {
      pipelineResult.passed = false;
    }

    return pipelineResult;
  }

  _getMedicalWarning(action) {
    const warnings = {
      WARN_DOSAGE: 'Senior pyta o dawkowanie leków — sugeruj konsultację z lekarzem, nie podawaj konkretnych dawek.',
      WARN_DISCONTINUE: 'Senior rozważa odstawienie leku — eskalacja do rodziny i lekarza prowadzącego.',
      FLAG_SYMPTOM: 'Senior zgłasza niepokojące objawy — zalecenie kontaktu z lekarzem.',
    };
    return warnings[action] || 'Wymagana ostrożność medyczna.';
  }
}

module.exports = new EnhancedGuardrailsService();
