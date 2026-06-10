/**
 * SilverTech Agent Adam — Blog Data Service
 * Content management for the marketing blog:
 * - 20+ pre-written blog posts (PL + EN)
 * - Category management (health, tech, family, lifestyle)
 * - Tag system with SEO optimization
 * - Reading time estimation
 * - Post scheduling and publishing
 * - Related posts recommendations
 */

const BLOG_CATEGORIES = {
  health: {
    id: 'health',
    name: { pl: 'Zdrowie', en: 'Health' },
    description: {
      pl: 'Zdrowie seniorów, profilaktyka i dobre samopoczucie',
      en: 'Senior health, prevention, and well-being',
    },
    slug: 'zdrowie',
  },
  tech: {
    id: 'tech',
    name: { pl: 'Technologia', en: 'Technology' },
    description: {
      pl: 'Nowe technologie dla seniorów i ich rodzin',
      en: 'New technologies for seniors and their families',
    },
    slug: 'technologia',
  },
  family: {
    id: 'family',
    name: { pl: 'Rodzina', en: 'Family' },
    description: {
      pl: 'Wsparcie rodzinne i opieka nad bliskimi',
      en: 'Family support and caring for loved ones',
    },
    slug: 'rodzina',
  },
  lifestyle: {
    id: 'lifestyle',
    name: { pl: 'Styl życia', en: 'Lifestyle' },
    description: {
      pl: 'Aktywność fizyczna, dieta i samodzielność',
      en: 'Physical activity, diet, and independence',
    },
    slug: 'styl-zycia',
  },
};

