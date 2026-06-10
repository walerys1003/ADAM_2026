'use strict';

const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'senior-companion-dev-secret-change-in-production';
const JWT_REFRESH_SECRET = process.env.JWT_REFRESH_SECRET || 'senior-companion-refresh-secret-change-in-production';
const TOKEN_EXPIRY = '24h';
const REFRESH_TOKEN_EXPIRY = '7d';

/**
 * Authentication middleware for Fastify.
 * Supports:
 * - JWT Bearer token authentication
 * - Role-based access control (RBAC)
 * - Token refresh flow
 * - API key auth for service-to-service calls
 */

/**
 * Verify JWT access token from Authorization header.
 * Attaches decoded payload to request.user.
 */
async function authenticate(request, reply) {
  const authHeader = request.headers.authorization;

  if (!authHeader) {
    return reply.status(401).send({
      error: 'UNAUTHORIZED',
      message: 'Brak tokenu autoryzacyjnego. Zaloguj się ponownie.',
    });
  }

  // Support both "Bearer <token>" and API key "ApiKey <key>"
  const parts = authHeader.split(' ');

  if (parts.length !== 2) {
    return reply.status(401).send({
      error: 'INVALID_AUTH_HEADER',
      message: 'Nieprawidłowy format nagłówka autoryzacyjnego.',
    });
  }

  const [scheme, credentials] = parts;

  if (scheme === 'ApiKey') {
    return authenticateApiKey(credentials, request, reply);
  }

  if (scheme !== 'Bearer') {
    return reply.status(401).send({
      error: 'INVALID_SCHEME',
      message: 'Obsługiwane schematy: Bearer, ApiKey.',
    });
  }

  try {
    const decoded = jwt.verify(credentials, JWT_SECRET);
    request.user = decoded;

    // Check if token is about to expire (< 5 min remaining)
    const now = Math.floor(Date.now() / 1000);
    if (decoded.exp && decoded.exp - now < 300) {
      reply.header('X-Token-Expiring', 'true');
    }
  } catch (err) {
    if (err.name === 'TokenExpiredError') {
      return reply.status(401).send({
        error: 'TOKEN_EXPIRED',
        message: 'Token wygasł. Użyj tokenu odświeżania.',
      });
    }
    return reply.status(401).send({
      error: 'INVALID_TOKEN',
      message: 'Nieprawidłowy token autoryzacyjny.',
    });
  }
}

/**
 * Verify API key for service-to-service calls.
 */
async function authenticateApiKey(apiKey, request, reply) {
  const validApiKeys = (process.env.API_KEYS || '').split(',').filter(Boolean);

  // In development, accept 'dev-api-key'
  if (process.env.NODE_ENV === 'development' && apiKey === 'dev-api-key') {
    request.user = {
      id: 'service',
      role: 'SERVICE',
      email: 'service@agent-adam.local',
    };
    return;
  }

  if (!validApiKeys.includes(apiKey)) {
    return reply.status(401).send({
      error: 'INVALID_API_KEY',
      message: 'Nieprawidłowy klucz API.',
    });
  }

  request.user = {
    id: 'service',
    role: 'SERVICE',
    email: 'service@agent-adam.local',
  };
}

/**
 * Role-based access control middleware factory.
 *
 * Usage:
 *   fastify.get('/admin', { preHandler: [authenticate, requireRole('ADMIN')] }, handler)
 */
function requireRole(...allowedRoles) {
  return async function (request, reply) {
    if (!request.user) {
      return reply.status(401).send({
        error: 'UNAUTHORIZED',
        message: 'Wymagane uwierzytelnienie.',
      });
    }

    if (!allowedRoles.includes(request.user.role)) {
      return reply.status(403).send({
        error: 'FORBIDDEN',
        message: `Brak uprawnień. Wymagana rola: ${allowedRoles.join(' lub ')}.`,
      });
    }
  };
}

/**
 * Require that the user is accessing their own data or is an admin.
 * Compares request.user.id with the :seniorId param.
 */
async function requireOwnSeniorOrAdmin(request, reply) {
  if (!request.user) {
    return reply.status(401).send({
      error: 'UNAUTHORIZED',
      message: 'Wymagane uwierzytelnienie.',
    });
  }

  const seniorId = request.params.seniorId || request.body.seniorId;

  // Admins can access any senior's data
  if (request.user.role === 'ADMIN') return;

  // Family members can only access their linked seniors
  if (request.user.role === 'FAMILY') {
    // In production: verify senior-family link via Prisma
    // For now, accept if seniorId matches or is in user's linkedSeniors
    if (request.user.linkedSeniors && request.user.linkedSeniors.includes(seniorId)) {
      return;
    }
  }

  // Seniors can only access their own data
  if (request.user.role === 'SENIOR' && request.user.id === seniorId) {
    return;
  }

  return reply.status(403).send({
    error: 'FORBIDDEN',
    message: 'Brak dostępu do danych tego seniora.',
  });
}

/**
 * Generate access token for a user.
 */
function generateAccessToken(user) {
  return jwt.sign(
    {
      id: user.id,
      email: user.email,
      role: user.role,
      linkedSeniors: user.linkedSeniors || [],
    },
    JWT_SECRET,
    { expiresIn: TOKEN_EXPIRY }
  );
}

/**
 * Generate refresh token for a user.
 */
function generateRefreshToken(user) {
  return jwt.sign(
    {
      id: user.id,
      type: 'refresh',
    },
    JWT_REFRESH_SECRET,
    { expiresIn: REFRESH_TOKEN_EXPIRY }
  );
}

/**
 * Refresh token endpoint handler.
 * Validates refresh token and issues new access + refresh token pair.
 */
async function refreshTokenHandler(request, reply) {
  const { refreshToken } = request.body;

  if (!refreshToken) {
    return reply.status(400).send({
      error: 'MISSING_TOKEN',
      message: 'Brak tokenu odświeżania.',
    });
  }

  try {
    const decoded = jwt.verify(refreshToken, JWT_REFRESH_SECRET);

    if (decoded.type !== 'refresh') {
      return reply.status(401).send({
        error: 'INVALID_TOKEN_TYPE',
        message: 'Nieprawidłowy typ tokenu.',
      });
    }

    // In production: check token in DB revocation list
    // const isRevoked = await checkTokenRevocation(refreshToken);
    // if (isRevoked) throw new Error('Token revoked');

    // In production: fetch fresh user data from DB
    const user = {
      id: decoded.id,
      email: 'user@example.com',
      role: 'SENIOR',
    };

    const newAccessToken = generateAccessToken(user);
    const newRefreshToken = generateRefreshToken(user);

    return reply.send({
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
      expiresIn: 86400, // 24h in seconds
    });
  } catch (err) {
    return reply.status(401).send({
      error: 'INVALID_REFRESH_TOKEN',
      message: 'Nieprawidłowy lub wygasły token odświeżania.',
    });
  }
}

/**
 * Validate token without rejecting — used for optional auth.
 */
async function optionalAuth(request, reply) {
  const authHeader = request.headers.authorization;
  if (!authHeader) return;

  const parts = authHeader.split(' ');
  if (parts.length !== 2 || parts[0] !== 'Bearer') return;

  try {
    const decoded = jwt.verify(parts[1], JWT_SECRET);
    request.user = decoded;
  } catch (_) {
    // Token invalid — continue without auth
  }
}

module.exports = {
  authenticate,
  requireRole,
  requireOwnSeniorOrAdmin,
  optionalAuth,
  generateAccessToken,
  generateRefreshToken,
  refreshTokenHandler,
};
