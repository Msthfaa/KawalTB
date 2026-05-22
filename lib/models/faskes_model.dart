/// Represents a single TBC service offered by a facility.
class TbService {
  final String serviceName;
  final String description;

  const TbService({required this.serviceName, required this.description});

  factory TbService.fromJson(Map<String, dynamic> json) {
    return TbService(
      serviceName: json['service_name'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}

/// Model representing a medical facility (Faskes = Fasilitas Kesehatan).
/// Matches the Supabase `faskes` table schema.
class FaskesModel {
  final int id;
  final String name;         // nama_faskes
  final String category;     // kategori_faskes
  final double latitude;
  final double longitude;
  final String operatingHours;   // jam_operasional
  final String emergencyContact; // nomor_darurat
  final List<TbService> tbServices; // layanan_tbc_tersedia (JSONB array)
  final bool acceptsBpjs;    // terima_bpjs

  const FaskesModel({
    required this.id,
    required this.name,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.operatingHours,
    required this.emergencyContact,
    required this.tbServices,
    required this.acceptsBpjs,
  });

  factory FaskesModel.fromJson(Map<String, dynamic> json) {
    final rawServices = json['layanan_tbc_tersedia'];
    List<TbService> services = [];
    if (rawServices is List) {
      services = rawServices
          .map((e) => TbService.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return FaskesModel(
      id: json['id'] as int? ?? 0,
      name: json['nama_faskes'] as String? ?? '',
      category: json['kategori_faskes'] as String? ?? 'Rumah Sakit',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      operatingHours: json['jam_operasional'] as String? ?? '-',
      emergencyContact: json['nomor_darurat'] as String? ?? '-',
      tbServices: services,
      acceptsBpjs: json['terima_bpjs'] as bool? ?? false,
    );
  }
}
