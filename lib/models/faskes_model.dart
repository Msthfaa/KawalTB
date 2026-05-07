/// Model representing a medical facility (Faskes = Fasilitas Kesehatan).
/// Replace [latitude] / [longitude] with real coordinates when integrating maps.
class FaskesModel {
  final String id;
  final String name;
  final String category; // e.g., "Rumah Sakit", "Klinik", "Puskesmas"
  final String address;
  final String distance; // e.g., "2.4 km"
  final String operatingHours; // e.g., "Buka 24 Jam"
  final String emergencyContact;
  final bool acceptsBpjs;
  final double rating;
  final List<String> tbFacilities; // TBC-specific facilities
  final double latitude;
  final double longitude;

  const FaskesModel({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.distance,
    required this.operatingHours,
    required this.emergencyContact,
    required this.acceptsBpjs,
    required this.rating,
    required this.tbFacilities,
    required this.latitude,
    required this.longitude,
  });
}

/// Dummy data – swap with real API data when integrating backend.
final List<FaskesModel> dummyFaskesList = [
  const FaskesModel(
    id: 'rs-001',
    name: 'RSUD dr. Soetomo',
    category: 'Rumah Sakit',
    address: 'Jl. Mayjen Prof. dr. Moestopo No.6-8, Airlangga, Kec. Gubeng, Surabaya, Jawa Timur 60286',
    distance: '2.4 km',
    operatingHours: 'Buka 24 Jam',
    emergencyContact: '(031) 5501078',
    acceptsBpjs: true,
    rating: 4.8,
    tbFacilities: ['TCM (Tes Cepat Molekuler)', 'Klinik Paru', 'Ruang Isolasi Tekanan Negatif'],
    latitude: -7.2756,
    longitude: 112.7589,
  ),
  const FaskesModel(
    id: 'pusk-001',
    name: 'Puskesmas Gubeng',
    category: 'Puskesmas',
    address: 'Jl. Gubeng Jaya No.54, Gubeng, Surabaya, Jawa Timur',
    distance: '0.8 km',
    operatingHours: 'Senin–Jumat, 08.00–14.00',
    emergencyContact: '(031) 5035588',
    acceptsBpjs: true,
    rating: 4.2,
    tbFacilities: ['Pengambilan Dahak', 'Pemberian OAT', 'Konsultasi PMO'],
    latitude: -7.2701,
    longitude: 112.7508,
  ),
  const FaskesModel(
    id: 'klinik-001',
    name: 'Klinik Pratama Sehat Bersama',
    category: 'Klinik',
    address: 'Jl. Raya Darmo No.17, Wonokromo, Surabaya, Jawa Timur',
    distance: '3.1 km',
    operatingHours: 'Setiap Hari, 07.00–21.00',
    emergencyContact: '(031) 5678901',
    acceptsBpjs: true,
    rating: 4.5,
    tbFacilities: ['Tes BTA', 'Foto Rontgen', 'Konsultasi Dokter Umum'],
    latitude: -7.2911,
    longitude: 112.7349,
  ),
  const FaskesModel(
    id: 'rs-002',
    name: 'RS Islam A. Yani',
    category: 'Rumah Sakit',
    address: 'Jl. Ahmad Yani No.2-4, Wonokromo, Surabaya, Jawa Timur 60243',
    distance: '4.0 km',
    operatingHours: 'Buka 24 Jam',
    emergencyContact: '(031) 8285555',
    acceptsBpjs: true,
    rating: 4.6,
    tbFacilities: ['Poli Paru', 'TCM', 'Rawat Inap Isolasi'],
    latitude: -7.3023,
    longitude: 112.7376,
  ),
];
