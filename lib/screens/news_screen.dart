import 'package:flutter/material.dart';
import 'article_detail_screen.dart';
import '../core/app_colors.dart';
import '../models/article.dart';
import '../services/news_service.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final NewsService _newsService = NewsService();
  late Future<List<Article>> _newsFuture;

  @override
  void initState() {
    super.initState();
    // Menyimpan Future agar tidak memicu pemanggilan ulang API saat terjadi rebuild widget tree
    _newsFuture = _newsService.fetchTBCNews();
  }

  Future<void> _refreshNews() async {
    setState(() {
      _newsFuture = _newsService.fetchTBCNews();
    });
  }

  void _openArticle(Article article) {
    if (article.url.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ArticleDetailScreen(
          url: article.url,
          title: article.title,
          description: article.description,
          imageUrl: article.image,
          content: article.content,
          publishedAt: article.publishedAt,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Edukasi & Berita TBC',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: _refreshNews,
          )
        ],
      ),
      body: FutureBuilder<List<Article>>(
        future: _newsFuture,
        builder: (context, snapshot) {
          // ── State 1: Loading ──────────────────────────────────────
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          // ── State 2: Error ────────────────────────────────────────
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 64, color: AppColors.error),
                    const SizedBox(height: 16),
                    const Text(
                      'Gagal memuat berita',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString().replaceAll("Exception: ", ""),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _refreshNews,
                      icon: const Icon(Icons.replay_rounded),
                      label: const Text('Coba Lagi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          }

          // ── State 3: Kosong (No Data) ──────────────────────────────
          final articles = snapshot.data ?? [];
          if (articles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.newspaper_rounded, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'Tidak ada berita terbaru saat ini.',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          // ── State 4: Sukses (Success) ──────────────────────────────
          return RefreshIndicator(
            onRefresh: _refreshNews,
            color: AppColors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return Card(
                  elevation: 2,
                  shadowColor: AppColors.shadow.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFF1F5F9)),
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _openArticle(article),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Gambar Header dengan fallback errorBuilder
                        if (article.image.isNotEmpty)
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Image.network(
                              article.image,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 180,
                                  color: AppColors.primarySurface,
                                  width: double.infinity,
                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      size: 40,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                article.title,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                article.description,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'Baca Selengkapnya',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward,
                                    size: 14,
                                    color: AppColors.primary,
                                  ),
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