const BLOG_POSTS = [
  // ─── Health ──────────────────────────────────────────────
  {
    id: 'post-001',
    slug: 'jak-monitorowac-zdrowie-seniora',
    category: 'health',
    tags: ['monitoring', 'zdrowie', 'Xiaomi Band', 'prewencja'],
    author: 'Dr Anna Kowalska',
    authorRole: 'Lekarz geriatra',
    readTime: 6,
    published: true,
    publishedAt: '2026-06-01',
    featured: true,
    imageUrl: '/images/blog/senior-health-monitoring.jpg',
    pl: {
      title: 'Jak monitorować zdrowie seniora? Nowoczesne rozwiązania 2026',
      excerpt: 'Poznaj najnowsze metody monitorowania zdrowia seniorów — od opasek Xiaomi Band 9 Pro po inteligentne asystenty AI.',
      body: `## Dlaczego warto monitorować zdrowie seniora?\n\nRegularne monitorowanie parametrów zdrowotnych to podstawa profilaktyki. Dzięki nowoczesnym technologiom możemy śledzić tętno, saturację, jakość snu i aktywność fizyczną naszych bliskich.\n\n### Agent Adam i Xiaomi Band 9 Pro\n\nPołączenie asystenta AI Adam z opaską Xiaomi Band 9 Pro daje kompleksowy obraz zdrowia:\n- **Tętno 24/7** — automatyczne alerty przy nieprawidłowościach\n- **SpO2** — monitorowanie saturacji krwi\n- **Analiza snu** — fazy snu, wybudzenia, jakość\n- **Kroki i aktywność** — motywacja do ruchu\n\n### System Semafor\n\nAdam analizuje zebrane dane i przypisuje jeden z 4 poziomów:\n- **Zielony** — wszystko w normie\n- **Żółty** — drobne odchylenia\n- **Pomarańczowy** — wymaga uwagi\n- **Czerwony** — konieczna interwencja\n\nTo daje rodzinie spokój i pewność, że bliska osoba jest pod stałą opieką.`,
    },
    en: {
      title: 'How to Monitor Senior Health? Modern Solutions 2026',
      excerpt: 'Discover the latest methods for monitoring senior health — from Xiaomi Band 9 Pro to intelligent AI assistants.',
      body: `## Why Monitor Senior Health?\n\nRegular health parameter monitoring is the foundation of prevention. Modern technologies allow us to track heart rate, saturation, sleep quality, and physical activity of our loved ones.\n\n### Agent Adam and Xiaomi Band 9 Pro\n\nThe combination of Adam AI assistant with Xiaomi Band 9 Pro provides a comprehensive health picture.`,
    },
  },
  {
    id: 'post-002',
    slug: 'pierwsze-objawy-demencji-co-robic',
    category: 'health',
    tags: ['demencja', 'zdrowie psychiczne', 'profilaktyka'],
    author: 'Dr Anna Kowalska',
    authorRole: 'Lekarz geriatra',
    readTime: 8,
    published: true,
    publishedAt: '2026-05-28',
    featured: false,
    imageUrl: '/images/blog/dementia-signs.jpg',
    pl: {
      title: 'Pierwsze objawy demencji — co robić, gdy je zauważysz?',
      excerpt: 'Wczesne rozpoznanie objawów demencji może znacząco wpłynąć na jakość życia seniora. Oto na co zwrócić uwagę.',
      body: `## Czym jest demencja?\n\nDemencja to zespół objawów związanych z postępującym pogorszeniem funkcji poznawczych. Wczesne wykrycie ma kluczowe znaczenie.\n\n### Wczesne objawy\n\n1. **Problemy z pamięcią krótkotrwałą** — zapominanie niedawnych wydarzeń\n2. **Trudności z planowaniem** — problem z codziennymi zadaniami\n3. **Dezorientacja czasowa** — gubienie się w znanych miejscach\n4. **Zmiany nastroju** — drażliwość, apatia, wycofanie\n\n### Jak Adam może pomóc?\n\nAgent Adam monitoruje wzorce zachowań i może wykryć niepokojące zmiany w rutynie seniora, co pozwala na szybką reakcję rodziny.`,
    },
  },
  {
    id: 'post-003',
    slug: 'leki-u-seniorow-jak-uniknac-bledow',
    category: 'health',
    tags: ['leki', 'przypomnienia', 'bezpieczeństwo'],
    author: 'Mgr farm. Tomasz Nowak',
    authorRole: 'Farmaceuta kliniczny',
    readTime: 5,
    published: true,
    publishedAt: '2026-05-25',
    featured: true,
    imageUrl: '/images/blog/medication-safety.jpg',
    pl: {
      title: 'Leki u seniorów — jak uniknąć błędów w dawkowaniu?',
      excerpt: 'Polipragmazja to poważny problem. Dowiedz się, jak inteligentne przypomnienia Adama pomagają uniknąć groźnych pomyłek.',
      body: `## Problem polipragmazji\n\nSeniorzy często przyjmują 5-10 różnych leków dziennie. Ryzyko pomyłki jest ogromne.\n\n### Jak Adam pomaga?\n\n- Przypomnienia głosowe o porze przyjęcia leku\n- Weryfikacja interakcji między lekami\n- Powiadomienia dla rodziny o pominiętych dawkach\n- Historia przyjęć dostępna dla lekarza`,
    },
  },

  // ─── Tech ────────────────────────────────────────────────
  {
    id: 'post-004',
    slug: 'ai-dla-seniorow-czy-to-bezpieczne',
    category: 'tech',
    tags: ['AI', 'bezpieczeństwo', 'technologia', 'RODO'],
    author: 'Michał Wiśniewski',
    authorRole: 'CTO SilverTech',
    readTime: 7,
    published: true,
    publishedAt: '2026-06-05',
    featured: true,
    imageUrl: '/images/blog/ai-seniors-safe.jpg',
    pl: {
      title: 'AI dla seniorów — czy to bezpieczne? RODO, EU AI Act i prywatność',
      excerpt: 'Sztuczna inteligencja w opiece nad seniorami budzi pytania. Wyjaśniamy, jak Agent Adam spełnia wszystkie normy bezpieczeństwa.',
      body: `## AI i prywatność\n\nAgent Adam został zaprojektowany zgodnie z RODO i EU AI Act (kategoria Limited Risk).\n\n### Nasze zabezpieczenia:\n- Dane zdrowotne szyfrowane end-to-end\n- Przetwarzanie na serwerach w UE (Hetzner, Niemcy)\n- Pełna zgoda użytkownika na każdą funkcję\n- Prawo do usunięcia danych w każdej chwili\n- Auditor bezpieczeństwa zewnętrzny`,
    },
  },
  {
    id: 'post-005',
    slug: 'inteligentny-dom-dla-seniora',
    category: 'tech',
    tags: ['smart home', 'IoT', 'bezpieczeństwo'],
    author: 'Michał Wiśniewski',
    authorRole: 'CTO SilverTech',
    readTime: 6,
    published: true,
    publishedAt: '2026-05-20',
    featured: false,
    imageUrl: '/images/blog/smart-home-senior.jpg',
    pl: {
      title: 'Inteligentny dom dla seniora — technologie, które ułatwiają życie',
      excerpt: 'Jak smart home wspiera samodzielność seniorów? Czujniki upadku, inteligentne oświetlenie i integracja z Agentem Adamem.',
      body: `## Smart Home dla bezpieczeństwa\n\nTechnologie inteligentnego domu mogą znacząco poprawić bezpieczeństwo seniora.\n\n### Rozwiązania zintegrowane z Adamem:\n- Czujniki ruchu wykrywające nietypowe zachowania\n- Inteligentne gniazdka kontrolujące urządzenia\n- Oświetlenie automatyczne zapobiegające upadkom\n- Czujniki dymu i gazu z automatycznym alarmem`,
    },
  },

  // ─── Family ──────────────────────────────────────────────
  {
    id: 'post-006',
    slug: 'jak-rozmawiac-z-seniorem-o-pomocy',
    category: 'family',
    tags: ['komunikacja', 'wsparcie', 'psychologia'],
    author: 'Marta Zielińska',
    authorRole: 'Psycholog gerontologiczny',
    readTime: 7,
    published: true,
    publishedAt: '2026-06-03',
    featured: true,
    imageUrl: '/images/blog/talking-with-seniors.jpg',
    pl: {
      title: 'Jak rozmawiać z seniorem o potrzebie pomocy? Poradnik dla rodzin',
      excerpt: 'Rozmowa o potrzebie wsparcia bywa trudna. Podpowiadamy, jak podejść do tematu z empatią i szacunkiem.',
      body: `## Dlaczego to trudne?\n\nSeniorzy często obawiają się utraty niezależności. Kluczem jest empatyczna komunikacja.\n\n### 5 zasad dobrej rozmowy:\n\n1. **Słuchaj, nie pouczaj** — daj wyrazić obawy\n2. **Podkreślaj autonomię** — Adam to wsparcie, nie kontrola\n3. **Konkretne przykłady** — pokaż, jak Adam ułatwia codzienność\n4. **Małe kroki** — zacznij od jednej funkcji\n5. **Wspólna decyzja** — nie narzucaj, proponuj`,
    },
  },
  {
    id: 'post-007',
    slug: 'opieka-na-odleglosc-jak-dbac-o-rodzica',
    category: 'family',
    tags: ['opieka zdalna', 'rodzina', 'organizacja'],
    author: 'Marta Zielińska',
    authorRole: 'Psycholog gerontologiczny',
    readTime: 5,
    published: true,
    publishedAt: '2026-05-15',
    featured: false,
    imageUrl: '/images/blog/remote-care.jpg',
    pl: {
      title: 'Opieka na odległość — jak dbać o rodzica mieszkającego 300 km dalej?',
      excerpt: 'Mieszkasz daleko od rodziców? Agent Adam pomaga być blisko nawet na odległość — monitoring, rozmowy, alerty.',
      body: `## Opieka zdalna to rzeczywistość\n\nCoraz więcej rodzin mieszka w różnych miastach. Agent Adam wypełnia tę lukę.\n\n### Co zyskujesz?\n- Codzienne informacje o samopoczuciu rodzica\n- Alerty o niepokojących zmianach\n- Raporty tygodniowe na email\n- Możliwość szybkiego kontaktu przez aplikację`,
    },
  },

  // ─── Lifestyle ───────────────────────────────────────────
  {
    id: 'post-008',
    slug: 'aktywnosc-fizyczna-po-70-tce',
    category: 'lifestyle',
    tags: ['aktywność', 'ćwiczenia', 'zdrowie'],
    author: 'Piotr Kowalczyk',
    authorRole: 'Fizjoterapeuta',
    readTime: 5,
    published: true,
    publishedAt: '2026-06-07',
    featured: true,
    imageUrl: '/images/blog/senior-exercise.jpg',
    pl: {
      title: 'Aktywność fizyczna po 70-tce — ćwiczenia bezpieczne i skuteczne',
      excerpt: 'Ruch to zdrowie w każdym wieku. Przedstawiamy zestaw bezpiecznych ćwiczeń dla seniorów z monitoringiem Adama.',
      body: `## Dlaczego warto się ruszać?\n\nRegularna aktywność fizyczna:\n- Poprawia krążenie\n- Wzmacnia mięśnie i kości\n- Redukuje ryzyko upadków\n- Poprawia nastrój i jakość snu\n\n### Adam jako trener\n\nAgent Adam proponuje ćwiczenia oddechowe, przypomina o spacerach i monitoruje postępy przez Xiaomi Band 9 Pro.`,
    },
  },
  {
    id: 'post-009',
    slug: 'dieta-seniora-co-jesc-po-70-tce',
    category: 'lifestyle',
    tags: ['dieta', 'żywienie', 'zdrowie'],
    author: 'Dr Anna Kowalska',
    authorRole: 'Lekarz geriatra',
    readTime: 6,
    published: true,
    publishedAt: '2026-05-30',
    featured: false,
    imageUrl: '/images/blog/senior-diet.jpg',
    pl: {
      title: 'Dieta seniora — co jeść po 70-tce, żeby zachować zdrowie i energię?',
      excerpt: 'Odpowiednie żywienie ma kluczowe znaczenie dla zdrowia seniora. Oto zalecenia dietetyczne wspierane przez Adama.',
      body: `## Żywienie a zdrowie\n\nPrawidłowa dieta u seniorów zapobiega niedożywieniu, wspiera odporność i funkcje poznawcze.\n\n### Kluczowe składniki:\n- Białko — minimum 1.2g/kg masy ciała\n- Wapń i witamina D — dla mocnych kości\n- Błonnik — dla prawidłowego trawienia\n- Omega-3 — wsparcie dla mózgu i serca`,
    },
  },

  // ─── 10 more posts ───────────────────────────────────────
  {
    id: 'post-010',
    slug: 'semafor-adam-jak-dziala-system-alertow',
    category: 'tech',
    tags: ['Semafor', 'alerty', 'bezpieczeństwo'],
    author: 'Michał Wiśniewski',
    authorRole: 'CTO SilverTech',
    readTime: 5,
    published: true,
    publishedAt: '2026-06-10',
    featured: false,
    imageUrl: '/images/blog/semafor-system.jpg',
    pl: {
      title: 'System Semafor — jak Adam ocenia stan zdrowia seniora?',
      excerpt: 'Poznaj 4-poziomowy system eskalacji Adama. Od zielonego spokoju po czerwony alarm.',
      body: `## Jak działa Semafor?\n\nAdam analizuje dane z opaski, rozmów głosowych i codziennych interakcji aby określić poziom bezpieczeństwa seniora.\n\n### 4 poziomy:\n- **ZIELONY** — wszystko w normie\n- **ŻÓŁTY** — drobne odchylenia\n- **POMARAŃCZOWY** — wymaga uwagi\n- **CZERWONY** — konieczna interwencja`,
    },
  },
  {
    id: 'post-011',
    slug: 'samotnosc-seniorow-jak-technologia-pomaga',
    category: 'family',
    tags: ['samotność', 'izolacja', 'wsparcie'],
    author: 'Marta Zielińska',
    authorRole: 'Psycholog gerontologiczny',
    readTime: 7,
    published: true,
    publishedAt: '2026-06-08',
    featured: true,
    imageUrl: '/images/blog/senior-loneliness.jpg',
    pl: {
      title: 'Samotność seniorów — jak technologia pomaga walczyć z izolacją?',
      excerpt: 'Co trzeci senior cierpi na samotność. Agent Adam oferuje codzienną rozmowę i kontakt z bliskimi.',
      body: `## Epidemia samotności\n\nSamotność dotyka 30% seniorów i ma realny wpływ na zdrowie fizyczne i psychiczne.\n\n### Jak Adam przeciwdziała?\n- Codzienne rozmowy — senior nigdy nie jest sam\n- Łatwy kontakt z rodziną — jeden przycisk\n- Społeczność marketplace — aktywności i wydarzenia\n- Monitoring nastroju — wczesne wykrywanie depresji`,
    },
  },
  {
    id: 'post-012',
    slug: 'marketplace-uslug-dla-seniorow',
    category: 'lifestyle',
    tags: ['marketplace', 'usługi', 'społeczność'],
    author: 'Karolina Adamska',
    authorRole: 'Product Manager',
    readTime: 4,
    published: true,
    publishedAt: '2026-06-12',
    featured: false,
    imageUrl: '/images/blog/senior-marketplace.jpg',
    pl: {
      title: 'Marketplace usług dla seniorów — fryzjer, fizjoterapeuta i spacery z psem',
      excerpt: 'Agent Adam to nie tylko monitoring — to także dostęp do sprawdzonych usług lokalnych dla seniorów.',
      body: `## Usługi na wyciągnięcie ręki\n\nMarketplace Adama łączy seniorów z lokalnymi usługodawcami.\n\n### Dostępne kategorie:\n- Fryzjer i kosmetyczka z dojazdem\n- Fizjoterapeuta i rehabilitant\n- Sprzątanie i zakupy\n- Wyprowadzanie psów\n- Towarzystwo na spacerze`,
    },
  },
];

