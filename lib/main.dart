import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

const Color primaryColor = Color(0xFF59436B);
const Color accentColor = Color(0xFFE99B84);
const Color backgroundColor = Color(0xFFFAF7F4);
const Color textColor = Color(0xFF302A35);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DramaVerse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: backgroundColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedGenre = 'Semua';
  String searchText = '';

  final TextEditingController searchController =
      TextEditingController();

  final List<String> genres = [
    'Semua',
    'BL',
    'GL',
    'Romance',
    'Comedy',
    'Thriller',
  ];

  final List<DramaItem> dramas = const [
    DramaItem(
      title: 'Bad Buddy',
      year: '2021',
      genre: 'BL',
      description: 'Romance dan persahabatan',
      color: Color(0xFFB77A91),
    ),
    DramaItem(
      title: '2gether',
      year: '2020',
      genre: 'BL',
      description: 'Musik dan romansa',
      color: Color(0xFF7B9FB4),
    ),
    DramaItem(
      title: 'GAP The Series',
      year: '2022',
      genre: 'GL',
      description: 'Romansa dan perasaan',
      color: Color(0xFFB895A6),
    ),
    DramaItem(
      title: 'F4 Thailand',
      year: '2021',
      genre: 'Romance',
      description: 'Cinta dan kehidupan sekolah',
      color: Color(0xFFCC9B72),
    ),
    DramaItem(
      title: 'Girl From Nowhere',
      year: '2018',
      genre: 'Thriller',
      description: 'Misteri dan ketegangan',
      color: Color(0xFF8177A8),
    ),
    DramaItem(
      title: 'My School President',
      year: '2022',
      genre: 'Comedy',
      description: 'Sekolah, musik, dan cinta',
      color: Color(0xFF83A99B),
    ),
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredDramas = dramas.where((drama) {
      final matchesGenre = selectedGenre == 'Semua' ||
          drama.genre == selectedGenre;

      final matchesSearch = drama.title
          .toLowerCase()
          .contains(searchText.toLowerCase());

      return matchesGenre && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.movie_outlined,
                color: Colors.white,
                size: 23,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'DramaVerse',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 21,
                color: primaryColor,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: const Color(0xFFECE3F0),
              child: IconButton(
                onPressed: () {
                  showMessage(
                    'Halaman profil akan dibuat pada tahap berikutnya.',
                  );
                },
                icon: const Icon(
                  Icons.person_outline_rounded,
                  color: primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
        children: [
          const Text(
            'Halo, pecinta drama! 👋',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Mau nonton cerita apa hari ini?',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 20),

          // Kolom pencarian
          TextField(
            controller: searchController,
            onChanged: (value) {
              setState(() {
                searchText = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Cari drama favoritmu...',
              hintStyle: const TextStyle(
                color: Colors.black38,
                fontSize: 14,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: primaryColor,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 15,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Banner drama pilihan
          Container(
            height: 215,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF765D86),
                  Color(0xFF49364F),
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  top: -25,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  right: 22,
                  top: 42,
                  child: Icon(
                    Icons.movie_outlined,
                    color: Colors.white.withValues(alpha: 0.15),
                    size: 100,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'DRAMA PILIHAN',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'BAD BUDDY',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Thailand • Romance • BL',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          onPressed: () {
                            showMessage(
                              'Detail Bad Buddy akan dibuat pada tahap berikutnya.',
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: primaryColor,
                            elevation: 0,
                          ),
                          child: const Text(
                            'Lihat Drama',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Pilihan genre
          const Text(
            'Jelajahi Genre',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: genres.map((genre) {
                final isSelected = selectedGenre == genre;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(genre),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selectedGenre = genre;
                      });
                    },
                    selectedColor: primaryColor,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? primaryColor
                          : const Color(0xFFE9E2E8),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 26),

          // Judul daftar drama
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Drama Thailand',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Text(
                '${filteredDramas.length} drama',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Grid yang menyesuaikan lebar layar
          if (filteredDramas.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text('Drama yang kamu cari belum ditemukan.'),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final double width = constraints.maxWidth;

                // Layar kecil: 2 kolom.
                // Layar sedang: 3 kolom.
                // Layar lebar: 4 kolom.
                final int columnCount;

                if (width >= 900) {
                  columnCount = 4;
                } else if (width >= 600) {
                  columnCount = 3;
                } else {
                  columnCount = 2;
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredDramas.length,
                  gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columnCount,
                    mainAxisExtent: 235,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    final drama = filteredDramas[index];

                    return DramaCard(
                      drama: drama,
                      onTap: () {
                        showMessage(
                          'Kamu memilih ${drama.title}. '
                          'Detail akan dibuat pada tahap berikutnya.',
                        );
                      },
                    );
                  },
                );
              },
            ),
          const SizedBox(height: 26),

          // Informasi watchlist
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0E9F2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.movie_outlined,
                  color: primaryColor,
                  size: 27,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Punya drama favorit?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Nanti kamu bisa menyimpannya di watchlist.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DramaItem {
  final String title;
  final String year;
  final String genre;
  final String description;
  final Color color;

  const DramaItem({
    required this.title,
    required this.year,
    required this.genre,
    required this.description,
    required this.color,
  });
}

class DramaCard extends StatelessWidget {
  final DramaItem drama;
  final VoidCallback onTap;

  const DramaCard({
    super.key,
    required this.drama,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      elevation: 1,
      shadowColor: Colors.black12,
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
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      drama.color,
                      drama.color.withValues(alpha: 0.65),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.movie_outlined,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: 54,
                      ),
                    ),
                    Positioned(
                      left: 9,
                      top: 9,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          drama.year,
                          style: const TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    drama.genre,
                    style: const TextStyle(
                      fontSize: 11,
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    drama.description,
                    maxLines: 1,
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
}