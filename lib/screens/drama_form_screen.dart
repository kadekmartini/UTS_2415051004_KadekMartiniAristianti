
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/drama_database_provider.dart';

class DramaFormScreen extends StatefulWidget {
  const DramaFormScreen({super.key});

  @override
  State<DramaFormScreen> createState() => _DramaFormScreenState();
}

class _DramaFormScreenState extends State<DramaFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _yearController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _posterUrlController = TextEditingController();

  String? _selectedGenre = 'BL';
  bool _isSaving = false;

  final List<String> _genres = [
    'BL',
    'GL',
    'Romance',
    'Comedy',
    'Thriller',
    'Action',
    'Drama',
    'Fantasy',
    'Horror',
    'Mystery',
    'Other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _yearController.dispose();
    _descriptionController.dispose();
    _posterUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveDrama() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await context.read<DramaDatabaseProvider>().createDrama(
            title: _titleController.text.trim(),
            year: int.parse(_yearController.text.trim()),
            genre: _selectedGenre!,
            description: _descriptionController.text.trim(),
            posterUrl: _posterUrlController.text.trim().isEmpty
                ? null
                : _posterUrlController.text.trim(),
          );

      if (!mounted) return;

      Navigator.of(context).pop(true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Drama berhasil ditambahkan!'),
          backgroundColor: Color(0xFF388E3C),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Drama gagal disimpan. Periksa koneksi dan izin INSERT Supabase.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF59436B),
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFE4DCE9),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF59436B),
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tambah Drama',
          style: TextStyle(
            color: Color(0xFF59436B),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 650,
            ),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Icon(
                    Icons.movie_creation_outlined,
                    size: 60,
                    color: Color(0xFF59436B),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Tambahkan drama favoritmu',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF302A35),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Isi informasi drama di bawah ini. '
                    'Data akan disimpan ke database Supabase.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // JUDUL DRAMA
                  TextFormField(
                    controller: _titleController,
                    textCapitalization: TextCapitalization.words,
                    decoration: _inputDecoration(
                      label: 'Judul Drama',
                      hint: 'Contoh: Bad Buddy',
                      icon: Icons.movie_outlined,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Judul drama wajib diisi.';
                      }

                      if (value.trim().length < 2) {
                        return 'Judul minimal 2 karakter.';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 18),

                  // TAHUN RILIS
                  TextFormField(
                    controller: _yearController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(
                      label: 'Tahun Rilis',
                      hint: 'Contoh: 2025',
                      icon: Icons.calendar_today_outlined,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Tahun rilis wajib diisi.';
                      }

                      final year = int.tryParse(value.trim());

                      if (year == null ||
                          year < 1900 ||
                          year > DateTime.now().year) {
                        return 'Masukkan tahun yang valid.';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 18),

                  // GENRE
                  DropdownButtonFormField<String>(
                    initialValue: _selectedGenre,
                    decoration: _inputDecoration(
                      label: 'Genre Drama',
                      hint: 'Pilih genre',
                      icon: Icons.category_outlined,
                    ),
                    items: _genres.map((genre) {
                      return DropdownMenuItem<String>(
                        value: genre,
                        child: Text(genre),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGenre = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Genre wajib dipilih.';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 18),

                  // DESKRIPSI
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: _inputDecoration(
                      label: 'Deskripsi',
                      hint: 'Ceritakan secara singkat tentang drama ini',
                      icon: Icons.description_outlined,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Deskripsi wajib diisi.';
                      }

                      if (value.trim().length < 5) {
                        return 'Deskripsi minimal 5 karakter.';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 18),

                  // URL POSTER (OPSIONAL)
                  TextFormField(
                    controller: _posterUrlController,
                    keyboardType: TextInputType.url,
                    decoration: _inputDecoration(
                      label: 'URL Poster (Opsional)',
                      hint: 'https://contoh.com/poster.jpg',
                      icon: Icons.image_outlined,
                    ),
                    validator: (value) {
                      final url = value?.trim() ?? '';

                      if (url.isEmpty) {
                        return null;
                      }

                      final uri = Uri.tryParse(url);

                      if (uri == null ||
                          !uri.hasAuthority ||
                          (uri.scheme != 'https' &&
                              uri.scheme != 'http')) {
                        return 'Masukkan URL gambar yang valid.';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 28),

                  // TOMBOL SIMPAN
                  SizedBox(
                    height: 50,
                    child: FilledButton.icon(
                      onPressed: _isSaving ? null : _saveDrama,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF59436B),
                        foregroundColor: Colors.white,
                      ),
                      icon: _isSaving
                          ? const SizedBox(
                              width: 19,
                              height: 19,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(
                        _isSaving
                            ? 'Menyimpan...'
                            : 'Simpan Drama',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // TOMBOL BATAL
                  OutlinedButton(
                    onPressed: _isSaving
                        ? null
                        : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF59436B),
                      minimumSize: const Size.fromHeight(46),
                    ),
                    child: const Text('Batal'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
