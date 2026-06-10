/**
 * Landing Page Routes — Blog, Contact, Newsletter
 * SilverTech Agent Adam | June 2026
 */

const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function landingRoutes(fastify) {
  // ─── Blog ───────────────────────────────────────────────────────
  fastify.get('/api/v1/blog', async (req, reply) => {
    const { page = 1, limit = 10, category } = req.query;
    const skip = (parseInt(page) - 1) * parseInt(limit);
    const where = { published: true };
    if (category) where.category = category;

    const [posts, total] = await Promise.all([
      prisma.blogPost.findMany({
        where,
        orderBy: { publishedAt: 'desc' },
        skip,
        take: parseInt(limit),
        select: { id: true, title: true, slug: true, excerpt: true, category: true, author: true, publishedAt: true, readTime: true, tags: true, imageUrl: true },
      }),
      prisma.blogPost.count({ where }),
    ]);

    return { posts, total, page: parseInt(page), totalPages: Math.ceil(total / parseInt(limit)) };
  });

  fastify.get('/api/v1/blog/:slug', async (req, reply) => {
    const post = await prisma.blogPost.findUnique({ where: { slug: req.params.slug } });
    if (!post) return reply.code(404).send({ error: 'Post not found' });
    return post;
  });

  // ─── Contact ────────────────────────────────────────────────────
  fastify.post('/api/v1/contact', {
    schema: {
      body: {
        type: 'object',
        required: ['name', 'email', 'message'],
        properties: {
          name: { type: 'string', minLength: 2 },
          email: { type: 'string', format: 'email' },
          phone: { type: 'string' },
          message: { type: 'string', minLength: 10 },
          interest: { type: 'string', enum: ['KONTAKT', 'ZDROWIE', 'AKTYWNY', 'other'] },
        },
      },
    },
  }, async (req, reply) => {
    const submission = await prisma.contactSubmission.create({ data: req.body });
    return { success: true, id: submission.id };
  });

  // ─── Newsletter ─────────────────────────────────────────────────
  fastify.post('/api/v1/newsletter', {
    schema: {
      body: {
        type: 'object',
        required: ['email'],
        properties: { email: { type: 'string', format: 'email' } },
      },
    },
  }, async (req, reply) => {
    const existing = await prisma.newsletterSubscriber.findUnique({ where: { email: req.body.email } });
    if (existing) return { success: true, message: 'Already subscribed' };

    await prisma.newsletterSubscriber.create({ data: { email: req.body.email } });
    return { success: true, message: 'Subscribed' };
  });

  // ─── Pricing ────────────────────────────────────────────────────
  fastify.get('/api/v1/pricing', async () => ({
    packages: [
      { name: 'KONTAKT', price: 99, period: 'monthly', features: ['Asystent 24/7', 'Przypomnienia', 'Kontakty alarmowe'] },
      { name: 'ZDROWIE', price: 199, period: 'monthly', features: ['Wszystko z KONTAKT', 'Monitoring zdrowia', 'Wearable', 'Raporty'] },
      { name: 'AKTYWNY', price: 299, period: 'monthly', features: ['Wszystko z ZDROWIE', 'Marketplace', 'Telemedycyna', 'Priorytetowe wsparcie'] },
    ],
  }));
}

module.exports = landingRoutes;
