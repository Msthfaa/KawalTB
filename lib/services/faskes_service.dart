import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/faskes_model.dart';

/// Fetches healthcare facility (faskes) data from the Supabase `faskes` table.
class FaskesService {
  FaskesService._();
  static final FaskesService instance = FaskesService._();

  final _client = Supabase.instance.client;

  /// Returns all faskes rows from Supabase, ordered by name.
  Future<List<FaskesModel>> fetchAll() async {
    final response = await _client
        .from('faskes')
        .select()
        .order('nama_faskes', ascending: true);

    return (response as List<dynamic>)
        .map((e) => FaskesModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Returns faskes filtered by category (e.g. "Rumah Sakit").
  Future<List<FaskesModel>> fetchByCategory(String category) async {
    final response = await _client
        .from('faskes')
        .select()
        .eq('kategori_faskes', category)
        .order('nama_faskes', ascending: true);

    return (response as List<dynamic>)
        .map((e) => FaskesModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
