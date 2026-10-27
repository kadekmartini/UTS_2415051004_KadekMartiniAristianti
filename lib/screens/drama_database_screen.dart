import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/drama_database_model.dart';
import '../providers/drama_database_provider.dart';

class DramaDatabaseScreen extends StatefulWidget {
  const DramaDatabaseScreen({super.key});

  @override
  State<DramaDatabaseScreen> createState() =>
      _DramaDatabaseScreenState();
}

class _DramaDatabaseScreenState
    extends State<DramaDatabaseScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<DramaDatabaseProvider>().loadDramas();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DramaDatabaseProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Database Drama',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF59436B),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Muat ulang data',
            onPressed: provider.isLoading
                ? null
                : () => provider.loadDramas(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(DramaDatabaseProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: Color(0xFF59436B),
            ),
            SizedBox(height: 16),
            Text('Mengambil data dari Supabase...'),
          ],
        ),
      );
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                size: 60,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 12),
              const Text(
                'Data gagal dimuat',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                provider.errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => provider.loadDramas(),
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.dramas.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.movie_filter_outlined,
                size: 60,
                color: Color(0xFF59436B),
              ),
              SizedBox(height: 12),
              Text(
                'Belum ada data drama',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Tambahkan data melalui database Supabase.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: provider.refreshDramas,
      color: const Color(0xFF59436B),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: provider.dramas.length,
        itemBuilder: (context, index) {
          final drama = provider.dramas[index];

          return DramaDatabaseCard(drama: drama);
        },
      ),
    );
  }
}

class DramaDatabaseCard extends StatelessWidget {
  final DramaDatabaseModel drama;

  const DramaDatabaseCard({
    super.key,
    required this.drama,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPoster(drama.posterUrl),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    drama.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF302A35),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    drama.year?.toString() ??
                        'Tahun belum tersedia',
                    style: const TextStyle(
                      color: Color(0xFF59436B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Genre: ${drama.genre}'),
                  if (drama.description?.isNotEmpty ?? false) ...[
                    const SizedBox(height: 6),
                    Text(
                      drama.description!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoster(String? url) {
    if (url == null || url.isEmpty) {
      return Container(
        width: 76,
        height: 106,
        decoration: BoxDecoration(
          color: const Color(0xFFECE3F0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.movie_outlined,
          size: 36,
          color: Color(0xFF59436B),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        url,
        width: 76,
        height: 106,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 76,
            height: 106,
            color: const Color(0xFFECE3F0),
            child: const Icon(
              Icons.movie_outlined,
              size: 36,
              color: Color(0xFF59436B),
            ),
          );
        },
      ),
    );
  }
}