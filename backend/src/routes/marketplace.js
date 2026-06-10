/**
 * SilverTech Agent Adam — Marketplace Routes
 * Service categories, providers, order management
 */

async function marketplaceRoutes(fastify, options) {
  const { prisma } = fastify;

  const SERVICES = [
    { type: 'lekarz_domowy', name: 'Lekarz domowy — wizyta', price: 150, providers: ['MedHome', 'Lekarz24'] },
    { type: 'pielegniarka', name: 'Pielęgniarka — zastrzyk/kroplówka', price: 80, providers: ['MedHome', 'Pielęgniarki+'] },
    { type: 'fizjoterapeuta', name: 'Fizjoterapeuta — rehabilitacja', price: 120, providers: ['RehaDom', 'FizjoPlus'] },
    { type: 'sprzatanie', name: 'Sprzątanie mieszkania', price: 100, providers: ['CleanHome', 'SeniorClean'] },
    { type: 'zakupy', name: 'Zakupy z dostawą', price: 40, providers: ['ShopAssist', 'SeniorShop'] },
    { type: 'transport', name: 'Transport na wizytę lekarską', price: 60, providers: ['MediTrans', 'SafeRide'] },
  ];

  fastify.get('/services', {
    preHandler: [fastify.authenticate],
  }, async () => SERVICES);

  fastify.post('/order', {
    preHandler: [fastify.authenticate],
  }, async (request, reply) => {
    const order = await prisma.marketplaceOrder.create({
      data: {
        ...request.body,
        status: 'PENDING',
      },
    });
    reply.code(201).send(order);
  });

  fastify.get('/orders/:seniorId', {
    preHandler: [fastify.authenticate],
  }, async (request) => {
    return prisma.marketplaceOrder.findMany({
      where: { seniorId: request.params.seniorId },
      orderBy: { createdAt: 'desc' },
      take: 20,
    });
  });

  fastify.patch('/order/:id/status', {
    preHandler: [fastify.authenticate],
  }, async (request) => {
    return prisma.marketplaceOrder.update({
      where: { id: request.params.id },
      data: { status: request.body.status },
    });
  });
}

module.exports = marketplaceRoutes;
