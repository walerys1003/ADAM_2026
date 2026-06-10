/**
 * SilverTech Agent Adam — SEO Metadata Generator
 * Dynamic SEO metadata generation for landing page:
 * - Page-specific title/description/keywords
 * - Open Graph + Twitter Card tags
 * - Structured data (JSON-LD) for rich snippets
 * - Sitemap.xml generation
 * - Robots.txt configuration
 * - Multi-language support (PL, EN)
 * - Canonical URLs and hreflang tags
 */

// Base domain configuration
const BASE_CONFIG = {
  domain: 'https://silvertech.ai',
  siteName: 'Agent Adam — Senior Companion',
  defaultLocale: 'pl',
  locales: ['pl', 'en'],
  social: {
    twitter: '@AgentAdamAI',
    facebook: 'AgentAdamSeniorCompanion',
  },
};

// Page-specific SEO metadata
const PAGE_SEO = {
  home: {
    pl: {
      title: 'Agent Adam — Asystent AI dla Seniorów | SilverTech',
      description: 'Agent Adam to inteligentny asystent głosowy dla seniorów. Monitoring zdrowia Xiaomi Band 9 Pro, przypomnienia o lekach, kontakt z rodziną i pomoc 24/7. Od 99 zł/mies.',
      keywords: 'asystent seniora, AI dla seniorów, monitoring zdrowia seniora, opaska Xiaomi Band 9 Pro, przypomnienia o lekach, SOS dla seniora, teleopieka, asystent głosowy senior',
      ogImage: '/images/og/agent-adam-home.jpg',
    },
    en: {
      title: 'Agent Adam — AI Assistant for Seniors | SilverTech',
      description: 'Agent Adam is an intelligent voice assistant for seniors. Xiaomi Band 9 Pro health monitoring, medication reminders, family contact, and 24/7 support. From €20/month.',
      keywords: 'senior assistant, AI for elderly, senior health monitoring, Xiaomi Band 9 Pro, medication reminders, senior SOS, telecare, voice assistant elderly',
      ogImage: '/images/og/agent-adam-home-en.jpg',
    },
  },
  pricing: {
    pl: {
      title: 'Cennik — Agent Adam | Plany od 99 zł/mies.',
      description: 'Wybierz plan dla siebie lub bliskiej osoby. KONTAKT (99 zł), ZDROWIE (199 zł), AKTYWNY (299 zł). Monitoring zdrowia, asystent AI, marketplace usług.',
      keywords: 'cennik Agent Adam, koszt asystenta seniora, opieka nad seniorem cena, monitoring zdrowia cena, teleopieka cennik',
      ogImage: '/images/og/agent-adam-pricing.jpg',
    },
    en: {
      title: 'Pricing — Agent Adam | Plans from €20/month',
      description: 'Choose a plan for yourself or a loved one. KONTAKT (€20), ZDROWIE (€40), AKTYWNY (€60). Health monitoring, AI assistant, service marketplace.',
      keywords: 'Agent Adam pricing, senior assistant cost, elderly care pricing, health monitoring cost',
      ogImage: '/images/og/agent-adam-pricing-en.jpg',
    },
  },
  blog: {
    pl: {
      title: 'Blog — Agent Adam | Poradnik dla Seniorów i Rodzin',
      description: 'Artykuły o zdrowiu seniorów, nowych technologiach, bezpieczeństwie i samodzielności. Porady dotyczące opieki nad bliskimi.',
      keywords: 'blog senior, zdrowie seniora, technologie dla seniorów, opieka nad seniorem, porady rodzinne',
      ogImage: '/images/og/agent-adam-blog.jpg',
    },
    en: {
      title: 'Blog — Agent Adam | Guide for Seniors and Families',
      description: 'Articles about senior health, new technologies, safety, and independence. Tips for caring for loved ones.',
      keywords: 'senior blog, elderly health, technology for seniors, elder care, family tips',
      ogImage: '/images/og/agent-adam-blog-en.jpg',
    },
  },
  contact: {
    pl: {
      title: 'Kontakt — Agent Adam | SilverTech',
      description: 'Skontaktuj się z nami. Masz pytania o Agent Adam? Chcesz demo? Jesteśmy dostępni telefonicznie i mailowo.',
      keywords: 'kontakt Agent Adam, SilverTech kontakt, demo asystenta seniora, wsparcie techniczne',
    },
    en: {
      title: 'Contact — Agent Adam | SilverTech',
      description: 'Contact us. Questions about Agent Adam? Want a demo? Available by phone and email.',
      keywords: 'contact Agent Adam, SilverTech contact, senior assistant demo, technical support',
    },
  },
  about: {
    pl: {
      title: 'O nas — Agent Adam | SilverTech',
      description: 'SilverTech tworzy technologie wspierające samodzielność seniorów. Agent Adam to nasz flagowy produkt — asystent AI z misją.',
      keywords: 'SilverTech o nas, misja, zespół, technologia dla seniorów, startup',
    },
    en: {
      title: 'About Us — Agent Adam | SilverTech',
      description: 'SilverTech creates technology supporting senior independence. Agent Adam is our flagship AI assistant with a mission.',
      keywords: 'SilverTech about us, mission, team, senior technology, startup',
    },
  },
};

