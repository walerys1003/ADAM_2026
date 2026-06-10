/**
 * SilverTech Agent Adam — Authentication Routes
 * JWT auth with refresh token rotation, role-based access
 */

const crypto = require('crypto');

async function authRoutes(fastify, options) {
  const { prisma } = fastify;

  // Simple password hash (production: use bcrypt/argon2)
  function hashPassword(password) {
    return crypto.createHash('sha256').update(password + (process.env.PASSWORD_SALT || 'adam-salt')).digest('hex');
  }

  function generateTokens(userId, role) {
    const accessToken = fastify.jwt.sign({ id: userId, role }, { expiresIn: '24h' });
    const refreshToken = crypto.randomBytes(48).toString('hex');
    return { accessToken, refreshToken };
  }

  // ── Register ──────────────────────────────────────────
  fastify.post('/register', async (request, reply) => {
    const { email, password, firstName, lastName, role } = request.body;

    const existing = await prisma.user.findUnique({ where: { email } });
    if (existing) {
      return reply.code(409).send({ error: 'Email already registered' });
    }

    const user = await prisma.user.create({
      data: {
        email,
        passwordHash: hashPassword(password),
        role: role || 'SENIOR',
      },
    });

    const tokens = generateTokens(user.id, user.role);

    await prisma.refreshToken.create({
      data: {
        userId: user.id,
        token: tokens.refreshToken,
        expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
      },
    });

    reply.code(201).send({
      user: { id: user.id, email: user.email, role: user.role },
      ...tokens,
    });
  });

  // ── Login ─────────────────────────────────────────────
  fastify.post('/login', async (request, reply) => {
    const { email, password } = request.body;

    const user = await prisma.user.findUnique({
      where: { email },
      include: {
        seniorProfile: { select: { id: true, firstName: true, lastName: true } },
        familyProfile: { select: { id: true, firstName: true, lastName: true } },
        adminProfile: { select: { id: true, firstName: true, lastName: true } },
      },
    });

    if (!user || user.passwordHash !== hashPassword(password)) {
      return reply.code(401).send({ error: 'Invalid credentials' });
    }

    const tokens = generateTokens(user.id, user.role);

    await prisma.refreshToken.create({
      data: {
        userId: user.id,
        token: tokens.refreshToken,
        expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
      },
    });

    await prisma.user.update({
      where: { id: user.id },
      data: { lastLoginAt: new Date() },
    });

    reply.send({
      user: {
        id: user.id,
        email: user.email,
        role: user.role,
        profile: user.seniorProfile || user.familyProfile || user.adminProfile,
      },
      ...tokens,
    });
  });

  // ── Refresh Token ─────────────────────────────────────
  fastify.post('/refresh', async (request, reply) => {
    const { refreshToken } = request.body;

    const stored = await prisma.refreshToken.findUnique({
      where: { token: refreshToken },
      include: { user: { select: { id: true, role: true } } },
    });

    if (!stored || stored.expiresAt < new Date()) {
      return reply.code(401).send({ error: 'Invalid or expired refresh token' });
    }

    // Delete old token
    await prisma.refreshToken.delete({ where: { id: stored.id } });

    // Generate new pair
    const tokens = generateTokens(stored.user.id, stored.user.role);

    await prisma.refreshToken.create({
      data: {
        userId: stored.user.id,
        token: tokens.refreshToken,
        expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
      },
    });

    reply.send(tokens);
  });

  // ── Logout ────────────────────────────────────────────
  fastify.post('/logout', {
    preHandler: [fastify.authenticate],
  }, async (request) => {
    await prisma.refreshToken.deleteMany({
      where: { userId: request.user.id },
    });
    return { message: 'Logged out successfully' };
  });

  // ── Me ────────────────────────────────────────────────
  fastify.get('/me', {
    preHandler: [fastify.authenticate],
  }, async (request) => {
    const user = await prisma.user.findUnique({
      where: { id: request.user.id },
      select: { id: true, email: true, role: true, createdAt: true, lastLoginAt: true },
    });
    return user;
  });
}

module.exports = authRoutes;
