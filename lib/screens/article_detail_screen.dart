import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_colors.dart';

class ArticleDetailScreen extends StatelessWidget {
  final String url;
  final String title;
  final String? description;
  final String? imageUrl;
  final String? content;
  final String? publishedAt;

  const ArticleDetailScreen({
    super.key,
    required this.url,
    required this.title,
    this.description,
    this.imageUrl,
    this.content,
    this.publishedAt,
  });

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final dt = DateTime.parse(dateStr);
      final months = [
        '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
      ];
      return '${dt.day} ${months[dt.month]} ${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }

  /// Cleans content by removing "[... chars]" truncation markers from GNews API
  String _cleanContent(String? rawContent) {
    if (rawContent == null || rawContent.isEmpty) return '';
    // GNews API appends "[XXX chars]" at the end of truncated content
    return rawContent.replaceAll(RegExp(r'\[\d+ chars\]$'), '').trim();
  }

  Future<void> _openFullArticle(BuildContext context) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka artikel')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cleanedContent = _cleanContent(content);
    final formattedDate = _formatDate(publishedAt);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          // ── Image Hero with AppBar ──────────────────────────────────
          SliverAppBar(
            expandedHeight: imageUrl != null && imageUrl!.isNotEmpty ? 260 : 0,
            pinned: true,
            backgroundColor: AppColors.surface,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: imageUrl != null && imageUrl!.isNotEmpty
                ? FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.primarySurface,
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  size: 48,
                                  color: AppColors.primary,
                                ),
                              ),
                            );
                          },
                        ),
                        // Gradient overlay for readability
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black26,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : null,
          ),

          // ── Article Content ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source label
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'ARTIKEL KESEHATAN',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Date
                  if (formattedDate.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF94A3B8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Divider
                  Container(
                    height: 1,
                    color: const Color(0xFFE2E8F0),
                  ),
                  const SizedBox(height: 20),

                  // Description
                  if (description != null && description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        description!,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF334155),
                          fontWeight: FontWeight.w600,
                          height: 1.6,
                        ),
                      ),
                    ),

                  // Content
                  if (cleanedContent.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        cleanedContent,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF475569),
                          height: 1.7,
                        ),
                      ),
                    ),

                  // Info note
                  Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: Color(0xFF94A3B8),
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Ini adalah cuplikan artikel. Klik tombol di bawah untuk membaca artikel lengkap di sumber aslinya.',
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(0xFF64748B),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // CTA Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _openFullArticle(context),
                      icon: const Icon(Icons.open_in_new_rounded, size: 18),
                      label: const Text(
                        'Baca Artikel Lengkap',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
