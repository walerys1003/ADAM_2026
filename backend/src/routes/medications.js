/**
 * SilverTech Agent Adam — Medication Routes
 */

async function medicationRoutes(fastify, options) {
  const { prisma } = fastify;

  fastify.get('/:seniorId', {
    preHandler: [fastify.authenticate],
  }, async (request) => {
    return prisma.medication.findMany({
      where: { seniorId: request.params.seniorId, isActive: true },
      orderBy: { createdAt: 'asc' },
    });
  });

  fastify.post('/', {
    preHandler: [fastify.authenticate],
  }, async (request, reply) => {
    const med = await prisma.medication.create({ data: request.body });
    reply.code(201).send(med);
  });

  fastify.patch('/:id', {
    preHandler: [fastify.authenticate],
  }, async (request) => {
    return prisma.medication.update({ where: { id: request.params.id }, data: request.body });
  });

  fastify.delete('/:id', {
    preHandler: [fastify.authenticate],
  }, async (request) => {
    return prisma.medication.update({
      where: { id: request.params.id },
      data: { isActive: false },
    });
  });

  fastify.post('/adherence', {
    preHandler: [fastify.authenticate],
  }, async (request, reply) => {
    const record = await prisma.medicationAdherence.create({ data: request.body });
    reply.code(201).send(record);
  });

  fastify.get('/:seniorId/adherence', {
    preHandler: [fastify.authenticate],
  }, async (request) => {
    const { days } = request.query;
    const since = new Date(Date.now() - (parseInt(days) || 7) * 24 * 60 * 60 * 1000);

    return prisma.medicationAdherence.findMany({
      where: { seniorId: request.params.seniorId, scheduledFor: { gte: since } },
      orderBy: { scheduledFor: 'desc' },
      include: { medication: { select: { name: true, dosage: true } } },
    });
  });
}

module.exports = medicationRoutes;
