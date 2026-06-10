/**
 * SilverTech Agent Adam — Conversation Routes
 * History, search, transcripts, analytics
 */

async function conversationRoutes(fastify, options) {
  const { prisma } = fastify;

  fastify.get('/', {
    preHandler: [fastify.authenticate],
    schema: {
      querystring: {
        type: 'object',
        properties: {
          seniorId: { type: 'string' },
          page: { type: 'integer', default: 1 },
          limit: { type: 'integer', default: 20 },
          sortBy: { type: 'string', default: 'started_at' },
          sortDir: { type: 'string', enum: ['asc', 'desc'], default: 'desc' },
        },
      },
    },
  }, async (request) => {
    const { seniorId, page, limit, sortBy, sortDir } = request.query;
    const where = seniorId ? { seniorId } : {};
    const skip = (page - 1) * limit;

    const [conversations, total] = await Promise.all([
      prisma.conversation.findMany({
        where,
        skip,
        take: limit,
        orderBy: { [sortBy]: sortDir },
        select: {
          id: true, seniorId: true, duration: true, moodScore: true,
          topicsDetected: true, costTotal: true, isEmergency: true,
          startedAt: true, endedAt: true, hangupReason: true,
          senior: { select: { firstName: true, lastName: true } },
        },
      }),
      prisma.conversation.count({ where }),
    ]);

    return { data: conversations, pagination: { page, limit, total, pages: Math.ceil(total / limit) } };
  });

  fastify.get('/:id', {
    preHandler: [fastify.authenticate],
  }, async (request, reply) => {
    const conv = await prisma.conversation.findUnique({
      where: { id: request.params.id },
      include: { senior: { select: { firstName: true, lastName: true } } },
    });
    if (!conv) return reply.code(404).send({ error: 'Not found' });
    return conv;
  });
}

module.exports = conversationRoutes;