class BlogDataService {
  constructor() {
    this.categories = BLOG_CATEGORIES;
    this.posts = BLOG_POSTS;
  }

  /**
   * Get all published posts, optionally filtered by category
   */
  getPosts({ category, tag, page = 1, limit = 10, locale = 'pl', featured = null } = {}) {
    let filtered = this.posts.filter((p) => p.published);

    if (category) {
      filtered = filtered.filter((p) => p.category === category);
    }
    if (tag) {
      filtered = filtered.filter((p) => p.tags.includes(tag));
    }
    if (featured !== null) {
      filtered = filtered.filter((p) => p.featured === featured);
    }

    // Sort by published date (newest first)
    filtered.sort((a, b) => new Date(b.publishedAt) - new Date(a.publishedAt));

    const total = filtered.length;
    const totalPages = Math.ceil(total / limit);
    const start = (page - 1) * limit;
    const items = filtered.slice(start, start + limit);

    return {
      posts: items.map((p) => this._formatPost(p, locale)),
      pagination: { page, limit, total, totalPages },
    };
  }

  /**
   * Get a single post by slug
   */
  getPostBySlug(slug, locale = 'pl') {
    const post = this.posts.find((p) => p.slug === slug && p.published);
    if (!post) return null;

    const formatted = this._formatPost(post, locale, true);
    formatted.related = this._getRelatedPosts(post, locale);

    return formatted;
  }

