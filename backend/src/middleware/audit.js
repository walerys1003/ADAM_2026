/**
 * SilverTech Agent Adam — Audit Middleware
 * Logs all administrative actions to audit_logs table
 * June 2026 — GDPR Art. 30 compliance
 */

async function auditMiddleware(request, reply) {
  // Only log mutating operations (POST, PUT, PATCH, DELETE)
  if (!['POST', 'PUT', 'PATCH', 'DELETE'].includes(request.method)) {
    return;
  }

  // Extract entity from URL pattern
  const entity = _extractEntity(request.url);
  if (!entity) return;

  // Hook into reply to log after successful response
  const originalSend = reply.send;
  reply.send = function (payload) {
    // Log asynchronously — don't block response
    _logAction(request, entity, payload).catch(err => {
      request.log.error({ err }, 'Audit log write failed');
    });

    return originalSend.call(this, payload);
  };
}

function _extractEntity(url) {
  // e.g., /api/seniors/123 → 'seniors'
  const match = url.match(/^\/api\/([a-z_-]+)/);
  return match ? match[1] : null;
}

async function _logAction(request, entity, payload) {
  const { prisma } = request.server;

  let action = 'unknown';
  switch (request.method) {
    case 'POST': action = 'create'; break;
    case 'PUT': action = 'update_full'; break;
    case 'PATCH': action = 'update_partial'; break;
    case 'DELETE': action = 'delete'; break;
  }

  // Extract entity ID from response or URL
  let entityId = null;
  try {
    const body = typeof payload === 'string' ? JSON.parse(payload) : payload;
    entityId = body?.id || null;
  } catch {
    const idMatch = request.url.match(/\/([a-f0-9-]{36})/);
    entityId = idMatch ? idMatch[1] : null;
  }

  await prisma.auditLog.create({
    data: {
      adminId: request.user?.id || null,
      action,
      entity,
      entityId,
      details: {
        method: request.method,
        url: request.url,
        ip: request.ip,
        userAgent: request.headers['user-agent'],
      },
      ipAddress: request.ip,
    },
  });
}

module.exports = auditMiddleware;
