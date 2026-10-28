
import 'package:flutter/material.dart';

import '../models/drama_database_model.dart';

const Color catalogPrimaryColor = Color(0xFF59436B);
const Color catalogTextColor = Color(0xFF302A35);

class DramaCatalogCard extends StatelessWidget {
  final DramaDatabaseModel drama;
  final VoidCallback onTap;

  const DramaCatalogCard({
    super.key,
    required this.drama,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildPoster(),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        drama.year?.toString() ?? '-',
                        style: const TextStyle(
                          color: catalogPrimaryColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    drama.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: catalogTextColor,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    drama.genre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: catalogPrimaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    drama.description?.isNotEmpty == true
                        ? drama.description!
                        : 'Belum ada deskripsi',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoster() {
    final url = drama.posterUrl?.trim();

    if (url == null || url.isEmpty) {
      return _posterPlaceholder();
    }

    return Image.network(
      url,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;

        return Container(
          color: const Color(0xFFECE3F0),
          alignment: Alignment.center,
          child: const CircularProgressIndicator(
            color: catalogPrimaryColor,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return _posterPlaceholder();
      },
    );
  }

  Widget _posterPlaceholder() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFECE3F0),
      alignment: Alignment.center,
      child: const Icon(
        Icons.movie_outlined,
        color: catalogPrimaryColor,
        size: 48,
      ),
    );
  }
}
