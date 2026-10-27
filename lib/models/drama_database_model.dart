class DramaDatabaseModel {
  final int id;
  final String title;
  final int? year;
  final String genre;
  final String? description;
  final String? posterUrl;
  final DateTime? createdAt;

  const DramaDatabaseModel({
    required this.id,
    required this.title,
    required this.year,
    required this.genre,
    required this.description,
    required this.posterUrl,
    required this.createdAt,
  });

  factory DramaDatabaseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return DramaDatabaseModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      year: (json['year'] as num?)?.toInt(),
      genre: json['genre'] as String,
      description: json['description'] as String?,
      posterUrl: json['poster_url'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(
              json['created_at'].toString(),
            ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'year': year,
      'genre': genre,
      'description': description,
      'poster_url': posterUrl,
    };
  }
}