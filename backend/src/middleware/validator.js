'use strict';

/**
 * Request validation middleware for Fastify.
 * Provides common validation patterns for:
 * - UUID format
 * - Polish phone numbers
 * - PESEL numbers
 * - Email format
 * - Date ranges
 * - Pagination parameters
 * - Enum values
 */

/**
 * Validate that a route parameter is a valid UUID v4.
 */
function validateUUID(paramName) {
  return async function (request, reply) {
    const value = request.params[paramName];
    const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

    if (!value || !uuidRegex.test(value)) {
      return reply.status(400).send({
        error: 'INVALID_PARAM',
        message: `Parametr '${paramName}' musi być poprawnym UUID.`,
        param: paramName,
        received: value,
      });
    }
  };
}

/**
 * Validate Polish phone number format.
 * Accepts: +48XXXXXXXXX, 48XXXXXXXXX, XXX-XXX-XXX, XXXXXXXXX
 */
function validatePolishPhone(value) {
  if (!value) return false;
  const cleaned = value.replace(/[\s\-\(\)]/g, '');
  // +48 followed by 9 digits, or 9 digits
  return /^(\+?48)?\d{9}$/.test(cleaned);
}

/**
 * Validate PESEL number (Polish personal ID).
 * 11 digits with checksum validation.
 */
function validatePESEL(value) {
  if (!value || !/^\d{11}$/.test(value)) return false;

  const weights = [1, 3, 7, 9, 1, 3, 7, 9, 1, 3];
  let sum = 0;

  for (let i = 0; i < 10; i++) {
    sum += parseInt(value[i]) * weights[i];
  }

  const checksum = (10 - (sum % 10)) % 10;
  return checksum === parseInt(value[10]);
}

/**
 * Validate date string in ISO format.
 */
function validateISODate(value) {
  if (!value) return false;
  const date = new Date(value);
  return !isNaN(date.getTime());
}

/**
 * Validate that a date range is valid (start <= end).
 */
function validateDateRange(startDate, endDate) {
  if (!startDate || !endDate) return false;
  return new Date(startDate) <= new Date(endDate);
}

/**
 * Validate pagination parameters.
 */
function validatePagination(query) {
  const page = parseInt(query.page) || 1;
  const limit = Math.min(parseInt(query.limit) || 20, 100);

  if (page < 1 || limit < 1) {
    return { valid: false, error: 'Page and limit must be positive integers' };
  }

  return { valid: true, page, limit, offset: (page - 1) * limit };
}

/**
 * Validate enum value.
 */
function validateEnum(value, allowedValues, fieldName = 'value') {
  if (!allowedValues.includes(value)) {
    return {
      valid: false,
      error: `'${fieldName}' must be one of: ${allowedValues.join(', ')}`,
    };
  }
  return { valid: true };
}

/**
 * Sanitize string input — trim and limit length.
 */
function sanitizeString(value, maxLength = 500) {
  if (typeof value !== 'string') return value;
  return value.trim().substring(0, maxLength);
}

/**
 * Validate body fields middleware.
 * Checks required fields and their formats.
 *
 * Usage:
 *   fastify.post('/api/seniors', {
 *     preHandler: [validateBody({
 *       firstName: { required: true, type: 'string', maxLength: 100 },
 *       email: { required: true, type: 'email' },
 *       phone: { required: true, type: 'phone' },
 *     })]
 *   }, handler)
 */
function validateBody(fieldRules) {
  return async function (request, reply) {
    const errors = [];

    for (const [field, rules] of Object.entries(fieldRules)) {
      const value = request.body[field];

      // Required check
      if (rules.required && (value === undefined || value === null || value === '')) {
        errors.push(`Pole '${field}' jest wymagane.`);
        continue;
      }

      // Skip further validation if optional and empty
      if (!rules.required && (value === undefined || value === null)) {
        continue;
      }

      // Type-specific validation
      if (value !== undefined && value !== null) {
        switch (rules.type) {
          case 'string':
            if (typeof value !== 'string') {
              errors.push(`Pole '${field}' musi być tekstem.`);
            } else if (rules.maxLength && value.length > rules.maxLength) {
              errors.push(`Pole '${field}' nie może przekraczać ${rules.maxLength} znaków.`);
            }
            break;

          case 'email':
            if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)) {
              errors.push(`Pole '${field}' musi być poprawnym adresem email.`);
            }
            break;

          case 'phone':
            if (!validatePolishPhone(value)) {
              errors.push(`Pole '${field}' musi być poprawnym polskim numerem telefonu.`);
            }
            break;

          case 'number':
            if (typeof value !== 'number' || isNaN(value)) {
              errors.push(`Pole '${field}' musi być liczbą.`);
            } else {
              if (rules.min !== undefined && value < rules.min) {
                errors.push(`Pole '${field}' nie może być mniejsze niż ${rules.min}.`);
              }
              if (rules.max !== undefined && value > rules.max) {
                errors.push(`Pole '${field}' nie może być większe niż ${rules.max}.`);
              }
            }
            break;

          case 'date':
            if (!validateISODate(value)) {
              errors.push(`Pole '${field}' musi być poprawną datą ISO.`);
            }
            break;

          case 'uuid':
            if (!/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(value)) {
              errors.push(`Pole '${field}' musi być poprawnym UUID.`);
            }
            break;

          case 'boolean':
            if (typeof value !== 'boolean') {
              errors.push(`Pole '${field}' musi być wartością logiczną.`);
            }
            break;

          case 'array':
            if (!Array.isArray(value)) {
              errors.push(`Pole '${field}' musi być tablicą.`);
            }
            break;
        }
      }
    }

    if (errors.length > 0) {
      return reply.status(400).send({
        error: 'VALIDATION_ERROR',
        message: 'Nieprawidłowe dane wejściowe.',
        details: errors,
      });
    }
  };
}

/**
 * Validate query parameters middleware.
 */
function validateQuery(paramRules) {
  return async function (request, reply) {
    const errors = [];

    for (const [param, rules] of Object.entries(paramRules)) {
      const value = request.query[param];

      if (rules.required && (value === undefined || value === '')) {
        errors.push(`Parametr '${param}' jest wymagany.`);
        continue;
      }

      if (value !== undefined && value !== '') {
        switch (rules.type) {
          case 'number':
            const num = Number(value);
            if (isNaN(num)) {
              errors.push(`Parametr '${param}' musi być liczbą.`);
            } else {
              if (rules.min !== undefined && num < rules.min) {
                errors.push(`Parametr '${param}' nie może być mniejszy niż ${rules.min}.`);
              }
              if (rules.max !== undefined && num > rules.max) {
                errors.push(`Parametr '${param}' nie może być większy niż ${rules.max}.`);
              }
            }
            break;

          case 'date':
            if (!validateISODate(value)) {
              errors.push(`Parametr '${param}' musi być poprawną datą.`);
            }
            break;

          case 'enum':
            const enumResult = validateEnum(value, rules.values, param);
            if (!enumResult.valid) {
              errors.push(enumResult.error);
            }
            break;
        }
      }
    }

    if (errors.length > 0) {
      return reply.status(400).send({
        error: 'INVALID_QUERY',
        message: 'Nieprawidłowe parametry zapytania.',
        details: errors,
      });
    }
  };
}

module.exports = {
  validateUUID,
  validateBody,
  validateQuery,
  validatePolishPhone,
  validatePESEL,
  validateISODate,
  validateDateRange,
  validatePagination,
  validateEnum,
  sanitizeString,
};
