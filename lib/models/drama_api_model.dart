class DramaApiModel {
  final int id;
  final String name;
  final String language;
  final List<String> genres;
  final String status;
  final String? premiered;
  final String summary;
  final String? imageUrl;
  final String? url;

  const DramaApiModel({
    required this.id,
    required this.name,
    required this.language,
    required this.genres,
    required this.status,
    required this.premiered,
    required this.summary,
    required this.imageUrl,
    required this.url,
  });

  factory DramaApiModel.fromSearchResult(
    Map<String, dynamic> json,
  ) {
    final rawShow = json['show'];

    final Map<String, dynamic> show =
        rawShow is Map<String, dynamic>
            ? rawShow
            : <String, dynamic>{};

    final rawImage = show['image'];

    final Map<String, dynamic>? image =
        rawImage is Map<String, dynamic>
            ? rawImage
            : null;

    final rawGenres = show['genres'];

    final List<String> genres = rawGenres is List
        ? rawGenres.whereType<String>().toList()
        : <String>[];

    final String summaryHtml =
        show['summary'] as String? ?? '';

    return DramaApiModel(
      id: (show['id'] as num?)?.toInt() ?? 0,
      name: show['name'] as String? ?? 'Tanpa judul',
      language:
          show['language'] as String? ?? 'Tidak diketahui',
      genres: genres,
      status:
          show['status'] as String? ?? 'Tidak diketahui',
      premiered: show['premiered'] as String?,
      summary: _removeHtmlTags(summaryHtml),
      imageUrl: image?['medium'] as String? ??
          image?['original'] as String?,
      url: show['url'] as String?,
    );
  }

  String get year {
    if (premiered == null || premiered!.isEmpty) {
      return 'Tahun tidak diketahui';
    }

    return premiered!.split('-').first;
  }

  static String _removeHtmlTags(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}