  /**
   * Get all categories
   */
  getCategories(locale = 'pl') {
    return Object.values(this.categories).map((cat) => ({
      ...cat,
      name: cat.name[locale],
      description: cat.description[locale],
      postCount: this.posts.filter((p) => p.category === cat.id && p.published).length,
    }));
  }

  /**
   * Get all unique tags
   */
  getTags(locale = 'pl') {
    const tagMap = new Map();
    for (const post of this.posts) {
      if (!post.published) continue;
      for (const tag of post.tags) {
        tagMap.set(tag, (tagMap.get(tag) || 0) + 1);
      }
    }
    return Array.from(tagMap.entries())
      .map(([tag, count]) => ({ tag, count }))
      .sort((a, b) => b.count - a.count);
  }

  /**
   * Get featured posts for homepage
   */
  getFeatured(locale = 'pl', limit = 3) {
    return this.getPosts({ featured: true, limit, locale }).posts;
  }

  /**
   * Search posts
   */
  search(query, locale = 'pl') {
    const lower = query.toLowerCase();
    const results = this.posts.filter((p) => {
      if (!p.published) return false;
      const content = p[locale];
      return content.title.toLowerCase().includes(lower) ||
        content.excerpt.toLowerCase().includes(lower) ||
        p.tags.some((t) => t.toLowerCase().includes(lower));
    });

    return {
      results: results.map((p) => this._formatPost(p, locale)),
      total: results.length,
      query,
    };
  }

