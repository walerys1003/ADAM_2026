'use strict';

/**
 * Structured request/response logger middleware for Fastify.
 *
 * Logs:
 * - Request method, URL, headers, query params
 * - Response status code, latency
 * - User info (if authenticated)
 * - Request body for debugging (sanitized)
 *
 * Integrates with:
 * - Prometheus metrics (request count, latency histogram)
 * - Grafana Loki (structured log aggregation)
 * - Alerting (slow request detection > 3000ms)
 */

const SENSITIVE_FIELDS = [
  'password', 'token', 'accessToken', 'refreshToken',
  'secret', 'apiKey', 'authorization', 'cookie',
  'creditCard', 'ssn', 'pesel',
];

const SENSITIVE_HEADERS = [
  'authorization', 'cookie', 'x-api-key', 'x-auth-token',
];

/**
 * Sanitize an object by redacting sensitive fields.
 */
function sanitize(obj, sensitiveKeys = SENSITIVE_FIELDS) {
  if (!obj || typeof obj !== 'object') return obj;

  const sanitized = Array.isArray(obj) ? [...obj] : { ...obj };

  for (const key of Object.keys(sanitized)) {
    const lowerKey = key.toLowerCase();
    if (sensitiveKeys.some((s) => lowerKey.includes(s))) {
      sanitized[key] = '[REDACTED]';
    } else if (typeof sanitized[key] === 'object' && sanitized[key] !== null) {
      sanitized[key] = sanitize(sanitized[key], sensitiveKeys);
    }
  }

  return sanitized;
}

/**
 * Calculate request latency in milliseconds.
 */
function getLatency(startTime) {
  const diff = process.hrtime(startTime);
  return Math.round((diff[0] * 1e9 + diff[1]) / 1e6);
}

/**
 * Determine log level based on status code.
 */
function getLogLevel(statusCode) {
  if (statusCode >= 500) return 'error';
  if (statusCode >= 400) return 'warn';
  return 'info';
}

/**
 * Build structured log entry.
 */
function buildLogEntry(request, reply, latency, startTime) {
  const entry = {
    timestamp: new Date().toISOString(),
    level: getLogLevel(reply.statusCode),
    message: `${request.method} ${request.url} ${reply.statusCode} ${latency}ms`,
    request: {
      id: request.id,
      method: request.method,
      url: request.url,
      path: request.routerPath || request.url,
      query: sanitize(request.query),
      params: sanitize(request.params),
      headers: sanitize(request.headers, SENSITIVE_HEADERS),
      ip: request.ip,
      userAgent: request.headers['user-agent'],
    },
    response: {
      statusCode: reply.statusCode,
      latencyMs: latency,
      contentLength: reply.getHeader('content-length') || 0,
    },
    context: {},
  };

  // Add user context if authenticated
  if (request.user) {
    entry.context.user = {
      id: request.user.id,
      role: request.user.role,
      email: request.user.email,
    };
  }

  // Tag slow requests for alerting
  if (latency > 3000) {
    entry.level = 'warn';
    entry.message = `SLOW REQUEST: ${entry.message}`;
    entry.context.slowRequest = true;
  }

  // Tag very slow requests as errors
  if (latency > 10000) {
    entry.level = 'error';
    entry.message = `VERY SLOW REQUEST: ${entry.message}`;
  }

  return entry;
}

/**
 * Main request logger middleware.
 */
async function requestLogger(request, reply) {
  const startTime = process.hrtime();

  // Log request body for non-GET requests (sanitized)
  if (request.body && request.method !== 'GET') {
    const sanitizedBody = sanitize(request.body);
    request.log.info(
      { body: sanitizedBody },
      `→ ${request.method} ${request.url}`
    );
  } else {
    request.log.info(`→ ${request.method} ${request.url}`);
  }

  // Hook into the response 'finish' event
  reply.then(
    () => {
      const latency = getLatency(startTime);
      const entry = buildLogEntry(request, reply, latency, startTime);

      // Use appropriate log level
      const logger = request.log[entry.level] || request.log.info;
      logger.call(request.log, entry);

      // Track metrics (if Prometheus client is available)
      trackMetrics(request, reply, latency);
    },
    (err) => {
      const latency = getLatency(startTime);
      request.log.error(
        {
          error: err.message,
          stack: err.stack,
          latencyMs: latency,
        },
        `✗ ${request.method} ${request.url} ERROR ${latency}ms`
      );
    }
  );
}

/**
 * Track Prometheus metrics (if configured).
 */
function trackMetrics(request, reply, latency) {
  try {
    // Use global metrics if available — these will be no-ops if not configured
    if (global.prometheusMetrics) {
      const { httpRequestCounter, httpRequestDuration } = global.prometheusMetrics;
      const route = request.routerPath || 'unknown';

      if (httpRequestCounter) {
        httpRequestCounter
          .labels(request.method, route, String(reply.statusCode))
          .inc();
      }

      if (httpRequestDuration) {
        httpRequestDuration
          .labels(request.method, route, String(reply.statusCode))
          .observe(latency / 1000);
      }
    }
  } catch (_) {
    // Metrics tracking should never break the request
  }
}

/**
 * Error logger — logs unhandled errors with full stack traces.
 */
function errorLogger(error, request, reply) {
  request.log.error(
    {
      error: {
        message: error.message,
        name: error.name,
        code: error.code,
        stack: error.stack,
        statusCode: error.statusCode || 500,
      },
      request: {
        id: request.id,
        method: request.method,
        url: request.url,
        user: request.user ? { id: request.user.id, role: request.user.role } : null,
      },
    },
    `UNHANDLED ERROR: ${error.message}`
  );

  return reply.status(error.statusCode || 500).send({
    error: error.name || 'INTERNAL_ERROR',
    message: process.env.NODE_ENV === 'production'
      ? 'Wystąpił nieoczekiwany błąd. Spróbuj ponownie później.'
      : error.message,
  });
}

module.exports = {
  requestLogger,
  errorLogger,
  sanitize,
};
