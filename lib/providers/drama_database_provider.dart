import 'package:flutter/foundation.dart';

import '../models/drama_database_model.dart';
import '../services/drama_supabase_service.dart';

class DramaDatabaseProvider extends ChangeNotifier {
  final DramaSupabaseService _service;

  DramaDatabaseProvider({
    DramaSupabaseService? service,
  }) : _service = service ?? DramaSupabaseService();

  List<DramaDatabaseModel> _dramas = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<DramaDatabaseModel> get dramas =>
      List.unmodifiable(_dramas);

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

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

  Future<void> refreshDramas() async {
    await loadDramas();
  }
}
