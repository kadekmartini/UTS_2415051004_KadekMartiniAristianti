
import 'package:flutter/material.dart';

class DramaItem {
  final String title;
  final String year;
  final String genre;
  final String description;
  final Color color;
  final String? posterUrl;

  const DramaItem({
    required this.title,
    required this.year,
    required this.genre,
    required this.description,
    required this.color,
    this.posterUrl,
  });
}
