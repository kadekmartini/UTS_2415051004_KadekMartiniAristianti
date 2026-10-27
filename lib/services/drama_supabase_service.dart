import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/drama_database_model.dart';

class DramaSupabaseService {
  final SupabaseClient _client;

  DramaSupabaseService({
    SupabaseClient? client,
  }) : _client = client ?? Supabase.instance.client;

  Future<List<DramaDatabaseModel>> getDramas() async {
    final rows = await _client
        .from('dramas')
        .select()
        .order('id', ascending: true);

    return rows
        .map(
          (row) => DramaDatabaseModel.fromJson(row),
        )
        .toList();
  }
}