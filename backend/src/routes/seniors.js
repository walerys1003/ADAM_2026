/**
 * SilverTech Agent Adam — Seniors CRUD Routes
 * Full REST API with search, filtering, semafor management
 */

async function seniorRoutes(fastify, options) {
  const { prisma } = fastify;

  // ── List all seniors (admin) ──────────────────────────
  fastify.get('/', {
    preHandler: [fastify.authenticate],
    schema: {
      querystring: {
        type: 'object',
        properties: {
          page: { type: 'integer', default: 1 },
          limit: { type: 'integer', default: 20 },
          search: { type: 'string' },
          semafor: { type: 'string', enum: ['GREEN', 'YELLOW', 'ORANGE', 'RED', 'PURPLE'] },
          package: { type: 'string', enum: ['KONTAKT', 'ZDROWIE', 'AKTYWNY'] },
          isActive: { type: 'boolean' },
          sortBy: { type: 'string', default: 'last_name' },
          sortDir: { type: 'string', enum: ['asc', 'desc'], default: 'asc' },
        },
      },
    },
  }, async (request) => {
    const { page, limit, search, semafor, package: pkg, isActive, sortBy, sortDir } = request.query;
    const skip = (page - 1) * limit;

    const where = {};
    if (semafor) where.semaforLevel = semafor;
    if (pkg) where.package = pkg;
    if (isActive !== undefined) where.isActive = isActive;
    if (search) {
      where.OR = [
        { firstName: { contains: search, mode: 'insensitive' } },
        { lastName: { contains: search, mode: 'insensitive' } },
        { phone: { contains: search } },
        { city: { contains: search, mode: 'insensitive' } },
      ];
    }

    const [seniors, total] = await Promise.all([
      prisma.senior.findMany({
        where,
        skip,
        take: limit,
        orderBy: { [sortBy]: sortDir },
        select: {
          id: true,
          firstName: true,
          lastName: true,
          phone: true,
          city: true,
          semaforLevel: true,
          package: true,
          wearableConnected: true,
          lastConversation: true,
          lastHealthCheck: true,
          isActive: true,
          _count: { select: { alerts: { where: { isResolved: false } } } },
        },
      }),
      prisma.senior.count({ where }),
    ]);

    return {
      data: seniors,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit),
      },
    };
  });

  // ── Get single senior by ID ───────────────────────────
  fastify.get('/:id', {
    preHandler: [fastify.authenticate],
  }, async (request, reply) => {
    const senior = await prisma.senior.findUnique({
      where: { id: request.params.id },
      include: {
        medications: { where: { isActive: true } },
        familyMembers: true,
        _count: {
          select: {
            conversations: true,
            alerts: { where: { isResolved: false } },
            marketplaceOrders: true,
          },
        },
      },
    });

    if (!senior) {
      return reply.code(404).send({ error: 'Senior not found' });
    }

    return senior;
  });

  // ── Create senior ─────────────────────────────────────
  fastify.post('/', {
    preHandler: [fastify.authenticate],
  }, async (request, reply) => {
    const senior = await prisma.senior.create({
      data: request.body,
    });
    reply.code(201).send(senior);
  });

  // ── Update senior ─────────────────────────────────────
  fastify.patch('/:id', {
    preHandler: [fastify.authenticate],
  }, async (request) => {
    return prisma.senior.update({
      where: { id: request.params.id },
      data: request.body,
    });
  });

  // ── Deactivate senior (soft delete) ──────────────────
  fastify.delete('/:id', {
    preHandler: [fastify.authenticate],
  }, async (request) => {
    return prisma.senior.update({
      where: { id: request.params.id },
      data: { isActive: false },
    });
  });

  // ── Update semafor level ──────────────────────────────
  fastify.patch('/:id/semafor', {
    preHandler: [fastify.authenticate],
  }, async (request, reply) => {
    const { level } = request.body;
    if (!['GREEN', 'YELLOW', 'ORANGE', 'RED', 'PURPLE'].includes(level)) {
      return reply.code(400).send({ error: 'Invalid semafor level' });
    }

    const senior = await prisma.senior.update({
      where: { id: request.params.id },
      data: { semaforLevel: level, lastHealthCheck: new Date() },
    });

    // Auto-create alert for RED/PURPLE
    if (['RED', 'PURPLE'].includes(level)) {
      await prisma.alert.create({
        data: {
          seniorId: senior.id,
          type: 'HEALTH_ANOMALY',
          severity: level,
          title: `Status ${level}: ${senior.firstName} ${senior.lastName}`,
          description: `Automatyczna eskalacja do poziomu ${level}`,
        },
      });
    }

    return senior;
  });

  // ── Get dashboard stats for senior ────────────────────
  fastify.get('/:id/dashboard', {
    preHandler: [fastify.authenticate],
  }, async (request) => {
    const { id } = request.params;

    const [senior, todayMeds, weeklyHealth, recentConversations, activeAlerts] =
      await Promise.all([
        prisma.senior.findUnique({
          where: { id },
          select: {
            semaforLevel: true,
            wearableConnected: true,
            package: true,
          },
        }),
        prisma.medicationAdherence.count({
          where: {
            seniorId: id,
            scheduledFor: {
              gte: new Date(new Date().setHours(0, 0, 0, 0)),
              lt: new Date(new Date().setHours(23, 59, 59, 999)),
            },
            isTaken: true,
          },
        }),
        prisma.healthRecord.findMany({
          where: {
            seniorId: id,
            recordedAt: { gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) },
          },
          orderBy: { recordedAt: 'desc' },
          take: 7,
        }),
        prisma.conversation.findMany({
          where: { seniorId: id },
          orderBy: { startedAt: 'desc' },
          take: 5,
          select: {
            id: true,
            duration: true,
            moodScore: true,
            topicsDetected: true,
            startedAt: true,
          },
        }),
        prisma.alert.count({
          where: { seniorId: id, isResolved: false },
        }),
      ]);

    return { senior, todayMeds, weeklyHealth, recentConversations, activeAlerts };
  });
}

module.exports = seniorRoutes;
