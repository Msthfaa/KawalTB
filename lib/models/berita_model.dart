import 'package:flutter/material.dart';

enum BeritaCategory {
  laporan,
  edukasi,
  pengobatan,
  gejala,
  pencegahan,
}

class BeritaModel {
  final String id;
  final String title;
  final String description;
  final String date;
  final BeritaCategory category;
  final Color imageBgColor;
  final IconData imageIcon;

  const BeritaModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.category,
    required this.imageBgColor,
    required this.imageIcon,
  });

  String get categoryLabel {
    switch (category) {
      case BeritaCategory.laporan:
        return 'LAPORAN 2024';
      case BeritaCategory.edukasi:
        return 'EDUKASI';
      case BeritaCategory.pengobatan:
        return 'PENGOBATAN';
      case BeritaCategory.gejala:
        return 'GEJALA';
      case BeritaCategory.pencegahan:
        return 'PENCEGAHAN';
    }
  }

  Color get categoryColor {
    switch (category) {
      case BeritaCategory.laporan:
        return const Color(0xFF2D6A4F);
      case BeritaCategory.edukasi:
        return const Color(0xFF0288D1);
      case BeritaCategory.pengobatan:
        return const Color(0xFF5C6BC0);
      case BeritaCategory.gejala:
        return const Color(0xFFE53935);
      case BeritaCategory.pencegahan:
        return const Color(0xFF00897B);
    }
  }
}

final List<BeritaModel> dummyBeritaList = [
  const BeritaModel(
    id: 'brt-001',
    title: 'Perkembangan Kasus TBC di Indonesia Tahun 2024',
    description:
        'Kementerian Kesehatan merilis data terbaru mengenai tren perkembangan kasus TBC di Indonesia.',
    date: '2 Hari lalu',
    category: BeritaCategory.laporan,
    imageBgColor: Color(0xFF00796B),
    imageIcon: Icons.assignment_rounded,
  ),
  const BeritaModel(
    id: 'brt-002',
    title: 'Cara Efektif Mencegah Penularan TBC di Rumah',
    description:
        'Langkah-langkah sederhana yang bisa dilakukan untuk mencegah penularan TBC di lingkungan rumah.',
    date: '12 Okt 2023',
    category: BeritaCategory.edukasi,
    imageBgColor: Color(0xFF0288D1),
    imageIcon: Icons.wash_rounded,
  ),
  const BeritaModel(
    id: 'brt-003',
    title: 'Pentingnya Tuntas Minum Obat Anti Tuberkulosis',
    description:
        'Ketidakpatuhan dalam mengonsumsi obat dapat menyebabkan resistensi dan memperburuk kondisi.',
    date: '05 Okt 2023',
    category: BeritaCategory.pengobatan,
    imageBgColor: Color(0xFF5C6BC0),
    imageIcon: Icons.medication_rounded,
  ),
  const BeritaModel(
    id: 'brt-004',
    title: 'Kenali Gejala Awal TBC Sebelum Batuk Berkepanjangan',
    description:
        'Gejala awal TBC seringkali tidak spesifik. Kenali tanda-tandanya sejak dini.',
    date: '28 Sep 2023',
    category: BeritaCategory.gejala,
    imageBgColor: Color(0xFFE53935),
    imageIcon: Icons.coronavirus_rounded,
  ),
  const BeritaModel(
    id: 'brt-005',
    title: 'Pentingnya Deteksi Dini TBC',
    description: 'Mengapa gejala awal penting untuk segera diketahui.',
    date: '10 Mei 2023',
    category: BeritaCategory.edukasi,
    imageBgColor: Color(0xFF00796B),
    imageIcon: Icons.search_rounded,
  ),
  const BeritaModel(
    id: 'brt-006',
    title: 'Mitos dan Fakta Penyakit TBC',
    description: 'Banyak yang salah paham tentang penyakit TBC. Ketahui fakta sebenarnya.',
    date: '10 Mei 2023',
    category: BeritaCategory.edukasi,
    imageBgColor: Color(0xFF0288D1),
    imageIcon: Icons.fact_check_rounded,
  ),
];
