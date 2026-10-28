
import 'package:flutter/foundation.dart';

import '../models/drama_database_model.dart';
import '../services/drama_supabase_service.dart';

class DramaDatabaseProvider extends ChangeNotifier {
  final DramaSupabaseService _service;

  DramaDatabaseProvider({DramaSupabaseService? service})
      : _service = service ?? DramaSupabaseService();

  List<DramaDatabaseModel> _dramas = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<DramaDatabaseModel> get dramas =>
      List.unmodifiable(_dramas);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // MENGAMBIL DATA DRAMA
  Future<void> loadDramas() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _dramas = await _service.getDramas();
    } catch (error) {
      _errorMessage =
          'Gagal mengambil data drama dari database. '
          'Periksa koneksi dan izin akses Supabase.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // MEMUAT ULANG DATA
  Future<void> refreshDramas() async {
    await loadDramas();
  }

  // MENAMBAHKAN DRAMA BARU
  Future<DramaDatabaseModel> createDrama({
    required String title,
    required int? year,
    required String genre,
    String? description,
    String? posterUrl,
  }) async {
    final newDrama = await _service.createDrama(
      title: title,
      year: year,
      genre: genre,
      description: description,
      posterUrl: posterUrl,
    );

    _dramas = [..._dramas, newDrama];
    notifyListeners();

    return newDrama;
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
    final updatedDrama = await _service.updateDrama(
      id: id,
      title: title,
      year: year,
      genre: genre,
      description: description,
      posterUrl: posterUrl,
    );

    _dramas = _dramas.map((drama) {
      return drama.id == updatedDrama.id ? updatedDrama : drama;
    }).toList();

    notifyListeners();

    return updatedDrama;
  }
}
