/**
 * SilverTech Agent Adam — Family Routes
 * Family dashboard, alerts, reports, senior linking
 */

async function familyRoutes(fastify, options) {
  const { prisma } = fastify;

  fastify.get('/dashboard/:familyId', {
    preHandler: [fastify.authenticate],
  }, async (request) => {
    const { familyId } = request.params;
    const family = await prisma.family.findUnique({
      where: { id: familyId },
      include: {
        senior: {
          select: {
            id: true, firstName: true, lastName: true, semaforLevel: true,
            wearableConnected: true, lastHealthCheck: true, lastConversation: true,
            medications: { where: { isActive: true }, take: 5 },
            _count: { select: { alerts: { where: { isResolved: false } } } },
          },
        },
      },
    });
    if (!family) return fastify.httpErrors.notFound('Family member not found');
    return family;
  });

  fastify.get('/seniors', {
    preHandler: [fastify.authenticate],
  }, async (request) => {
    const { search } = request.query;
    const where = { isActive: true };
    if (search) {
      where.OR = [
        { firstName: { contains: search, mode: 'insensitive' } },
        { lastName: { contains: search, mode: 'insensitive' } },
      ];
    }
    return prisma.senior.findMany({
      where,
      select: {
        id: true, firstName: true, lastName: true, phone: true,
        city: true, semaforLevel: true, wearableConnected: true,
      },
      take: 50,
    });
  });

  fastify.post('/link', {
    preHandler: [fastify.authenticate],
  }, async (request, reply) => {
    const { familyId, seniorId, relation } = request.body;
    const existing = await prisma.family.findFirst({ where: { id: familyId, seniorId } });
    if (existing) return reply.code(409).send({ error: 'Already linked' });
    const link = await prisma.family.create({
      data: {
        id: familyId, userId: request.user.id, seniorId,
        firstName: request.body.firstName, lastName: request.body.lastName,
        relation, phone: request.body.phone, email: request.body.email,
      },
    });
    reply.code(201).send(link);
  });
}

module.exports = familyRoutes;
