
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/drama_database_model.dart';

class DramaSupabaseService {
  final SupabaseClient _client;

  DramaSupabaseService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  // MENGAMBIL DATA DRAMA
  Future<List<DramaDatabaseModel>> getDramas() async {
    final rows = await _client
        .from('dramas')
        .select()
        .order('id', ascending: true);

    return rows
        .map((row) => DramaDatabaseModel.fromJson(row))
        .toList();
  }

  // MENAMBAHKAN DRAMA BARU
  Future<DramaDatabaseModel> createDrama({
    required String title,
    required int? year,
    required String genre,
    String? description,
    String? posterUrl,
  }) async {
    final row = await _client
        .from('dramas')
        .insert({
          'title': title,
          'year': year,
          'genre': genre,
          'description': description,
          'poster_url': posterUrl,
        })
        .select()
        .single();

    return DramaDatabaseModel.fromJson(row);
  }

  // MEMPERBARUI DATA DRAMA
  Future<DramaDatabaseModel> updateDrama({
    required int id,
    required String title,
    required int? year,
    required String genre,
    String? description,
    String? posterUrl,
  }) async {
    final row = await _client
        .from('dramas')
        .update({
          'title': title,
          'year': year,
          'genre': genre,
          'description': description,
          'poster_url': posterUrl,
        })
        .eq('id', id)
        .select()
        .single();

    return DramaDatabaseModel.fromJson(row);
  }
}
