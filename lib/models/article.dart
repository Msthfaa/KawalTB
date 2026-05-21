class Article {
  final String title;
  final String description;
  final String url;
  final String image;
  final String content;
  final String publishedAt;

  Article({
    required this.title,
    required this.description,
    required this.url,
    required this.image,
    this.content = '',
    this.publishedAt = '',
  });

  /// Factory method to safely parse JSON response, handling nulls with fallback defaults.
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? 'Tanpa Judul',
      description: json['description'] ?? 'Tidak ada deskripsi untuk artikel ini.',
      url: json['url'] ?? '',
      image: json['image'] ?? json['urlToImage'] ?? '', // Handles both GNews ('image') and NewsAPI ('urlToImage') format
      content: json['content'] ?? '',
      publishedAt: json['publishedAt'] ?? '',
    );
  }
}
