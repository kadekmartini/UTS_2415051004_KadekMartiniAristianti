import 'package:flutter/foundation.dart';

import '../models/drama_api_model.dart';
import '../repositories/drama_repository.dart';

class DramaApiProvider extends ChangeNotifier {
  final DramaRepository _repository;

  DramaApiProvider({
    DramaRepository? repository,
  }) : _repository = repository ?? DramaRepository();

  List<DramaApiModel> _dramas = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<DramaApiModel> get dramas =>
      List.unmodifiable(_dramas);

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  Future<void> searchDramas(String query) async {
    final String searchQuery = query.trim();

    if (searchQuery.isEmpty) {
      _dramas = [];
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _dramas = await _repository.searchDramas(searchQuery);
    } catch (error) {
      _dramas = [];
      _errorMessage =
          'Gagal mengambil data drama. '
          'Periksa koneksi internet dan coba lagi.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearResults() {
    _dramas = [];
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}