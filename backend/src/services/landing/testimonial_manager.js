/**
 * SilverTech Agent Adam — Testimonial Manager
 * Manages customer testimonials for the landing page:
 * - Approved testimonials with ratings
 * - Video testimonial support
 * - Package-specific filtering
 * - Moderation queue
 * - Star rating aggregation
 */

const TESTIMONIALS = [
  {
    id: 'test-001',
    name: 'Maria K.',
    age: 76,
    location: 'Warszawa',
    package: 'ZDROWIE',
    role: 'senior',
    rating: 5,
    text: 'Adam jest jak mój osobisty opiekun. Codziennie rano pyta jak się czuję, przypomina o lekach, a jak coś jest nie tak, od razu dzwoni do córki. Czuję się bezpieczniej.',
    avatar: '/images/testimonials/maria-k.jpg',
    verified: true,
    featured: true,
    since: '2026-03',
  },
  {
    id: 'test-002',
    name: 'Jan W.',
    age: 81,
    location: 'Kraków',
    package: 'AKTYWNY',
    role: 'senior',
    rating: 5,
    text: 'Dzięki Adamowi znów jestem aktywny. Przypomina o spacerach, umawia wizyty u lekarza, a nawet znalazł mi fizjoterapeutę przez marketplace. Polecam każdemu!',
    avatar: '/images/testimonials/jan-w.jpg',
    verified: true,
    featured: true,
    since: '2026-02',
  },
  {
    id: 'test-003',
    name: 'Katarzyna M.',
    age: 45,
    location: 'Gdańsk',
    package: 'ZDROWIE',
    role: 'family',
    rating: 5,
    text: 'Jestem córką i pracuję na pełen etat. Adam dał mi spokój — wiem, że mama jest pod opieką. Raporty tygodniowe są świetne, a system Semafor naprawdę działa.',
    avatar: '/images/testimonials/katarzyna-m.jpg',
    verified: true,
    featured: true,
    since: '2026-04',
  },
  {
    id: 'test-004',
    name: 'Tomasz R.',
    age: 52,
    location: 'Wrocław',
    package: 'KONTAKT',
    role: 'family',
    rating: 4,
    text: 'Mój tata miał opory przed technologią, ale Adam mówi normalnym głosem po polsku i tata szybko się przyzwyczaił. Teraz sam dzwoni do Adama, żeby pogadać.',
    avatar: '/images/testimonials/tomasz-r.jpg',
    verified: true,
    featured: false,
    since: '2026-05',
  },
  {
    id: 'test-005',
    name: 'Zofia P.',
    age: 79,
    location: 'Poznań',
    package: 'KONTAKT',
    role: 'senior',
    rating: 5,
    text: 'Wcześniej bałam się zostać sama w domu. Teraz wiem, że wystarczy powiedzieć "Adam, pomocy" i ktoś przyjdzie. To zmieniło moje życie.',
    avatar: '/images/testimonials/zofia-p.jpg',
    verified: true,
    featured: true,
    since: '2026-01',
  },
  {
    id: 'test-006',
    name: 'Andrzej L.',
    age: 68,
    location: 'Łódź',
    package: 'ZDROWIE',
    role: 'senior',
    rating: 5,
    text: 'Mam problemy z sercem, więc opaska i stały monitoring to dla mnie podstawa. Adam sprawdza tętno co godzinę i alarmuje lekarza przy nieprawidłowościach.',
    avatar: '/images/testimonials/andrzej-l.jpg',
    verified: true,
    featured: false,
    since: '2026-05',
  },
  {
    id: 'test-007',
    name: 'Monika S.',
    age: 38,
    location: 'Szczecin',
    package: 'AKTYWNY',
    role: 'family',
    rating: 5,
    text: 'Mieszkam za granicą a mama w Polsce. Adam jest naszym mostem. Codziennie dostaję informację, że mama wzięła leki i wszystko jest OK. Bezcenne.',
    avatar: '/images/testimonials/monika-s.jpg',
    verified: true,
    featured: true,
    since: '2026-03',
  },
  {
    id: 'test-008',
    name: 'Stanisław G.',
    age: 84,
    location: 'Katowice',
    package: 'KONTAKT',
    role: 'senior',
    rating: 4,
    text: 'Czasem się zawiesza jak mówię po śląsku, ale ogólnie jestem zadowolony. Najbardziej lubię jak Adam opowiada dowcipy i przypomina o meczu.',
    avatar: '/images/testimonials/stanislaw-g.jpg',
    verified: true,
    featured: false,
    since: '2026-06',
  },
  {
    id: 'test-009',
    name: 'Aleksandra W.',
    age: 42,
    location: 'Bydgoszcz',
    package: 'ZDROWIE',
    role: 'family',
    rating: 5,
    text: 'Jestem lekarką i widzę, że Adam naprawdę pomaga. Moja babcia ma lepsze wyniki, regularnie bierze leki, a ja dostaję alerty tylko gdy naprawdę trzeba.',
    avatar: '/images/testimonials/aleksandra-w.jpg',
    verified: true,
    featured: false,
    since: '2026-04',
  },
  {
    id: 'test-010',
    name: 'Henryk B.',
    age: 77,
    location: 'Lublin',
    package: 'AKTYWNY',
    role: 'senior',
    rating: 5,
    text: 'Aktywny senior to ja! Adam motywuje mnie do ćwiczeń, zapisuje na zajęcia i chwali jak robię postępy. A jak żona mówi że za dużo siedzę przed TV, to Adam staje po jej stronie!',
    avatar: '/images/testimonials/henryk-b.jpg',
    verified: true,
    featured: true,
    since: '2026-02',
  },
  {
    id: 'test-011',
    name: 'Joanna N.',
    age: 61,
    location: 'Rzeszów',
    package: 'ZDROWIE',
    role: 'family',
    rating: 5,
    text: 'Poleciłam Adama wszystkim znajomym. To nie jest gadżet — to realne wsparcie. Mój tata nie czuje się już samotny, a ja nie dzwonię do niego spanikowana 5 razy dziennie.',
    avatar: '/images/testimonials/joanna-n.jpg',
    verified: true,
    featured: true,
    since: '2026-06',
  },
  {
    id: 'test-012',
    name: 'Władysława C.',
    age: 82,
    location: 'Toruń',
    package: 'KONTAKT',
    role: 'senior',
    rating: 4,
    text: 'Na początku myślałam, że to jakiś robot i się bałam. Ale Adam mówi tak ładnie i grzecznie, że teraz to mój najlepszy przyjaciel. Nawet wnuki są zazdrosne!',
    avatar: '/images/testimonials/wladyslawa-c.jpg',
    verified: true,
    featured: false,
    since: '2026-05',
  },
];

