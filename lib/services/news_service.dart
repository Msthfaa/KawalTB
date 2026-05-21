import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article.dart';

class NewsService {
  /// API Key untuk layanan berita.
  /// BEST PRACTICE: 
  /// Untuk keamanan jangka panjang, Anda sebaiknya memindahkan API Key ke environment variables (.env) 
  /// menggunakan package `flutter_dotenv` agar tidak ter-commit ke Git.
  static const String _apiKey = "9d47c2b108274fd4f6ee01509cffd6d9"; // Ganti dengan GNews API Key Anda dari gnews.io

  /// GNews API adalah rekomendasi terbaik untuk Flutter Mobile karena gratis 
  /// dan memperbolehkan pemanggilan langsung dari Mobile User-Agent tanpa diblokir CORS.

  /// Mengambil berita TBC berbahasa Indonesia
  Future<List<Article>> fetchTBCNews() async {
    if (_apiKey.isEmpty || _apiKey.startsWith("MASUKKAN")) {
      return _getFallbackArticles();
    }

    // Menggunakan query pencarian "Tuberkulosis OR TBC" dengan filter bahasa Indonesia
    final url = Uri.https("gnews.io", "/api/v4/search", {
      "q": "Tuberkulosis OR TBC",
      "lang": "id",
      "apikey": _apiKey,
    });

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> articlesJson = data['articles'] ?? [];
        if (articlesJson.isNotEmpty) {
          final allArticles = articlesJson.map((json) => Article.fromJson(json)).toList();
          final cleanArticles = allArticles.where((article) {
            final urlLower = article.url.toLowerCase();
            return !urlLower.contains("tribunnews.com") &&
                   !urlLower.contains("detik.com") &&
                   !urlLower.contains("merdeka.com") &&
                   !urlLower.contains("liputan6.com") &&
                   !urlLower.contains("grid.id");
          }).toList();
          
          if (cleanArticles.isNotEmpty) {
            return cleanArticles;
          }
          return allArticles;
        }
      }
      
      // Fallback jika response bukan 200 atau kosong
      return _getFallbackArticles();
    } catch (e) {
      // Fallback jika terjadi kesalahan jaringan atau API Key invalid
      return _getFallbackArticles();
    }
  }

  /// Curated fallback articles for Tuberculosis education and news
  List<Article> _getFallbackArticles() {
    return [
      Article(
        title: "Mengenal Gejala TBC dan Cara Pencegahannya",
        description: "Tuberkulosis (TBC) adalah penyakit menular yang disebabkan bakteri Mycobacterium tuberculosis. Gejala utamanya meliputi batuk berdahak selama lebih dari 2 minggu, demam, keringat malam, dan penurunan berat badan secara drastis tanpa alasan jelas. Pelajari cara pencegahannya dengan vaksinasi BCG dan menjaga ventilasi rumah.",
        url: "https://tbindonesia.or.id/informasi/tentang-tbc/",
        image: "https://images.unsplash.com/photo-1576091160550-2173dba999ef?q=80&w=600",
      ),
      Article(
        title: "Pentingnya Kepatuhan Minum Obat TBC Hingga Tuntas",
        description: "Pengobatan TBC membutuhkan kepatuhan luar biasa karena pasien harus minum obat setiap hari selama minimal 6 bulan. Menghentikan konsumsi obat secara sepihak sebelum waktu yang ditentukan sangat berbahaya karena dapat memicu resistensi bakteri (MDR-TB) yang jauh lebih sulit dan lama untuk disembuhkan.",
        url: "https://tbindonesia.or.id/informasi/tentang-tbc/pengobatan-tbc/",
        image: "https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?q=80&w=600",
      ),
      Article(
        title: "Gaya Hidup Sehat & Nutrisi Tepat untuk Penderita TBC",
        description: "Selain kepatuhan minum obat, proses penyembuhan TBC paru didukung oleh asupan nutrisi yang kaya akan protein dan vitamin, istirahat yang cukup, serta menjaga sirkulasi udara bersih di dalam ruangan agar tetap segar dan tidak lembap.",
        url: "https://tbindonesia.or.id/artikel/nutrisi-penting-bagi-pasien-tbc/",
        image: "https://images.unsplash.com/photo-1490645935967-10de6ba17061?q=80&w=600",
      ),
      Article(
        title: "Mitos vs Fakta Seputar Penularan Tuberkulosis",
        description: "Banyak mitos menyebutkan bahwa TBC menular lewat alat makan bersama atau penyakit keturunan. Fakta medis membuktikan bahwa TBC menular hanya melalui udara saat penderita batuk atau bersin. Mari cegah stigma negatif dengan edukasi yang benar.",
        url: "https://tbindonesia.or.id/informasi/tentang-tbc/cara-penularan/",
        image: "https://images.unsplash.com/photo-1506126613408-eca07ce68773?q=80&w=600",
      ),
    ];
  }
}
