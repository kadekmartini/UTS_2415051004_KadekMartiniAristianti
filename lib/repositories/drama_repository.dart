import '../models/drama_api_model.dart';
import '../services/drama_api_service.dart';

class DramaRepository {
  final DramaApiService _apiService;

  DramaRepository({
    DramaApiService? apiService,
  }) : _apiService = apiService ?? DramaApiService();

  Future<List<DramaApiModel>> searchDramas(
    String query,
  ) async {
    return _apiService.searchShows(query);
  }
}