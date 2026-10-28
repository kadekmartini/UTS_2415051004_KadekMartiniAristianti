
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/drama_item.dart';
import 'models/drama_api_model.dart';
import 'providers/drama_provider.dart';
import 'providers/drama_api_provider.dart';
import 'providers/drama_database_provider.dart';
import 'screens/drama_database_screen.dart';
import 'widgets/drama_catalog_card.dart';

// KONFIGURASI SUPABASE
const String supabaseUrl =
    'https://idpxiyyrjnusoiynbtpg.supabase.co';

const String supabasePublishableKey =
    'sb_publishable_Yo8NEsJKgv2yZHur5LNu1A_VxPU4CKX';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<DramaProvider>(
          create: (context) => DramaProvider(),
        ),
        ChangeNotifierProvider<DramaApiProvider>(
          create: (context) => DramaApiProvider(),
        ),
        ChangeNotifierProvider<DramaDatabaseProvider>(
          create: (context) => DramaDatabaseProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

const Color primaryColor = Color(0xFF59436B);
const Color accentColor = Color(0xFFE99B84);
const Color backgroundColor = Color(0xFFFAF7F4);
const Color textColor = Color(0xFF302A35);

// DATA CONTOH LOKAL
const List<DramaItem> demoDramas = [
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

// APLIKASI UTAMA
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
      home: const MainNavigationScreen(),
    );
  }
}

// KONVERSI DATA DATABASE KE MODEL DETAIL LOKAL
DramaItem databaseDramaToItem(dynamic drama) {
  return DramaItem(
    title: drama.title as String,
    year: drama.year?.toString() ?? '-',
    genre: drama.genre as String,
    description: (drama.description as String?) ?? '',
    color: primaryColor,
  );
}

// NAVIGASI UTAMA
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState
    extends State<MainNavigationScreen> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    HomeScreen(),
    CatalogScreen(),
    ApiDramaScreen(),
    DramaDatabaseScreen(),
    WatchlistScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.movie_outlined),
            selectedIcon: Icon(Icons.movie),
            label: 'Katalog',
          ),
          NavigationDestination(
            icon: Icon(Icons.cloud_download_outlined),
            selectedIcon: Icon(Icons.cloud_download),
            label: 'API Drama',
          ),
          NavigationDestination(
            icon: Icon(Icons.storage_outlined),
            selectedIcon: Icon(Icons.storage),
            label: 'Database',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Watchlist',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

// HALAMAN BERANDA
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

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void openDrama(DramaItem drama) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return DramaDetailScreen(drama: drama);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final databaseProvider =
        context.watch<DramaDatabaseProvider>();

    final filteredDramas =
        databaseProvider.dramas.where((drama) {
      final matchesGenre = selectedGenre == 'Semua' ||
          drama.genre.toLowerCase() ==
              selectedGenre.toLowerCase();

      final matchesSearch = drama.title
          .toLowerCase()
          .contains(searchText.toLowerCase());

      return matchesGenre && matchesSearch;
    }).toList();

    // DRAMA PILIHAN DIAMBIL DARI DATABASE
    final featuredDrama = databaseProvider.dramas.isEmpty
        ? null
        : databaseProvider.dramas.first;

    final featuredPosterUrl =
        featuredDrama?.posterUrl?.trim();

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

          // PENCARIAN DRAMA
          TextField(
            controller: searchController,
            onChanged: (value) {
              setState(() {
                searchText = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Cari drama favoritmu...',
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: primaryColor,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // BANNER DRAMA PILIHAN DENGAN POSTER DATABASE
          Container(
            height: 215,
            clipBehavior: Clip.antiAlias,
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
              fit: StackFit.expand,
              children: [
                if (featuredPosterUrl != null &&
                    featuredPosterUrl.isNotEmpty)
                  Image.network(
                    featuredPosterUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox.shrink();
                    },
                  ),

                // Lapisan gelap agar teks terbaca
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x55302635),
                        Color(0xEE302035),
                      ],
                    ),
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
                      Text(
                        featuredDrama?.title.toUpperCase() ??
                            'BELUM ADA DRAMA',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        featuredDrama == null
                            ? 'Tambahkan drama melalui menu Database'
                            : 'Thailand • '
                                '${featuredDrama.year ?? '-'} • '
                                '${featuredDrama.genre}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          onPressed: featuredDrama == null
                              ? null
                              : () {
                                  openDrama(
                                    databaseDramaToItem(
                                      featuredDrama,
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: primaryColor,
                            elevation: 0,
                          ),
                          child: const Text('Lihat Drama'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          const Text(
            'Jelajahi Genre',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),

          // FILTER GENRE
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
                      color: isSelected
                          ? Colors.white
                          : textColor,
                      fontSize: 12,
                    ),
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 26),

          // JUDUL DAN JUMLAH DRAMA
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
              Text('${filteredDramas.length} drama'),
            ],
          ),
          const SizedBox(height: 14),

          // LOADING, ERROR, DAN EMPTY STATE
          if (databaseProvider.isLoading &&
              databaseProvider.dramas.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: CircularProgressIndicator(
                  color: primaryColor,
                ),
              ),
            )
          else if (databaseProvider.errorMessage != null &&
              databaseProvider.dramas.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(
                    Icons.cloud_off_outlined,
                    size: 48,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    databaseProvider.errorMessage!,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      context
                          .read<DramaDatabaseProvider>()
                          .loadDramas();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi'),
                  ),
                ],
              ),
            )
          else if (filteredDramas.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text('Drama tidak ditemukan.'),
              ),
            )
          else
            // GRID POSTER RESPONSIF
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
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
                    mainAxisExtent: 285,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    final drama = filteredDramas[index];

                    return DramaCatalogCard(
                      drama: drama,
                      onTap: () {
                        openDrama(
                          databaseDramaToItem(drama),
                        );
                      },
                    );
                  },
                );
              },
            ),

          const SizedBox(height: 26),

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
                        'Simpan drama favoritmu di watchlist.',
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

