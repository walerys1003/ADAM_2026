import 'dart:convert';

/// SEO Metadata Service for Landing Page
/// Manages meta tags, Open Graph, Twitter Cards and structured data for search engines
class SeoMetadataService {
  final Map<String, String> _defaultMeta = {
    'title': 'Agent Adam — Asystent Głosowy AI dla Seniorów | SilverTech',
    'description':
        'Agent Adam to inteligentny asystent głosowy dla seniorów. '
        'Działa 24/7 — przypomina o lekach, umawia wizyty, monitoruje zdrowie i zapewnia '
        'bezpieczeństwo. Sprawdź pakiety od 99 zł/mies.',
    'keywords':
        'asystent głosowy senior, AI senior, opieka nad seniorem, '
        'monitoring zdrowia senior, teleopieka, smart opaska senior, Agent Adam SilverTech',
    'author': 'SilverTech',
    'og:type': 'website',
    'og:site_name': 'Agent Adam — SilverTech',
    'og:locale': 'pl_PL',
    'twitter:card': 'summary_large_image',
    'twitter:site': '@SilverTechPL',
  };

  final Map<String, String> _pageMeta = {};

  /// Get all meta tags for a specific page
  Map<String, String> getMetaTags(String page) {
    final tags = Map<String, String>.from(_defaultMeta);
    tags.addAll(_pageMeta[page] ?? {});
    return tags;
  }

  /// Set page-specific meta
  void setPageMeta(String page, Map<String, String> meta) {
    _pageMeta[page] = meta;
  }

  /// Generate JSON-LD structured data for the landing page
  String generateStructuredData() {
    final jsonLd = {
      '@context': 'https://schema.org',
      '@type': 'SoftwareApplication',
      'name': 'Agent Adam',
      'applicationCategory': 'HealthApplication',
      'operatingSystem': 'Android, iOS',
      'description':
          'Inteligentny asystent głosowy AI dla seniorów — przypomnienia o lekach, '
          'monitoring zdrowia, teleopieka 24/7.',
      'offers': {
        '@type': 'AggregateOffer',
        'lowPrice': '99',
        'highPrice': '299',
        'priceCurrency': 'PLN',
        'offers': [
          {
            '@type': 'Offer',
            'name': 'KONTAKT',
            'price': '99',
            'priceCurrency': 'PLN',
            'description': 'Podstawowy asystent głosowy',
          },
          {
            '@type': 'Offer',
            'name': 'ZDROWIE',
            'price': '199',
            'priceCurrency': 'PLN',
            'description': 'Monitoring zdrowia + AI',
          },
          {
            '@type': 'Offer',
            'name': 'AKTYWNY',
            'price': '299',
            'priceCurrency': 'PLN',
            'description': 'Pełny pakiet premium',
          },
        ],
      },
      'provider': {
        '@type': 'Organization',
        'name': 'SilverTech',
        'url': 'https://silvertech.pl',
      },
      'aggregateRating': {
        '@type': 'AggregateRating',
        'ratingValue': '4.8',
        'reviewCount': '127',
      },
    };

    return const JsonEncoder.withIndent('  ').convert(jsonLd);
  }

  /// Generate HTML meta tags string for web
  String generateHtmlMeta(String page) {
    final tags = getMetaTags(page);
    final buffer = StringBuffer();

    buffer.writeln('<title>${tags['title']}</title>');
    buffer.writeln('<meta name="description" content="${tags['description']}">');
    buffer.writeln('<meta name="keywords" content="${tags['keywords']}">');
    buffer.writeln('<meta name="author" content="${tags['author']}">');

    // Open Graph
    buffer.writeln('<meta property="og:title" content="${tags['title']}">');
    buffer.writeln('<meta property="og:description" content="${tags['description']}">');
    buffer.writeln('<meta property="og:type" content="${tags['og:type']}">');
    buffer.writeln('<meta property="og:site_name" content="${tags['og:site_name']}">');
    buffer.writeln('<meta property="og:locale" content="${tags['og:locale']}">');
    buffer.writeln(
        '<meta property="og:image" content="https://agentadam.pl/images/og-image.jpg">');

    // Twitter
    buffer.writeln('<meta name="twitter:card" content="${tags['twitter:card']}">');
    buffer.writeln('<meta name="twitter:site" content="${tags['twitter:site']}">');
    buffer.writeln('<meta name="twitter:title" content="${tags['title']}">');
    buffer.writeln('<meta name="twitter:description" content="${tags['description']}">');

    // Canonical
    buffer.writeln('<link rel="canonical" href="https://agentadam.pl/$page">');

    return buffer.toString();
  }

  /// Get sitemap URLs for SEO
  List<String> getSitemapUrls() {
    return [
      'https://agentadam.pl/',
      'https://agentadam.pl/blog',
      'https://agentadam.pl/kontakt',
      'https://agentadam.pl/cennik',
      'https://agentadam.pl/jak-to-dziala',
      'https://agentadam.pl/o-nas',
      'https://agentadam.pl/rodo',
      'https://agentadam.pl/regulamin',
    ];
  }
}
