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
        title: "Tuberkulosis (TBC) - Penyebab, Gejala, Pengobatan & Pencegahan",
        description: "Butuh info Tuberkulosis (TBC) untukmu atau keluarga? Baca Gejala, Penyebab, Pencegahan & Pengobatan. Pakai Halodoc kapan & dari mana saja.",
        url: "https://www.halodoc.com/kesehatan/tuberkulosis",
        image: "https://d1vbn70lmn1nqe.cloudfront.net/prod/wp-content/uploads/2021/06/20060124/tuberkulosis-halodoc.jpg",
      ),
      Article(
        title: "TBC (Tuberkulosis) - Gejala, penyebab dan mengobati - Alodokter",
        description: "Tuberkulosis (TBC) atau TB adalah penyakit menular akibat infeksi bakteri. TBC umumnya menyerang paru-paru, tetapi juga dapat menyerang organ tubuh lain, seperti ginjal, tulang belakang, dan otak.",
        url: "https://www.alodokter.com/tuberkulosis",
        image: "https://res.cloudinary.com/dk0z4ums3/image/upload/v1589445100/attached_image/tuberkulosis.jpg",
      ),
      Article(
        title: "Tuberkulosis - Wikipedia bahasa Indonesia, ensiklopedia bebas",
        description: "Tuberkulosis, sering disingkat TB atau TBC, adalah penyakit menular yang umumnya memengaruhi paru-paru. Penyakit ini disebabkan oleh infeksi bakteri Mycobacterium tuberculosis.",
        url: "https://id.wikipedia.org/wiki/Tuberkulosis",
        image: "https://upload.wikimedia.org/wikipedia/commons/thumb/c/ca/Tuberculosis-x-ray-1.jpg/1200px-Tuberculosis-x-ray-1.jpg",
      ),
      Article(
        title: "Mycobacterium tuberculosis - Wikipedia bahasa Indonesia, ensiklopedia bebas",
        description: "Mycobacterium tuberculosis adalah spesies bakteri patogen serta agen penyebab utama tuberkulosis. Bakteri ini pertama kali ditemukan pada 1882 oleh Robert Koch.",
        url: "https://id.wikipedia.org/wiki/Mycobacterium_tuberculosis",
        image: "https://upload.wikimedia.org/wikipedia/commons/0/0a/TB_Culture.jpg",
      ),
      Article(
        title: "Vaksin Bacillus Calmette-Guérin - Wikipedia bahasa Indonesia, ensiklopedia bebas",
        description: "Vaksin Bacillus Calmette-Guérin (BCG) adalah vaksin yang utamanya digunakan untuk mencegah tuberkulosis (TB). Satu dosis vaksin dianjurkan pada bayi sehat secepatnya setelah lahir.",
        url: "https://id.wikipedia.org/wiki/Vaksin_BCG",
        image: "https://upload.wikimedia.org/wikipedia/commons/2/25/Mycobacterium_bovis_BCG_ZN.jpg",
      ),
      Article(
        title: "Tuberkulosis resistan obat ganda - Wikipedia bahasa Indonesia, ensiklopedia bebas",
        description: "Tuberkulosis resistan obat ganda (MDR-TB) adalah bentuk tuberkulosis (TB) yang disebabkan oleh bakteri yang tidak merespons terhadap pengobatan dengan setidaknya isoniazid dan rifampisin.",
        url: "https://id.wikipedia.org/wiki/Tuberkulosis_resistan_obat_ganda",
        image: "https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?q=80&w=600",
      ),
      Article(
        title: "Tes Mantoux - Wikipedia bahasa Indonesia, ensiklopedia bebas",
        description: "Tes Mantoux atau uji tuberkulin adalah alat diagnostik untuk tuberkulosis. Tes ini digunakan untuk mengetahui apakah seseorang telah terinfeksi bakteri Mycobacterium tuberculosis.",
        url: "https://id.wikipedia.org/wiki/Tes_Mantoux",
        image: "https://images.unsplash.com/photo-1576091160550-2173dba999ef?q=80&w=600",
      ),
      Article(
        title: "Paru-paru - Wikipedia bahasa Indonesia, ensiklopedia bebas",
        description: "Paru-paru adalah organ utama pada sistem pernapasan pada manusia dan hewan lainnya. Infeksi seperti tuberkulosis utamanya menyerang organ paru-paru ini.",
        url: "https://id.wikipedia.org/wiki/Paru-paru",
        image: "https://images.unsplash.com/photo-1502086223501-7ea6ecd79368?q=80&w=600",
      ),
      Article(
        title: "Hari Tuberkulosis Sedunia - Wikipedia bahasa Indonesia, ensiklopedia bebas",
        description: "Hari Tuberkulosis Sedunia diperingati pada tanggal 24 Maret setiap tahun untuk membangun kesadaran masyarakat tentang epidemi tuberkulosis global.",
        url: "https://id.wikipedia.org/wiki/Hari_Tuberkulosis_Sedunia",
        image: "https://images.unsplash.com/photo-1506126613408-eca07ce68773?q=80&w=600",
      ),
      Article(
        title: "Batuk - Wikipedia bahasa Indonesia, ensiklopedia bebas",
        description: "Batuk adalah refleks yang terjadi ketika saluran udara tersumbat atau teriritasi. Batuk berdahak selama lebih dari 2 minggu adalah gejala utama penyakit tuberkulosis.",
        url: "https://id.wikipedia.org/wiki/Batuk",
        image: "https://images.unsplash.com/photo-1490645935967-10de6ba17061?q=80&w=600",
      ),
    ];
  }
}
