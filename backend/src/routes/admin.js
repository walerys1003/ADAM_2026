/**
 * SilverTech Agent Adam — Admin Routes
 * Dashboard analytics, audit logs, team management, SROI calculator
 */

async function adminRoutes(fastify, options) {
  const { prisma } = fastify;

  // ── Admin Dashboard Overview ──────────────────────────
  fastify.get('/dashboard', {
    preHandler: [fastify.authenticate],
  }, async () => {
    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const thirtyDaysAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);

    const [
      totalSeniors, activeSeniors, totalConversations, conversationsToday,
      activeAlerts, redAlerts, totalFamilyMembers, totalRevenue,
      semaforDistribution, packageDistribution, dailyCalls,
    ] = await Promise.all([
      prisma.senior.count(),
      prisma.senior.count({ where: { isActive: true } }),
      prisma.conversation.count(),
      prisma.conversation.count({ where: { startedAt: { gte: today } } }),
      prisma.alert.count({ where: { isResolved: false } }),
      prisma.alert.count({ where: { isResolved: false, severity: { in: ['RED', 'PURPLE'] } } }),
      prisma.family.count(),
      _calculateRevenue(prisma),
      _getSemaforDistribution(prisma),
      _getPackageDistribution(prisma),
      _getDailyCalls(prisma, thirtyDaysAgo),
    ]);

    return {
      totalSeniors, activeSeniors, totalConversations, conversationsToday,
      activeAlerts, redAlerts, totalFamilyMembers, totalRevenue,
      semaforDistribution, packageDistribution, dailyCalls,
      systemHealth: {
        uptime: process.uptime(),
        memory: Math.round(process.memoryUsage().heapUsed / 1024 / 1024),
        status: 'healthy',
      },
    };
  });

  // ── SROI Calculator ────────────────────────────────────
  fastify.get('/sroi', {
    preHandler: [fastify.authenticate],
  }, async () => {
    const seniorCount = await prisma.senior.count({ where: { isActive: true } });
    const monthlyConversations = await prisma.conversation.count({
      where: { startedAt: { gte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) } },
    });

    // Cost calculations (June 2026)
    const avgCostPerCall = 0.114; // $ per call
    const monthlyCost = monthlyConversations * avgCostPerCall;
    const annualCost = monthlyCost * 12;

    // Alternative costs without Adam
    const avgCaregiverVisit = 85; // PLN per visit (~$21)
    const visitsPerWeek = 2;
    const annualCaregiverCost = seniorCount * avgCaregiverVisit * visitsPerWeek * 52;

    // Prevented hospitalizations
    const preventedHospitalizations = Math.round(seniorCount * 0.15);
    const avgHospitalizationCost = 15000; // PLN
    const savingsFromPrevention = preventedHospitalizations * avgHospitalizationCost;

    // SROI calculation
    const totalInvestment = annualCost * 4; // PLN (USD to PLN ~4x)
    const totalReturn = savingsFromPrevention + (annualCaregiverCost * 0.5);
    const sroiRatio = totalReturn / totalInvestment;

    return {
      inputs: {
        activeSeniors: seniorCount,
        monthlyConversations,
        avgCostPerCallUSD: avgCostPerCall,
        monthlyOperationalCostUSD: Math.round(monthlyCost * 100) / 100,
        annualOperationalCostUSD: Math.round(annualCost * 100) / 100,
      },
      savings: {
        preventedHospitalizations,
        savingsFromPreventionPLN: savingsFromPrevention,
        alternativeCaregiverCostPLN: annualCaregiverCost,
        totalSavingsPLN: totalReturn,
      },
      result: {
        sroiRatio: Math.round(sroiRatio * 100) / 100,
        interpretation: sroiRatio > 3 ? 'Excellent — every 1 PLN invested returns ' + Math.round(sroiRatio * 10) / 10 + ' PLN in savings' : 'Good',
        breakEvenMonths: Math.round(6 / sroiRatio),
      },
    };
  });

  // ── Audit Log ─────────────────────────────────────────
  fastify.get('/audit', {
    preHandler: [fastify.authenticate],
    schema: {
      querystring: {
        type: 'object',
        properties: {
          page: { type: 'integer', default: 1 },
          limit: { type: 'integer', default: 50 },
          action: { type: 'string' },
          entity: { type: 'string' },
          adminId: { type: 'string' },
        },
      },
    },
  }, async (request) => {
    const { page, limit, action, entity, adminId } = request.query;
    const where = {};
    if (action) where.action = action;
    if (entity) where.entity = entity;
    if (adminId) where.adminId = adminId;

    const [logs, total] = await Promise.all([
      prisma.auditLog.findMany({
        where,
        skip: (page - 1) * limit,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: { admin: { select: { firstName: true, lastName: true } } },
      }),
      prisma.auditLog.count({ where }),
    ]);

    return { data: logs, pagination: { page, limit, total, pages: Math.ceil(total / limit) } };
  });

  // ── System Health ─────────────────────────────────────
  fastify.get('/health', {
    preHandler: [fastify.authenticate],
  }, async () => {
    const dbStart = Date.now();
    await prisma.$queryRaw`SELECT 1`;
    const dbLatency = Date.now() - dbStart;

    return {
      status: 'healthy',
      timestamp: new Date().toISOString(),
      services: {
        api: { status: 'up', uptime: process.uptime() },
        database: { status: 'up', latencyMs: dbLatency },
      },
      resources: {
        memoryMB: Math.round(process.memoryUsage().heapUsed / 1024 / 1024),
        cpu: process.cpuUsage(),
      },
    };
  });

  // ── Cost Analysis ─────────────────────────────────────
  fastify.get('/costs', {
    preHandler: [fastify.authenticate],
  }, async () => {
    const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);

    const conversations = await prisma.conversation.findMany({
      where: { startedAt: { gte: thirtyDaysAgo } },
      select: { costStt: true, costLlm: true, costTts: true, costTwilio: true, costTotal: true },
    });

    const totals = conversations.reduce((acc, c) => ({
      stt: acc.stt + (c.costStt || 0),
      llm: acc.llm + (c.costLlm || 0),
      tts: acc.tts + (c.costTts || 0),
      twilio: acc.twilio + (c.costTwilio || 0),
      total: acc.total + (c.costTotal || 0),
    }), { stt: 0, llm: 0, tts: 0, twilio: 0, total: 0 });

    return {
      period: '30 days',
      totalConversations: conversations.length,
      costs: {
        stt: Math.round(totals.stt * 100) / 100,
        llm: Math.round(totals.llm * 100) / 100,
        tts: Math.round(totals.tts * 100) / 100,
        twilio: Math.round(totals.twilio * 100) / 100,
        total: Math.round(totals.total * 100) / 100,
      },
      perCall: conversations.length > 0
        ? Math.round((totals.total / conversations.length) * 10000) / 10000
        : 0,
    };
  });
}