class SeoMetadataGenerator {
  constructor(config = {}) {
    this.config = { ...BASE_CONFIG, ...config };
  }

  /**
   * Get SEO metadata for a specific page
   */
  getPageSeo(page, locale = 'pl') {
    const pageData = PAGE_SEO[page];
    if (!pageData) {
      return this._getDefaultSeo(locale);
    }

    const data = pageData[locale] || pageData[this.config.defaultLocale];

    return {
      title: data.title,
      meta: {
        description: data.description,
        keywords: data.keywords,
        robots: this._getRobots(page),
        canonical: this._getCanonical(page, locale),
      },
      og: this._buildOpenGraph(page, data, locale),
      twitter: this._buildTwitterCard(page, data),
      jsonLd: this._buildJsonLd(page, data, locale),
      hreflang: this._buildHreflang(page),
    };
  }

  /**
   * Get SEO metadata for a blog post
   */
  getBlogPostSeo(post, locale = 'pl') {
    return {
      title: `${post.title} | Agent Adam Blog`,
      meta: {
        description: post.excerpt || post.title,
        keywords: post.tags?.join(', ') || 'senior, blog, Agent Adam',
        robots: 'index, follow',
        canonical: `${this.config.domain}/blog/${post.slug}`,
      },
      og: {
        title: post.title,
        description: post.excerpt,
        type: 'article',
        url: `${this.config.domain}/blog/${post.slug}`,
        image: post.imageUrl || `${this.config.domain}/images/og/agent-adam-blog.jpg`,
        imageAlt: post.title,
        publishedTime: post.publishedAt,
        author: post.author,
        tags: post.tags,
      },
      twitter: {
        card: 'summary_large_image',
        title: post.title,
        description: post.excerpt,
        image: post.imageUrl,
      },
      jsonLd: {
        '@context': 'https://schema.org',
        '@type': 'BlogPosting',
        headline: post.title,
        description: post.excerpt,
        image: post.imageUrl,
        datePublished: post.publishedAt,
        author: {
          '@type': 'Person',
          name: post.author,
        },
        publisher: {
          '@type': 'Organization',
          name: 'SilverTech',
          logo: {
            '@type': 'ImageObject',
            url: `${this.config.domain}/images/silvertech-logo.png`,
          },
        },
        mainEntityOfPage: {
          '@type': 'WebPage',
          '@id': `${this.config.domain}/blog/${post.slug}`,
        },
      },
    };
  }

  /**
   * Generate sitemap.xml content
   */
  generateSitemap(pages, blogPosts = []) {
    const urls = [];

    // Static pages
    for (const page of pages) {
      for (const locale of this.config.locales) {
        const loc = locale === this.config.defaultLocale
          ? `${this.config.domain}/${page === 'home' ? '' : page}`
          : `${this.config.domain}/${locale}/${page === 'home' ? '' : page}`;
        urls.push({
          loc,
          changefreq: page === 'home' ? 'daily' : 'weekly',
          priority: page === 'home' ? 1.0 : page === 'pricing' ? 0.9 : 0.7,
        });
      }
    }

    // Blog posts
    for (const post of blogPosts) {
      urls.push({
        loc: `${this.config.domain}/blog/${post.slug}`,
        lastmod: post.updatedAt || post.publishedAt,
        changefreq: post.updatedAt ? 'weekly' : 'monthly',
        priority: 0.6,
      });
    }

    return this._buildSitemapXml(urls);
  }

  /**
   * Generate robots.txt content
   */
  generateRobotsTxt() {
    return [
      '# Agent Adam — SilverTech',
      '# https://silvertech.ai',
      '',
      'User-agent: *',
      'Allow: /',
      '',
      'Disallow: /api/',
      'Disallow: /admin/',
      'Disallow: /health/',
      '',
      `Sitemap: ${this.config.domain}/sitemap.xml`,
      '',
      `Host: ${this.config.domain}`,
    ].join('\n');
  }

  // ─── Private Builders ────────────────────────────────────

  _buildOpenGraph(page, data, locale) {
    return {
      title: data.title,
      description: data.description,
      type: page === 'blog' ? 'website' : 'website',
      url: this._getCanonical(page, locale),
      image: data.ogImage || `${this.config.domain}/images/og/agent-adam-default.jpg`,
      imageAlt: data.title,
      siteName: this.config.siteName,
      locale: this._getOgLocale(locale),
    };
  }

