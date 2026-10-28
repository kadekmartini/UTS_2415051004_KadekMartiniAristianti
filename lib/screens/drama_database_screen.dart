import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/drama_database_model.dart';
import '../providers/drama_database_provider.dart';
import 'drama_edit_screen.dart';
import 'drama_form_screen.dart';

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

  // MEMBUKA FORM TAMBAH DRAMA
  Future<void> _openCreateForm() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) => const DramaFormScreen(),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      await context.read<DramaDatabaseProvider>().loadDramas();
    }
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateForm,
        backgroundColor: const Color(0xFF59436B),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Drama'),
      ),
    );
  }

  // TAMPILAN BERDASARKAN KONDISI DATA
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
                'Tekan tombol Tambah Drama untuk '
                'menambahkan koleksi baru.',
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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
        itemCount: provider.dramas.length,
        itemBuilder: (context, index) {
          return DramaDatabaseCard(
            drama: provider.dramas[index],
          );
        },
      ),
    );
  }
}

// KARTU DRAMA DARI DATABASE
class DramaDatabaseCard extends StatelessWidget {
  final DramaDatabaseModel drama;

  const DramaDatabaseCard({
    super.key,
    required this.drama,
  });

  // MEMBUKA FORM EDIT
  Future<void> _openEditForm(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) => DramaEditScreen(
          drama: drama,
        ),
      ),
    );

    if (!context.mounted) return;

    if (result == true) {
      await context.read<DramaDatabaseProvider>().loadDramas();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data drama berhasil diperbarui!'),
          backgroundColor: Color(0xFF388E3C),
        ),
      );
    }
  }

  // DIALOG KONFIRMASI DELETE
  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.delete_outline,
            color: Colors.redAccent,
            size: 36,
          ),
          title: const Text('Hapus Drama?'),
          content: Text(
            'Apakah kamu yakin ingin menghapus '
            '"${drama.title}" dari database? '
            'Data yang dihapus tidak dapat dikembalikan.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Batal'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Ya, Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await context
          .read<DramaDatabaseProvider>()
          .deleteDrama(drama.id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${drama.title} berhasil dihapus.'),
          backgroundColor: const Color(0xFF388E3C),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Drama gagal dihapus. Periksa koneksi '
            'dan izin DELETE Supabase.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

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
                  const SizedBox(height: 10),

                  // TOMBOL EDIT DAN HAPUS
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _openEditForm(context),
                        icon: const Icon(
                          Icons.edit_outlined,
                          size: 18,
                        ),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF59436B),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _confirmDelete(context),
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 18,
                        ),
                        label: const Text('Hapus'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MEMUAT POSTER DRAMA
  Widget _buildPoster(String? url) {
    if (url == null || url.trim().isEmpty) {
      return _posterPlaceholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        url.trim(),
        width: 76,
        height: 106,
        fit: BoxFit.cover,
        webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
        errorBuilder: (context, error, stackTrace) {
          return _posterPlaceholder();
        },
      ),
    );
  }

  // POSTER PENGGANTI JIKA GAMBAR KOSONG
  Widget _posterPlaceholder() {
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
}