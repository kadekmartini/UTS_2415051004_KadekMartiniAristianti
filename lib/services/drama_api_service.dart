import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/drama_api_model.dart';

class DramaApiService {
  static const String _baseUrl = 'api.tvmaze.com';

  Future<List<DramaApiModel>> searchShows(String query) async {
    final searchQuery = query.trim();

    if (searchQuery.isEmpty) {
      return [];
    }

    final uri = Uri.https(
      _baseUrl,
      '/search/shows',
      {'q': searchQuery},
    );

    final response = await http
        .get(uri)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal mengambil data drama. '
        'Kode HTTP: ${response.statusCode}',
      );
    }

    final dynamic decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw const FormatException(
        'Format data dari API tidak sesuai.',
      );
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(DramaApiModel.fromSearchResult)
        .where((drama) => drama.id != 0)
        .toList();
  }
}