// KARTU DRAMA LOKAL
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

// HALAMAN DETAIL DRAMA LOKAL
class DramaDetailScreen extends StatelessWidget {
  final DramaItem drama;

  const DramaDetailScreen({
    super.key,
    required this.drama,
  });

  @override
  Widget build(BuildContext context) {
    final isSaved = context.select<DramaProvider, bool>(
      (provider) => provider.isInWatchlist(drama),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Drama'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            height: 230,
            decoration: BoxDecoration(
              color: drama.color,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.movie_outlined,
              size: 90,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            drama.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 26,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${drama.year} • Thailand • ${drama.genre}',
            style: const TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Informasi Drama',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            drama.description,
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              context.read<DramaProvider>().toggleWatchlist(drama);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isSaved
                        ? '${drama.title} dihapus dari Watchlist.'
                        : '${drama.title} ditambahkan ke Watchlist.',
                  ),
                ),
              );
            },
            icon: Icon(
              isSaved
                  ? Icons.bookmark_remove_outlined
                  : Icons.bookmark_add_outlined,
            ),
            label: Text(
              isSaved
                  ? 'Hapus dari Watchlist'
                  : 'Tambahkan ke Watchlist',
            ),
          ),
        ],
      ),
    );
  }
}

// HALAMAN KATALOG DARI SUPABASE
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  String searchText = '';

  final TextEditingController searchController =
      TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final databaseProvider =
        context.watch<DramaDatabaseProvider>();

    final filteredDramas =
        databaseProvider.dramas.where((drama) {
      return drama.title
          .toLowerCase()
          .contains(searchText.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Katalog Drama',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari drama...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: primaryColor,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: Builder(
              builder: (context) {
                if (databaseProvider.isLoading &&
                    databaseProvider.dramas.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: primaryColor,
                    ),
                  );
                }

                if (databaseProvider.errorMessage != null &&
                    databaseProvider.dramas.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.cloud_off_outlined,
                            size: 50,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            databaseProvider.errorMessage!,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () {
                              context
                                  .read<DramaDatabaseProvider>()
                                  .loadDramas();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (filteredDramas.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.movie_filter_outlined,
                            size: 55,
                            color: primaryColor,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            searchText.isEmpty
                                ? 'Belum ada drama di katalog.'
                                : 'Drama tidak ditemukan.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (searchText.isEmpty) ...[
                            const SizedBox(height: 6),
                            const Text(
                              'Tambahkan drama melalui menu Database.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                          const SizedBox(height: 12),
                          if (!databaseProvider.isLoading)
                            OutlinedButton.icon(
                              onPressed: () {
                                context
                                    .read<DramaDatabaseProvider>()
                                    .loadDramas();
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Muat Ulang'),
                            ),
                        ],
                      ),
                    ),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final int columns;

                    if (width >= 900) {
                      columns = 4;
                    } else if (width >= 600) {
                      columns = 3;
                    } else {
                      columns = 2;
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        4,
                        16,
                        20,
                      ),
                      itemCount: filteredDramas.length,
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        mainAxisExtent: 285,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemBuilder: (context, index) {
                        final drama = filteredDramas[index];

                        return DramaCatalogCard(
                          drama: drama,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return DramaDetailScreen(
                                    drama: databaseDramaToItem(
                                      drama,
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// HALAMAN PENCARIAN REST API
class ApiDramaScreen extends StatefulWidget {
  const ApiDramaScreen({super.key});

  @override
  State<ApiDramaScreen> createState() => _ApiDramaScreenState();
}

class _ApiDramaScreenState extends State<ApiDramaScreen> {
  final TextEditingController searchController =
      TextEditingController();

  bool hasSearched = false;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> searchDramas() async {
    final query = searchController.text.trim();

    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan nama serial terlebih dahulu.'),
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      hasSearched = true;
    });

    await context.read<DramaApiProvider>().searchDramas(query);
  }

  @override
  Widget build(BuildContext context) {
    final apiProvider = context.watch<DramaApiProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cari Drama dari API',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Jelajahi serial dari internet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Data diambil melalui REST API TVmaze.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => searchDramas(),
                  decoration: InputDecoration(
                    hintText: 'Contoh: Bad Buddy',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: primaryColor,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: apiProvider.isLoading
                        ? null
                        : searchDramas,
                    icon: const Icon(Icons.cloud_download_outlined),
                    label: const Text('Cari melalui API'),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          if (apiProvider.isLoading)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: primaryColor,
                    ),
                    SizedBox(height: 16),
                    Text('Sedang mengambil data drama...'),
                  ],
                ),
              ),
            )
          else if (apiProvider.errorMessage != null)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.cloud_off_outlined,
                        size: 58,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        apiProvider.errorMessage!,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: searchDramas,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (apiProvider.dramas.isEmpty)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        hasSearched
                            ? Icons.search_off
                            : Icons.live_tv_outlined,
                        color: primaryColor,
                        size: 62,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        hasSearched
                            ? 'Drama tidak ditemukan.'
                            : 'Cari serial favoritmu',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        hasSearched
                            ? 'Coba kata kunci lain.'
                            : 'Masukkan judul serial, lalu tekan tombol Cari.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${apiProvider.dramas.length} hasil ditemukan',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: apiProvider.dramas.length,
                      itemBuilder: (context, index) {
                        final drama = apiProvider.dramas[index];
                        return ApiDramaCard(drama: drama);
                      },
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

// KARTU HASIL REST API
class ApiDramaCard extends StatelessWidget {
  final DramaApiModel drama;

  const ApiDramaCard({
    super.key,
    required this.drama,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 7,
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: drama.imageUrl != null &&
                      drama.imageUrl!.isNotEmpty
                  ? Image.network(
                      drama.imageUrl!,
                      width: 78,
                      height: 112,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 78,
                          height: 112,
                          color: const Color(0xFFECE3F0),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.movie_outlined,
                            color: primaryColor,
                            size: 34,
                          ),
                        );
                      },
                    )
                  : Container(
                      width: 78,
                      height: 112,
                      color: const Color(0xFFECE3F0),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.movie_outlined,
                        color: primaryColor,
                        size: 34,
                      ),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    drama.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${drama.year} • ${drama.language}',
                    style: const TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    drama.genres.isEmpty
                        ? 'Genre belum tersedia'
                        : drama.genres.join(' • '),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Status: ${drama.status}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  if (drama.summary.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      drama.summary,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: textColor,
                      ),
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
}

// HALAMAN WATCHLIST
class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final watchlist = context.watch<DramaProvider>().watchlist;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Watchlist',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: watchlist.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bookmark_border,
                      color: primaryColor,
                      size: 65,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Watchlist Kamu',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Drama yang kamu simpan akan muncul di sini.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 900
                    ? 4
                    : constraints.maxWidth >= 600
                        ? 3
                        : 2;

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: watchlist.length,
                  gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisExtent: 235,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    final drama = watchlist[index];

                    return DramaCard(
                      drama: drama,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return DramaDetailScreen(
                                drama: drama,
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}

// HALAMAN PROFIL
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profil',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const CircleAvatar(
            radius: 45,
            backgroundColor: Color(0xFFECE3F0),
            child: Icon(
              Icons.person,
              color: primaryColor,
              size: 50,
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Kadek Martini Aristianti',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Center(
            child: Text(
              'Mahasiswa Pendidikan Teknik Informatika',
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          const Card(
            color: Colors.white,
            child: ListTile(
              leading: Icon(
                Icons.badge_outlined,
                color: primaryColor,
              ),
              title: Text('NIM'),
              subtitle: Text('2415051004'),
            ),
          ),
          const Card(
            color: Colors.white,
            child: ListTile(
              leading: Icon(
                Icons.school_outlined,
                color: primaryColor,
              ),
              title: Text('Kelas'),
              subtitle: Text('PTI 5C'),
            ),
          ),
          const Card(
            color: Colors.white,
            child: ListTile(
              leading: Icon(
                Icons.movie_outlined,
                color: primaryColor,
              ),
              title: Text('Nama Aplikasi'),
              subtitle: Text('DramaVerse'),
            ),
          ),
        ],
      ),
    );
  }
}
