/**
 * Prisma Seed Script — Agent Adam Development Data
 *
 * Creates realistic test data for development and staging:
 *  - Admin user (silvertech.pl)
 *  - 3 seniors with health profiles, medications, conversations
 *  - 2 family members linked to seniors
 *  - Sample alerts, marketplace orders, blog posts
 *  - Cost: free (dev data only, no API calls)
 */

const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');
const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Seeding Agent Adam database...\n');

  // ─── Clean existing data ─────────────────────────────────────────
  await prisma.analyticsEvent.deleteMany();
  await prisma.auditLog.deleteMany();
  await prisma.alert.deleteMany();
  await prisma.marketplaceOrder.deleteMany();
  await prisma.conversation.deleteMany();
  await prisma.documentEmbedding.deleteMany();
  await prisma.medication.deleteMany();
  await prisma.healthRecord.deleteMany();
  await prisma.contactSubmission.deleteMany();
  await prisma.blogPost.deleteMany();
  await prisma.family.deleteMany();
  await prisma.senior.deleteMany();
  await prisma.admin.deleteMany();
  await prisma.user.deleteMany();

  console.log('  ✓ Cleaned existing data');

  // ─── Admin ───────────────────────────────────────────────────────
  const adminHash = await bcrypt.hash('admin123!', 12);
  const admin = await prisma.admin.create({
    data: {
      email: 'admin@silvertech.pl',
      passwordHash: adminHash,
      name: 'Administrator SilverTech',
      role: 'SUPER_ADMIN',
      isActive: true,
    },
  });
  console.log(`  ✓ Admin: ${admin.email}`);

  // ─── Seniors ─────────────────────────────────────────────────────
  const seniors = [];

  const senior1 = await prisma.senior.create({
    data: {
      firstName: 'Janina',
      lastName: 'Kowalska',
      phone: '+48 601 111 222',
      email: 'janina.k@example.pl',
      dateOfBirth: new Date('1948-03-15'),
      address: 'ul. Słoneczna 12/4, 00-001 Warszawa',
      bloodType: 'A+',
      chronicConditions: ['nadciśnienie', 'cukrzyca typu 2'],
      allergies: ['penicylina'],
      emergencyContact: '+48 601 333 444',
      emergencyContactName: 'Tomasz Kowalski (syn)',
      semaforLevel: 'GREEN',
      package: 'AKTYWNY',
      onboardingCompleted: true,
      voiceRecordingConsent: true,
      healthDataConsent: true,
      familySharingConsent: true,
    },
  });
  seniors.push(senior1);

  const senior2 = await prisma.senior.create({
    data: {
      firstName: 'Stanisław',
      lastName: 'Nowak',
      phone: '+48 602 222 333',
      email: 'stanislaw.n@example.pl',
      dateOfBirth: new Date('1945-11-02'),
      address: 'ul. Leśna 5, 30-001 Kraków',
      bloodType: '0+',
      chronicConditions: ['arytmia', 'osteoporoza'],
      allergies: [],
      emergencyContact: '+48 602 444 555',
      emergencyContactName: 'Anna Nowak (córka)',
      semaforLevel: 'YELLOW',
      package: 'ZDROWIE',
      onboardingCompleted: true,
      voiceRecordingConsent: true,
      healthDataConsent: true,
      familySharingConsent: false,
    },
  });
  seniors.push(senior2);

  const senior3 = await prisma.senior.create({
    data: {
      firstName: 'Helena',
      lastName: 'Wiśniewska',
      phone: '+48 603 333 444',
      email: 'helena.w@example.pl',
      dateOfBirth: new Date('1952-07-20'),
      address: 'ul. Parkowa 8/2, 50-001 Wrocław',
      bloodType: 'B+',
      chronicConditions: ['astma'],
      allergies: ['sulfonamidy', 'lateks'],
      emergencyContact: '+48 603 555 666',
      emergencyContactName: 'Marek Wiśniewski (mąż)',
      semaforLevel: 'GREEN',
      package: 'KONTAKT',
      onboardingCompleted: true,
      voiceRecordingConsent: true,
      healthDataConsent: true,
      familySharingConsent: true,
    },
  });
  seniors.push(senior3);

  console.log(`  ✓ Seniors: ${seniors.length} created`);

  // ─── Family members ──────────────────────────────────────────────
  const family1 = await prisma.family.create({
    data: {
      seniorId: senior1.id,
      name: 'Tomasz Kowalski',
      relation: 'Syn',
      phone: '+48 601 333 444',
      email: 'tomasz.k@example.pl',
      notificationPreferences: ['push', 'sms', 'email'],
      weeklyReportEnabled: true,
    },
  });

  const family2 = await prisma.family.create({
    data: {
      seniorId: senior2.id,
      name: 'Anna Nowak',
      relation: 'Córka',
      phone: '+48 602 444 555',
      email: 'anna.n@example.pl',
      notificationPreferences: ['push', 'email'],
      weeklyReportEnabled: true,
    },
  });

  console.log(`  ✓ Family members: 2 created`);

  // ─── Health records ──────────────────────────────────────────────
  const now = new Date();
  for (let days = 6; days >= 0; days--) {
    const date = new Date(now);
    date.setDate(date.getDate() - days);

    await prisma.healthRecord.create({
      data: {
        seniorId: senior1.id,
        heartRate: 68 + Math.floor(Math.random() * 15),
        systolic: 125 + Math.floor(Math.random() * 15),
        diastolic: 78 + Math.floor(Math.random() * 10),
        spo2: 96 + Math.floor(Math.random() * 4),
        steps: 3500 + Math.floor(Math.random() * 3000),
        sleepHours: 6.5 + Math.random() * 2.5,
        semaforLevel: 'GREEN',
        source: 'health_connect',
        recordedAt: date,
      },
    });
  }

  console.log('  ✓ Health records: 7 days for senior1');

  // ─── Medications ─────────────────────────────────────────────────
  await prisma.medication.createMany({
    data: [
      {
        seniorId: senior1.id,
        name: 'Metformina',
        dosage: '500mg',
        frequency: '2x dziennie (rano + wieczór)',
        prescribingDoctor: 'Dr Maria Wiśniewska',
        startDate: new Date('2026-06-01'),
        endDate: new Date('2026-12-31'),
        refillReminder: true,
      },
      {
        seniorId: senior1.id,
        name: 'Enalapryl',
        dosage: '10mg',
        frequency: '1x dziennie (rano)',
        prescribingDoctor: 'Dr Maria Wiśniewska',
        startDate: new Date('2026-05-15'),
        endDate: new Date('2026-11-15'),
        refillReminder: true,
      },
      {
        seniorId: senior2.id,
        name: 'Bisoprolol',
        dosage: '5mg',
        frequency: '1x dziennie (rano)',
        prescribingDoctor: 'Dr Piotr Zalewski',
        startDate: new Date('2026-04-01'),
        endDate: new Date('2026-10-01'),
        refillReminder: true,
      },
    ],
  });

  console.log('  ✓ Medications: 3 created');

  // ─── Conversations ───────────────────────────────────────────────
  const conversations = [
    { seniorText: 'Adam, jaką dziś mamy pogodę?', adamResponse: 'Dzień dobry Pani Janino! Dziś w Warszawie słonecznie, 22°C. Idealna pogoda na spacer! ☀️', mood: 'neutral', duration: 15 },
    { seniorText: 'Przypomnij mi o lekach o 20:00', adamResponse: 'Oczywiście! Ustawiłem przypomnienie o Metforminie i Enalaprylu na godzinę 20:00. Czy coś jeszcze?', mood: 'neutral', duration: 12 },
    { seniorText: 'Trochę się źle czuję dzisiaj...', adamResponse: 'Przykro mi to słyszeć. Czy boli Panią coś konkretnego? Sprawdziłem Pani ostatnie pomiary — ciśnienie jest w normie. Może warto się położyć i odpocząć?', mood: 'negative', duration: 20 },
    { seniorText: 'Opowiedz mi jakiś dowcip!', adamResponse: 'Dlaczego komputer poszedł do lekarza? Bo miał wirusa! 😄 A tak na poważnie — jak się Pani dzisiaj czuje?', mood: 'positive', duration: 10 },
    { seniorText: 'Umów mnie do doktor Wiśniewskiej', adamResponse: 'Sprawdzam kalendarz... Najbliższy wolny termin to czwartek 25 czerwca o 11:30. Czy umówić wizytę?', mood: 'neutral', duration: 18 },
  ];

  for (const conv of conversations) {
    await prisma.conversation.create({
      data: {
        seniorId: senior1.id,
        seniorText: conv.seniorText,
        adamResponse: conv.adamResponse,
        mood: conv.mood,
        durationSeconds: conv.duration,
      },
    });
  }

  console.log(`  ✓ Conversations: ${conversations.length} created`);

  // ─── Alerts ──────────────────────────────────────────────────────
  await prisma.alert.createMany({
    data: [
      {
        seniorId: senior2.id,
        type: 'HEALTH_ANOMALY',
        severity: 'ORANGE',
        message: 'Podwyższone ciśnienie: 155/95 mmHg',
        acknowledged: true,
        acknowledgedBy: 'Anna Nowak',
        acknowledgedAt: new Date('2026-06-15'),
      },
      {
        seniorId: senior2.id,
        type: 'MEDICATION_MISSED',
        severity: 'YELLOW',
        message: 'Pominięta dawka Bisoprololu (rano)',
        acknowledged: false,
      },
    ],
  });

  console.log('  ✓ Alerts: 2 created');

  // ─── Blog posts ──────────────────────────────────────────────────
  await prisma.blogPost.createMany({
    data: [
      {
        title: 'Jak technologia AI pomaga seniorom zachować niezależność',
        slug: 'ai-pomaga-seniorom-niezaleznosc',
        excerpt: 'Sztuczna inteligencja rewolucjonizuje opiekę nad osobami starszymi...',
        content: 'Pełna treść artykułu...',
        category: 'Technologia',
        author: 'Anna Kowalska',
        imageUrl: '/images/blog/ai-seniorzy.jpg',
        published: true,
        publishedAt: new Date('2026-06-10'),
        readTime: 6,
        tags: ['AI', 'niezależność', 'seniorzy', 'technologia'],
      },
      {
        title: '5 sposobów na lepszą komunikację z bliskimi po 70-tce',
        slug: '5-sposobow-komunikacja-seniorzy',
        excerpt: 'Poznaj sprawdzone metody na utrzymanie bliskiej relacji z seniorem...',
        content: 'Pełna treść artykułu...',
        category: 'Porady',
        author: 'Dr Marek Nowak',
        imageUrl: '/images/blog/komunikacja.jpg',
        published: true,
        publishedAt: new Date('2026-06-08'),
        readTime: 8,
        tags: ['komunikacja', 'rodzina', 'relacje'],
      },
      {
        title: 'Zdrowie seniora — kluczowe parametry do monitorowania',
        slug: 'zdrowie-seniora-parametry',
        excerpt: 'Jakie parametry zdrowotne warto śledzić u osób po 65 roku życia...',
        content: 'Pełna treść artykułu...',
        category: 'Zdrowie',
        author: 'Dr Maria Wiśniewska',
        imageUrl: '/images/blog/parametry-zdrowotne.jpg',
        published: true,
        publishedAt: new Date('2026-06-05'),
        readTime: 7,
        tags: ['zdrowie', 'monitorowanie', 'wearable'],
      },
    ],
  });

  console.log('  ✓ Blog posts: 3 created');

  // ─── Summary ─────────────────────────────────────────────────────
  console.log('\n✅ Seed complete!');
  console.log('─────────────────────────────────────────');
  console.log('  Admin:   admin@silvertech.pl / admin123!');
  console.log('  Seniors: 3');
  console.log('  Family:  2');
  console.log('  Health:  7 records');
  console.log('  Meds:    3');
  console.log('  Chats:   5');
  console.log('  Alerts:  2');
  console.log('  Blog:    3 posts');
  console.log('─────────────────────────────────────────\n');
}

main()
  .catch((e) => {
    console.error('❌ Seed failed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