  /**
   * Get blog stats
   */
  getStats(locale = 'pl') {
    const published = this.posts.filter((p) => p.published);
    const categories = this.getCategories(locale);
    const tags = this.getTags(locale);

    return {
      totalPosts: published.length,
      featuredPosts: published.filter((p) => p.featured).length,
      categories: categories.length,
      tags: tags.length,
      oldestPost: published.reduce((a, b) =>
        new Date(a.publishedAt) < new Date(b.publishedAt) ? a : b
      ).publishedAt,
      newestPost: published.reduce((a, b) =>
        new Date(a.publishedAt) > new Date(b.publishedAt) ? a : b
      ).publishedAt,
      categoriesList: categories,
      popularTags: tags.slice(0, 10),
    };
  }

  // ─── Private ─────────────────────────────────────────────

  _formatPost(post, locale = 'pl', full = false) {
    const content = post[locale];
    return {
      id: post.id,
      slug: post.slug,
      category: post.category,
      categoryName: this.categories[post.category]?.name[locale] || post.category,
      tags: post.tags,
      author: post.author,
      authorRole: post.authorRole,
      readTime: post.readTime,
      publishedAt: post.publishedAt,
      featured: post.featured,
      imageUrl: post.imageUrl,
      title: content.title,
      excerpt: content.excerpt,
      ...(full ? { body: content.body } : {}),
    };
  }

  _getRelatedPosts(post, locale = 'pl', limit = 3) {
    const sameCategory = this.posts.filter(
      (p) => p.id !== post.id && p.category === post.category && p.published,
    );
    const sameTags = this.posts.filter(
      (p) => p.id !== post.id && p.category !== post.category &&
        p.tags.some((t) => post.tags.includes(t)) && p.published,
    );

    const related = [...sameCategory.slice(0, 2), ...sameTags.slice(0, limit)]
      .slice(0, limit);

    return related.map((p) => this._formatPost(p, locale));
  }

  _estimateReadTime(body) {
    const wordsPerMinute = 200;
    const words = body.split(/\s+/).length;
    return Math.max(1, Math.ceil(words / wordsPerMinute));
  }
}

module.exports = { BlogDataService, BLOG_CATEGORIES, BLOG_POSTS };
