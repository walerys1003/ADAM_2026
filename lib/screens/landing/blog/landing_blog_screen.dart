/// SilverTech Agent Adam — Landing Page Blog
/// SEO-optimized blog section with category filtering, search, pagination

import 'package:flutter/material.dart';
import '../../../config/app_config.dart';

class LandingBlogScreen extends StatefulWidget {
  const LandingBlogScreen({super.key});

  @override
  State<LandingBlogScreen> createState() => _LandingBlogScreenState();
}

class _LandingBlogScreenState extends State<LandingBlogScreen> {
  String _selectedCategory = 'Wszystkie';
  final _searchController = TextEditingController();

  final _categories = [
    'Wszystkie',
    'Zdrowie seniora',
    'Technologia',
    'Opieka',
    'Poradniki',
    'Aktualności',
  ];

  final _posts = [
    _BlogPost(
      title: 'Jak AI zmienia opiekę nad seniorami w 2026 roku',
      excerpt: 'Sztuczna inteligencja rewolucjonizuje sposób, w jaki dbamy o naszych bliskich. Agent Adam to przykład, jak technologia może wspierać, a nie zastępować...',
      category: 'Technologia',
      author: 'dr Anna Wiśniewska',
      date: '15 czerwca 2026',
      imageUrl: '',
      readTime: '6 min',
      slug: 'ai-senior-care-2026',
    ),
    _BlogPost(
      title: '5 oznak, że rodzic potrzebuje dodatkowej opieki',
      excerpt: 'Jak rozpoznać moment, w którym rodzic lub dziadek potrzebuje wsparcia? Zebraliśmy 5 kluczowych sygnałów ostrzegawczych...',
      category: 'Opieka',
      author: 'mgr Piotr Kowalski',
      date: '10 czerwca 2026',
      imageUrl: '',
      readTime: '4 min',
      slug: '5-signs-parent-needs-care',
    ),
    _BlogPost(
      title: 'Samotność seniorów — cicha epidemia XXI wieku',
      excerpt: 'Ponad 40% polskich seniorów deklaruje, że czuje się samotnie. Agent Adam powstał właśnie po to, by przeciwdziałać tej tendencji...',
      category: 'Zdrowie seniora',
      author: 'prof. Maria Zielińska',
      date: '5 czerwca 2026',
      imageUrl: '',
      readTime: '8 min',
      slug: 'senior-loneliness-epidemic',
    ),
    _BlogPost(
      title: 'Jak przygotować smartfon dla seniora — poradnik krok po kroku',
      excerpt: 'Prosty przewodnik dla rodzin: jak skonfigurować telefon, by był przyjazny dla starszej osoby. Duże czcionki, uproszczony interfejs...',
      category: 'Poradniki',
      author: 'Zespół SilverTech',
      date: '1 czerwca 2026',
      imageUrl: '',
      readTime: '5 min',
      slug: 'smartphone-senior-setup',
    ),
    _BlogPost(
      title: 'Teleopieka vs. AI Assistant — porównanie rozwiązań',
      excerpt: 'Porównujemy tradycyjną teleopiekę z nowoczesnymi asystentami AI. Co wybrać dla swojego bliskiego? Analiza kosztów i funkcji...',
      category: 'Technologia',
      author: 'dr Anna Wiśniewska',
      date: '28 maja 2026',
      imageUrl: '',
      readTime: '7 min',
      slug: 'telecare-vs-ai-assistant',
    ),
    _BlogPost(
      title: 'Dieta seniora — co jeść, by zachować sprawność umysłową',
      excerpt: 'Produkty bogate w omega-3, antyoksydanty i witaminy z grupy B. Sprawdź, co powinno znaleźć się w diecie Twojego rodzica...',
      category: 'Zdrowie seniora',
      author: 'mgr Katarzyna Nowak, dietetyk',
      date: '20 maja 2026',
      imageUrl: '',
      readTime: '6 min',
      slug: 'senior-diet-brain-health',
    ),
  ];

  List<_BlogPost> get filteredPosts {
    var result = _posts;
    if (_selectedCategory != 'Wszystkie') {
      result = result.where((p) => p.category == _selectedCategory).toList();
    }
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((p) =>
          p.title.toLowerCase().contains(query) ||
          p.excerpt.toLowerCase().contains(query)).toList();
    }
    return result;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.grey.shade50,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Blog Header ────────────────────────────
            _buildHeader(isDark),
            // ── Categories + Search ────────────────────
            _buildFilters(),
            // ── Featured Post ──────────────────────────
            if (filteredPosts.isNotEmpty) _buildFeaturedPost(filteredPosts.first, isDark),
            // ── Posts Grid ─────────────────────────────
            _buildPostsGrid(isDark),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppConfig.brandNavy, const Color(0xFF16213E)]
              : [AppConfig.brandNavy, const Color(0xFF0F3460)],
        ),
      ),
      child: Column(
        children: [
          const Text('Blog SilverTech',
              style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 16),
          Text('Wiedza o zdrowiu, technologii i opiece nad seniorami',
              style: TextStyle(fontSize: 18, color: Colors.white.withValues(alpha: 0.85))),
          const SizedBox(height: 40),
          // Search bar
          Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Szukaj artykułów...',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                prefixIcon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.7)),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: _categories.map((cat) {
            final selected = _selectedCategory == cat;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? AppConfig.brandNavy : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(cat, style: TextStyle(
                    color: selected ? Colors.white : Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  )),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFeaturedPost(_BlogPost post, bool isDark) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(24),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppConfig.brandNavy.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(post.category, style: TextStyle(color: AppConfig.brandNavy, fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                    const SizedBox(width: 12),
                    Text(post.readTime, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(post.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, height: 1.2)),
                const SizedBox(height: 12),
                Text(post.excerpt, style: TextStyle(fontSize: 16, color: Colors.grey.shade600, height: 1.5)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    CircleAvatar(radius: 18, backgroundColor: AppConfig.brandNavy.withValues(alpha: 0.15),
                        child: Text(post.author[0], style: TextStyle(color: AppConfig.brandNavy, fontWeight: FontWeight.w700))),
                    const SizedBox(width: 8),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(post.author, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      Text(post.date, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                    ]),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConfig.brandNavy, foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Czytaj więcej'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostsGrid(bool isDark) {
    final posts = filteredPosts.length > 1 ? filteredPosts.sublist(1) : <_BlogPost>[];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Najnowsze artykuły', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 800 ? 3 : (constraints.maxWidth > 500 ? 2 : 1);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: posts.length,
                itemBuilder: (context, index) => _buildPostCard(posts[index]),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(_BlogPost post) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppConfig.brandNavy.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(post.category,
                    style: TextStyle(color: AppConfig.brandNavy, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 12),
              Text(post.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, height: 1.3),
                  maxLines: 3, overflow: TextOverflow.ellipsis),
              const Spacer(),
              Row(
                children: [
                  Text(post.date, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  const SizedBox(width: 8),
                  Text('· ${post.readTime}', style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BlogPost {
  final String title, excerpt, category, author, date, imageUrl, readTime, slug;
  const _BlogPost({
    required this.title, required this.excerpt, required this.category,
    required this.author, required this.date, this.imageUrl = '',
    required this.readTime, required this.slug,
  });
}
