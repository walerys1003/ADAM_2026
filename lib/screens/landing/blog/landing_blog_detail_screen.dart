import 'package:flutter/material.dart';

/// Landing Page — Blog Detail Screen
/// Full article view with hero image, metadata, content, and related posts
class LandingBlogDetailScreen extends StatelessWidget {
  final BlogPost post;

  const LandingBlogDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App bar with back button
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF1B5E20),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF1B5E20),
                      const Color(0xFF1B5E20).withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            post.category,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          post.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author & date
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: const Color(0xFF1B5E20).withValues(alpha: 0.1),
                        child: Text(
                          post.author[0],
                          style: const TextStyle(
                            color: Color(0xFF1B5E20),
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.author,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                          Text(
                            post.date,
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text('${post.readTime} min', style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Article content
                  Text(
                    post.content,
                    style: const TextStyle(
                      fontSize: 17,
                      height: 1.8,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Tags
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: post.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B5E20).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(color: Color(0xFF1B5E20), fontSize: 14),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 40),
                  // CTA banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Chcesz dowiedzieć się więcej?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Skontaktuj się z nami — pomożemy dobrać najlepszy pakiet dla Twoich bliskich.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 220,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1B5E20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: const Text(
                              'Skontaktuj się',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Related posts section
                  const Text(
                    'Powiązane artykuły',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _relatedPosts.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final related = _relatedPosts[index];
                        return SizedBox(
                          width: 200,
                          child: Card(
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => LandingBlogDetailScreen(post: related),
                                  ),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 80,
                                    color: const Color(0xFF1B5E20).withValues(alpha: 0.1),
                                    child: const Center(
                                      child: Icon(Icons.article, color: Color(0xFF1B5E20), size: 32),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        related.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static final List<BlogPost> _relatedPosts = [
    BlogPost(
      title: 'Jak technologia AI pomaga seniorom zachować niezależność',
      category: 'Technologia',
      author: 'Anna Kowalska',
      date: '15.06.2026',
      readTime: 6,
      tags: ['AI', 'niezależność', 'seniorzy'],
      content: '',
    ),
    BlogPost(
      title: '5 sposobów na lepszą komunikację z bliskimi po 70-tce',
      category: 'Porady',
      author: 'Dr Marek Nowak',
      date: '10.06.2026',
      readTime: 8,
      tags: ['komunikacja', 'rodzina', 'relacje'],
      content: '',
    ),
    BlogPost(
      title: 'Zdrowie seniora — jak monitorować kluczowe parametry?',
      category: 'Zdrowie',
      author: 'Dr Maria Wiśniewska',
      date: '05.06.2026',
      readTime: 7,
      tags: ['zdrowie', 'monitorowanie', 'wearable'],
      content: '',
    ),
  ];
}

class BlogPost {
  final String title;
  final String category;
  final String author;
  final String date;
  final int readTime;
  final List<String> tags;
  final String content;

  const BlogPost({
    required this.title,
    required this.category,
    required this.author,
    required this.date,
    required this.readTime,
    required this.tags,
    required this.content,
  });
}