  _buildTwitterCard(page, data) {
    return {
      card: 'summary_large_image',
      site: this.config.social.twitter,
      creator: this.config.social.twitter,
      title: data.title,
      description: data.description,
      image: data.ogImage || `${this.config.domain}/images/og/agent-adam-default.jpg`,
    };
  }

  _buildJsonLd(page, data, locale) {
    // Organization structured data (same for all pages)
    const org = {
      '@context': 'https://schema.org',
      '@type': 'Organization',
      '@id': `${this.config.domain}/#organization`,
      name: 'SilverTech',
      alternateName: 'SilverTech Sp. z o.o.',
      description: this.config.siteName,
      url: this.config.domain,
      logo: `${this.config.domain}/images/silvertech-logo.png`,
      contactPoint: {
        '@type': 'ContactPoint',
        telephone: '+48-22-123-45-67',
        contactType: 'customer service',
        availableLanguage: ['Polish', 'English'],
      },
      sameAs: [
        'https://twitter.com/AgentAdamAI',
        'https://facebook.com/AgentAdamSeniorCompanion',
      ],
    };

    // Page-specific structured data
    if (page === 'pricing') {
      return [org, this._buildProductJsonLd()];
    }

    return [org, {
      '@context': 'https://schema.org',
      '@type': 'WebApplication',
      '@id': `${this._getCanonical(page, locale)}#webapp`,
      name: 'Agent Adam',
      description: data.description,
      applicationCategory: 'HealthApplication',
      operatingSystem: 'Android, Web',
      offers: {
        '@type': 'Offer',
        price: '99.00',
        priceCurrency: 'PLN',
        priceValidUntil: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000)
          .toISOString().split('T')[0],
      },
    }];
  }

  _buildProductJsonLd() {
    return {
      '@context': 'https://schema.org',
      '@type': 'SoftwareApplication',
      name: 'Agent Adam',
      description: 'Asystent AI dla seniorów z monitoringiem zdrowia',
      applicationCategory: 'HealthApplication',
      offers: {
        '@type': 'AggregateOffer',
        lowPrice: '99',
        highPrice: '299',
        priceCurrency: 'PLN',
        offerCount: '3',
        offers: [
          {
            '@type': 'Offer',
            name: 'KONTAKT',
            price: '99',
            priceCurrency: 'PLN',
            description: 'Pakiet podstawowy z asystentem 24/7',
          },
          {
            '@type': 'Offer',
            name: 'ZDROWIE',
            price: '199',
            priceCurrency: 'PLN',
            description: 'Pakiet z monitoringiem zdrowia',
          },
          {
            '@type': 'Offer',
            name: 'AKTYWNY',
            price: '299',
            priceCurrency: 'PLN',
            description: 'Pakiet premium z marketplace i telemedycyną',
          },
        ],
      },
    };
  }

  _buildHreflang(page) {
    const tags = [];
    for (const locale of this.config.locales) {
      tags.push({
        locale,
        url: locale === this.config.defaultLocale
          ? `${this.config.domain}/${page === 'home' ? '' : page}`
          : `${this.config.domain}/${locale}/${page === 'home' ? '' : page}`,
      });
    }
    return tags;
  }

  _getCanonical(page, locale) {
    return locale === this.config.defaultLocale
      ? `${this.config.domain}/${page === 'home' ? '' : page}`
      : `${this.config.domain}/${locale}/${page === 'home' ? '' : page}`;
  }

  _getRobots(page) {
    const privatePages = ['admin', 'health'];
    return privatePages.includes(page) ? 'noindex, nofollow' : 'index, follow';
  }

  _getOgLocale(locale) {
    const map = { pl: 'pl_PL', en: 'en_US' };
    return map[locale] || 'pl_PL';
  }

  _getDefaultSeo(locale) {
    return this.getPageSeo('home', locale);
  }

  _buildSitemapXml(urls) {
    const items = urls.map((u) => {
      let entry = `  <url>\n    <loc>${u.loc}</loc>\n`;
      if (u.lastmod) entry += `    <lastmod>${u.lastmod}</lastmod>\n`;
      if (u.changefreq) entry += `    <changefreq>${u.changefreq}</changefreq>\n`;
      if (u.priority) entry += `    <priority>${u.priority}</priority>\n`;
      entry += '  </url>';
      return entry;
    });

    return [
      '<?xml version="1.0" encoding="UTF-8"?>',
      '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"',
      '        xmlns:xhtml="http://www.w3.org/1999/xhtml">',
      ...items,
      '</urlset>',
    ].join('\n');
  }
}

module.exports = { SeoMetadataGenerator, PAGE_SEO, BASE_CONFIG };