// ── Helper Functions ──────────────────────────────────
async function _calculateRevenue(prisma) {
  const seniors = await prisma.senior.findMany({
    where: { isActive: true },
    select: { package: true },
  });

  const prices = { KONTAKT: 99, ZDROWIE: 199, AKTYWNY: 299 };
  return seniors.reduce((sum, s) => sum + (prices[s.package] || 0), 0);
}

async function _getSemaforDistribution(prisma) {
  const [green, yellow, orange, red, purple] = await Promise.all([
    prisma.senior.count({ where: { semaforLevel: 'GREEN' } }),
    prisma.senior.count({ where: { semaforLevel: 'YELLOW' } }),
    prisma.senior.count({ where: { semaforLevel: 'ORANGE' } }),
    prisma.senior.count({ where: { semaforLevel: 'RED' } }),
    prisma.senior.count({ where: { semaforLevel: 'PURPLE' } }),
  ]);
  return { GREEN: green, YELLOW: yellow, ORANGE: orange, RED: red, PURPLE: purple };
}

async function _getPackageDistribution(prisma) {
  const [kontakt, zdrowie, aktywny] = await Promise.all([
    prisma.senior.count({ where: { package: 'KONTAKT' } }),
    prisma.senior.count({ where: { package: 'ZDROWIE' } }),
    prisma.senior.count({ where: { package: 'AKTYWNY' } }),
  ]);
  return { KONTAKT: kontakt, ZDROWIE: zdrowie, AKTYWNY: aktywny };
}

async function _getDailyCalls(prisma, since) {
  const calls = await prisma.$queryRaw`
    SELECT DATE(started_at) as date, COUNT(*) as count
    FROM conversations
    WHERE started_at >= ${since}
    GROUP BY DATE(started_at)
    ORDER BY date ASC
  `;
  return calls;
}

module.exports = adminRoutes;
