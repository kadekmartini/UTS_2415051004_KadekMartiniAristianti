
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

  // READ: MENGAMBIL DATA DRAMA
  Future<void> loadDramas() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _dramas = await _service.getDramas();
    } catch (error, stackTrace) {
      debugPrint('Gagal memuat data drama: $error');
      debugPrintStack(stackTrace: stackTrace);

      _errorMessage =
          'Data drama gagal dimuat. Periksa koneksi internet '
          'dan izin akses database Supabase.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // MEMUAT ULANG DATA
  Future<void> refreshDramas() async {
    await loadDramas();
  }

  // CREATE: MENAMBAHKAN DRAMA
  Future<DramaDatabaseModel> createDrama({
    required String title,
    required int? year,
    required String genre,
    String? description,
    String? posterUrl,
  }) async {
    try {
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
    } catch (error, stackTrace) {
      debugPrint('Gagal menambahkan drama: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  // UPDATE: MEMPERBARUI DATA DRAMA
  Future<DramaDatabaseModel> updateDrama({
    required int id,
    required String title,
    required int? year,
    required String genre,
    String? description,
    String? posterUrl,
  }) async {
    try {
      final updatedDrama = await _service.updateDrama(
        id: id,
        title: title,
        year: year,
        genre: genre,
        description: description,
        posterUrl: posterUrl,
      );

      _dramas = _dramas.map((drama) {
        return drama.id == updatedDrama.id
            ? updatedDrama
            : drama;
      }).toList();

      notifyListeners();

      return updatedDrama;
    } catch (error, stackTrace) {
      debugPrint('Gagal memperbarui drama: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  // DELETE: MENGHAPUS DRAMA
  Future<void> deleteDrama(int id) async {
    try {
      await _service.deleteDrama(id: id);

      _dramas = _dramas
          .where((drama) => drama.id != id)
          .toList();

      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('Gagal menghapus drama dengan ID $id: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }
}