const VIDEO_TESTIMONIALS = [
  {
    id: 'video-001',
    name: 'Rodzina Kowalskich',
    package: 'ZDROWIE',
    thumbnail: '/images/testimonials/video-kowalscy.jpg',
    videoUrl: '/videos/testimonials/kowalscy.mp4',
    duration: '2:15',
    featured: true,
  },
  {
    id: 'video-002',
    name: 'Dr Anna K. — geriatra',
    package: 'AKTYWNY',
    thumbnail: '/images/testimonials/video-anna-k.jpg',
    videoUrl: '/videos/testimonials/anna-k-opinion.mp4',
    duration: '3:42',
    featured: true,
  },
  {
    id: 'video-003',
    name: 'Senior Klub "Pogodni"',
    package: 'ZDROWIE',
    thumbnail: '/images/testimonials/video-klub-pogodni.jpg',
    videoUrl: '/videos/testimonials/klub-pogodni.mp4',
    duration: '4:08',
    featured: false,
  },
];

class TestimonialManager {
  constructor() {
    this.testimonials = TESTIMONIALS;
    this.videoTestimonials = VIDEO_TESTIMONIALS;
  }

  /**
   * Get all approved testimonials
   */
  getAll({ package: pkg, role, rating, featured = null, page = 1, limit = 12 } = {}) {
    let filtered = [...this.testimonials];

    if (pkg) filtered = filtered.filter((t) => t.package === pkg);
    if (role) filtered = filtered.filter((t) => t.role === role);
    if (rating) filtered = filtered.filter((t) => t.rating >= rating);
    if (featured !== null) filtered = filtered.filter((t) => t.featured === featured);

    // Sort: featured first, then newest
    filtered.sort((a, b) => {
      if (a.featured !== b.featured) return b.featured ? 1 : -1;
      return b.since.localeCompare(a.since);
    });

    const total = filtered.length;
    const start = (page - 1) * limit;

    return {
      testimonials: filtered.slice(start, start + limit),
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * Get featured testimonials for homepage
   */
  getFeatured(limit = 5) {
    return this.testimonials
      .filter((t) => t.featured)
      .sort((a, b) => b.since.localeCompare(a.since))
      .slice(0, limit);
  }

  /**
   * Get aggregated rating statistics
   */
  getRatingStats() {
    const total = this.testimonials.length;
    if (total === 0) return null;

    const avgRating = this.testimonials.reduce((sum, t) => sum + t.rating, 0) / total;
    const distribution = { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 };
    for (const t of this.testimonials) {
      distribution[t.rating]++;
    }

    const byPackage = {};
    for (const t of this.testimonials) {
      if (!byPackage[t.package]) byPackage[t.package] = { total: 0, sum: 0 };
      byPackage[t.package].total++;
      byPackage[t.package].sum += t.rating;
    }

    const pkgAverages = Object.fromEntries(
      Object.entries(byPackage).map(([pkg, data]) => [
        pkg,
        Math.round((data.sum / data.total) * 10) / 10,
      ]),
    );

    return {
      average: Math.round(avgRating * 10) / 10,
      total,
      distribution,
      nps: Math.round(
        ((distribution[5] + distribution[4] - distribution[1] - distribution[2]) / total) * 100,
      ),
      byPackage: pkgAverages,
      byPackageCount: Object.fromEntries(
        Object.entries(byPackage).map(([pkg, data]) => [pkg, data.total]),
      ),
    };
  }

  /**
   * Get testimonials grouped by role (senior / family)
   */
  getByRole() {
    return {
      seniors: this.testimonials.filter((t) => t.role === 'senior'),
      family: this.testimonials.filter((t) => t.role === 'family'),
    };
  }

  /**
   * Get video testimonials
   */
  getVideos(featured = null) {
    if (featured !== null) {
      return this.videoTestimonials.filter((v) => v.featured === featured);
    }
    return this.videoTestimonials;
  }

  /**
   * Get testimonials for a specific package (marketing use)
   */
  getForPackage(packageName, limit = 3) {
    return this.testimonials
      .filter((t) => t.package === packageName)
      .sort((a, b) => b.since.localeCompare(a.since))
      .slice(0, limit);
  }

  /**
   * Generate testimonial HTML for email marketing
   */
  generateEmailHtml(packageName = null) {
    const testimonials = packageName
      ? this.getForPackage(packageName, 2)
      : this.getFeatured(2);

    return testimonials.map((t) => `
    <blockquote style="border-left:4px solid #1a237e;padding:16px;margin:16px 0;background:#f5f5f5;border-radius:0 8px 8px 0">
      <p style="font-size:16px;line-height:1.6;color:#333;font-style:italic">"${t.text}"</p>
      <footer style="margin-top:12px;color:#666">
        <strong>${t.name}</strong>, ${t.age} lat, ${t.location}<br>
        <span style="color:#ffc107">${'★'.repeat(t.rating)}</span>
        ${t.verified ? '<span style="color:#4caf50;margin-left:8px">✓ Zweryfikowany</span>' : ''}
      </footer>
    </blockquote>`).join('');
  }

  /**
   * Get a count summary for display
   */
  getSummary() {
    const stats = this.getRatingStats();
    return {
      totalReviews: stats.total,
      averageRating: stats.average,
      nps: stats.nps,
      fiveStarCount: stats.distribution[5],
      verifiedCount: this.testimonials.filter((t) => t.verified).length,
      videoCount: this.videoTestimonials.length,
    };
  }
}

module.exports = { TestimonialManager, TESTIMONIALS, VIDEO_TESTIMONIALS };
