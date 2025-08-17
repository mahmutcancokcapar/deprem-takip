// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:deprem_takip/models/model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'detay_page.dart';

class SonDepremler extends StatefulWidget {
  const SonDepremler({super.key});

  @override
  State<SonDepremler> createState() => _SonDepremlerState();
}

enum SortType { newest, oldest, magnitude, magnitudeLow }

enum FilterMagnitude {
  all,
  small, // < 3.0
  medium, // 3.0 - 4.9
  large, // >= 5.0
}

class _SonDepremlerState extends State<SonDepremler>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  List<Earthquake> _earthquakes = [];
  List<Earthquake> _filteredEarthquakes = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Filter and Search Variables
  final TextEditingController _searchController = TextEditingController();
  SortType _sortType = SortType.newest;
  FilterMagnitude _filterMagnitude = FilterMagnitude.all;
  bool _showFilters = false;
  String _selectedRegion = 'Tümü';

  // Scroll Controller for FAB
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTop = false;

  // Türkiye illeri listesi
  final List<String> _turkishCities = [
    'Tümü',
    'Adana',
    'Adıyaman',
    'Afyonkarahisar',
    'Ağrı',
    'Amasya',
    'Ankara',
    'Antalya',
    'Artvin',
    'Aydın',
    'Balıkesir',
    'Bilecik',
    'Bingöl',
    'Bitlis',
    'Bolu',
    'Burdur',
    'Bursa',
    'Çanakkale',
    'Çankırı',
    'Çorum',
    'Denizli',
    'Diyarbakır',
    'Edirne',
    'Elazığ',
    'Erzincan',
    'Erzurum',
    'Eskişehir',
    'Gaziantep',
    'Giresun',
    'Gümüşhane',
    'Hakkari',
    'Hatay',
    'Isparta',
    'Mersin',
    'İstanbul',
    'İzmir',
    'Kars',
    'Kastamonu',
    'Kayseri',
    'Kırklareli',
    'Kırşehir',
    'Kocaeli',
    'Konya',
    'Kütahya',
    'Malatya',
    'Manisa',
    'Kahramanmaraş',
    'Mardin',
    'Muğla',
    'Muş',
    'Nevşehir',
    'Niğde',
    'Ordu',
    'Rize',
    'Sakarya',
    'Samsun',
    'Siirt',
    'Sinop',
    'Sivas',
    'Tekirdağ',
    'Tokat',
    'Trabzon',
    'Tunceli',
    'Şanlıurfa',
    'Uşak',
    'Van',
    'Yozgat',
    'Zonguldak',
    'Aksaray',
    'Bayburt',
    'Karaman',
    'Kırıkkale',
    'Batman',
    'Şırnak',
    'Bartın',
    'Ardahan',
    'Iğdır',
    'Yalova',
    'Karabük',
    'Kilis',
    'Osmaniye',
    'Düzce',
  ];

  Future<void> _fetchEarthquakeData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http
          .get(
            Uri.parse('https://api.orhanaydogdu.com.tr/deprem/kandilli/live'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'User-Agent': 'Mozilla/5.0 (compatible; Flutter App)',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw Exception('API boş yanıt döndü');
        }
        try {
          final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
          if (jsonResponse.containsKey('status') &&
              jsonResponse['status'] == true &&
              jsonResponse.containsKey('result')) {
            final dynamic resultData = jsonResponse['result'];
            if (resultData is! List) {
              throw Exception(
                'API result beklenen formatta değil (liste olmalı)',
              );
            }
            final List<dynamic> jsonData = resultData;
            if (jsonData.isEmpty) {
              if (mounted) {
                setState(() {
                  _earthquakes = [];
                  _filteredEarthquakes = [];
                  _isLoading = false;
                });
              }
              return;
            }
            List<Earthquake> earthquakes = [];
            for (int i = 0; i < jsonData.length && i <= 100; i++) {
              try {
                final earthquake = Earthquake.fromJson(jsonData[i]);
                earthquakes.add(earthquake);
              } catch (e) {
                continue;
              }
            }
            if (mounted) {
              setState(() {
                _earthquakes = earthquakes;
                _applyFiltersAndSort();
                _isLoading = false;
              });
            }
          } else {
            throw Exception(
              'API başarısız yanıt döndü: ${jsonResponse['desc'] ?? 'Bilinmeyen hata'}',
            );
          }
        } catch (e) {
          throw Exception('JSON parse hatası: $e');
        }
      } else {
        throw Exception(
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = _getErrorMessage(e);
        });
      }
    }
  }

  void _applyFiltersAndSort() {
    List<Earthquake> filtered = List.from(_earthquakes);

    // Search filter
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _normalizeSearchTerm(_searchController.text);
      filtered = filtered.where((earthquake) {
        final normalizedTitle = _normalizeSearchTerm(earthquake.title);
        return normalizedTitle.contains(searchTerm);
      }).toList();
    }

    // Magnitude filter
    switch (_filterMagnitude) {
      case FilterMagnitude.small:
        filtered = filtered.where((e) => e.mag < 3.0).toList();
        break;
      case FilterMagnitude.medium:
        filtered = filtered.where((e) => e.mag >= 3.0 && e.mag < 5.0).toList();
        break;
      case FilterMagnitude.large:
        filtered = filtered.where((e) => e.mag >= 5.0).toList();
        break;
      case FilterMagnitude.all:
        break;
    }

    // Region filter (City filter)
    if (_selectedRegion != 'Tümü') {
      filtered = filtered.where((earthquake) {
        final normalizedTitle = _normalizeSearchTerm(earthquake.title);
        final normalizedRegion = _normalizeSearchTerm(_selectedRegion);
        return normalizedTitle.contains(normalizedRegion);
      }).toList();
    }

    // Sort
    switch (_sortType) {
      case SortType.newest:
        filtered.sort((a, b) => b.dateTime.compareTo(a.dateTime));
        break;
      case SortType.oldest:
        filtered.sort((a, b) => a.dateTime.compareTo(b.dateTime));
        break;
      case SortType.magnitude:
        filtered.sort((a, b) => b.mag.compareTo(a.mag));
        break;
      case SortType.magnitudeLow:
        filtered.sort((a, b) => a.mag.compareTo(b.mag));
        break;
    }

    _filteredEarthquakes = filtered;
  }

  // Türkçe karakterleri normalize eden yardımcı fonksiyon
  String _normalizeSearchTerm(String text) {
    return text
        .toLowerCase()
        .replaceAll('ç', 'c')
        .replaceAll('ğ', 'g')
        .replaceAll('ı', 'i')
        .replaceAll('ö', 'o')
        .replaceAll('ş', 's')
        .replaceAll('ü', 'u')
        .replaceAll(RegExp(r'[^\w\s]'), '') // Noktalama işaretlerini kaldır
        .replaceAll(RegExp(r'\s+'), ' ') // Çoklu boşlukları tek boşluğa çevir
        .trim();
  }

  // Geliştirilmiş hata mesajı fonksiyonu
  String _getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('timeoutexception') ||
        errorString.contains('timeout')) {
      return 'Bağlantı zaman aşımına uğradı. Lütfen internet bağlantınızı kontrol edin ve tekrar deneyin.';
    } else if (errorString.contains('socketexception') ||
        errorString.contains('network')) {
      return 'İnternet bağlantınızı kontrol edin ve tekrar deneyin.';
    } else if (errorString.contains('formatexception') ||
        errorString.contains('json')) {
      return 'Veri formatı hatası. API geçici olarak kullanılamıyor olabilir.';
    } else if (errorString.contains('http 404')) {
      return 'API servis bulunamadı. Lütfen daha sonra tekrar deneyin.';
    } else if (errorString.contains('http 500') ||
        errorString.contains('http 502') ||
        errorString.contains('http 503')) {
      return 'Sunucu hatası. Lütfen daha sonra tekrar deneyin.';
    } else if (errorString.contains('parse hatası')) {
      return 'Veri işleme hatası. API geçici olarak sorunlu olabilir.';
    } else {
      return 'Deprem verileri yüklenirken bir hata oluştu: ${error.toString()}';
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchEarthquakeData();
    _searchController.addListener(() {
      _applyFiltersAndSort();
      setState(() {});
    });

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels > 200 && !_showBackToTop) {
            setState(() {
              _showBackToTop = true;
            });
          } else if (scrollInfo.metrics.pixels <= 200 && _showBackToTop) {
            setState(() {
              _showBackToTop = false;
            });
          }
          return false;
        },
        child: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              _buildModernAppBar(innerBoxIsScrolled),
              if (_showFilters) _buildFilterSection(),
            ];
          },
          body: SafeArea(
            top: false,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: RefreshIndicator(
                  onRefresh: _refreshData,
                  color: const Color(0xFF3B82F6),
                  child: _buildBody(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingView();
    }

    if (_errorMessage != null) {
      return _buildErrorView();
    }

    if (_filteredEarthquakes.isEmpty) {
      // Eğer orijinal veriler var ama filtrelenmiş sonuç boşsa
      if (_earthquakes.isNotEmpty) {
        return _buildNoResultsView();
      }
      // Hiç veri yoksa
      return _buildEmptyView();
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        // Arama barı
        _buildSearchBar(),
        const SizedBox(height: 16),
        _buildCompactSummaryCard(),
        const SizedBox(height: 16),
        _buildSectionHeader(),
        const SizedBox(height: 16),
        ...List.generate(_filteredEarthquakes.length, (index) {
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 300 + (index * 100)),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value.clamp(0.0, 1.0),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildEarthquakeCard(index),
                  ),
                ),
              );
            },
          );
        }),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Deprem verileri yükleniyor...',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 48,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Bir Hata Oluştu',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchEarthquakeData,
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar Dene'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF6B7280).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.hourglass_empty,
                size: 48,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Veri Bulunamadı',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Şu anda gösterilecek deprem verisi bulunmuyor.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsView() {
    final bool hasActiveFilters =
        _searchController.text.isNotEmpty ||
        _filterMagnitude != FilterMagnitude.all ||
        _selectedRegion != 'Tümü' ||
        _sortType != SortType.newest;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF3B82F6).withOpacity(0.1),
                    const Color(0xFF3B82F6).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF3B82F6).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.search_off,
                size: 48,
                color: Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Arama Sonucu Bulunamadı',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                hasActiveFilters
                    ? 'Aradığınız kriterlere uygun deprem verisi bulunamadı. Lütfen arama terimlerinizi değiştirin veya filtreleri temizleyin.'
                    : 'Aradığınız terime uygun sonuç bulunamadı. Farklı bir arama terimi deneyin.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (hasActiveFilters) ...[
              // Filtreleri temizle butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _filterMagnitude = FilterMagnitude.all;
                      _selectedRegion = 'Tümü';
                      _sortType = SortType.newest;
                      _applyFiltersAndSort();
                    });
                  },
                  icon: const Icon(Icons.clear_all, size: 20),
                  label: const Text('Tüm Filtreleri Temizle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Sadece arama terimini temizle butonu
              if (_searchController.text.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _applyFiltersAndSort();
                      });
                    },
                    icon: const Icon(Icons.backspace_outlined, size: 18),
                    label: const Text('Sadece Aramayı Temizle'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF3B82F6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(
                        color: Color(0xFF3B82F6),
                        width: 1,
                      ),
                    ),
                  ),
                ),
            ] else ...[
              // Sadece arama varsa
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _applyFiltersAndSort();
                    });
                  },
                  icon: const Icon(Icons.backspace_outlined, size: 20),
                  label: const Text('Aramayı Temizle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ],

            // Aktif filtreleri göster
            if (hasActiveFilters) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aktif Filtreler:',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (_searchController.text.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Arama: "${_searchController.text}"',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF3B82F6),
                              ),
                            ),
                          ),
                        if (_filterMagnitude != FilterMagnitude.all)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Büyüklük: ${_getMagnitudeFilterText()}',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFF59E0B),
                              ),
                            ),
                          ),
                        if (_sortType != SortType.newest)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Sıralama: ${_getSortTypeText()}',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getMagnitudeFilterText() {
    switch (_filterMagnitude) {
      case FilterMagnitude.small:
        return 'Küçük (<3.0)';
      case FilterMagnitude.medium:
        return 'Orta (3.0-4.9)';
      case FilterMagnitude.large:
        return 'Büyük (≥5.0)';
      case FilterMagnitude.all:
        return 'Tümü';
    }
  }

  String _getSortTypeText() {
    switch (_sortType) {
      case SortType.newest:
        return 'En Yeni';
      case SortType.oldest:
        return 'En Eski';
      case SortType.magnitude:
        return 'Büyüklük ↓';
      case SortType.magnitudeLow:
        return 'Büyüklük ↑';
    }
  }

  Future<void> _refreshData() async {
    await _fetchEarthquakeData();
  }

  // Modern AppBar with collapsible design
  Widget _buildModernAppBar(bool innerBoxIsScrolled) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      elevation: innerBoxIsScrolled ? 4 : 0,
      backgroundColor: innerBoxIsScrolled
          ? const Color(0xFF3B82F6)
          : Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: innerBoxIsScrolled
                    ? Colors.white.withOpacity(0.2)
                    : const Color(0xFF3B82F6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.waves,
                color: innerBoxIsScrolled
                    ? Colors.white
                    : const Color(0xFF3B82F6),
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Son Depremler',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: innerBoxIsScrolled
                    ? Colors.white
                    : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: innerBoxIsScrolled
                  ? [const Color(0xFF3B82F6), const Color(0xFF1E40AF)]
                  : [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0)],
            ),
          ),
        ),
      ),
      actions: [
        // Yukarı çıkma butonu
        if (_showBackToTop)
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: innerBoxIsScrolled
                  ? Colors.white.withOpacity(0.15)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: innerBoxIsScrolled
                  ? Border.all(color: Colors.white.withOpacity(0.3), width: 1)
                  : null,
              boxShadow: innerBoxIsScrolled
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: IconButton(
              icon: Icon(
                Icons.keyboard_arrow_up,
                color: innerBoxIsScrolled
                    ? Colors.white
                    : const Color(0xFF3B82F6),
                size: 20,
              ),
              onPressed: () {
                if (_scrollController.hasClients) {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                  );
                }
              },
            ),
          ),
        // Filtre butonu
        Container(
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: innerBoxIsScrolled
                ? Colors.white.withOpacity(0.15)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: innerBoxIsScrolled
                ? Border.all(color: Colors.white.withOpacity(0.3), width: 1)
                : null,
            boxShadow: innerBoxIsScrolled
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list : Icons.filter_list_outlined,
              color: _showFilters
                  ? (innerBoxIsScrolled
                        ? Colors.white
                        : const Color(0xFF3B82F6))
                  : (innerBoxIsScrolled
                        ? Colors.white70
                        : const Color(0xFF6B7280)),
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ),
      ],
    );
  }

  // Filter Section
  Widget _buildFilterSection() {
    return SliverToBoxAdapter(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        constraints: const BoxConstraints(
          maxHeight: 400,
        ), // Maksimum yükseklik sınırı
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, const Color(0xFF3B82F6).withOpacity(0.01)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF3B82F6).withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: const Color(0xFF3B82F6).withOpacity(0.08),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.tune,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Filtreler ve Sıralama',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${_filteredEarthquakes.length} sonuç',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Sort Options Section
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.sort,
                          size: 14,
                          color: Color(0xFF3B82F6),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Sıralama',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF374151),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _buildFilterChip(
                          'En Yeni',
                          Icons.schedule,
                          _sortType == SortType.newest,
                          () {
                            setState(() {
                              _sortType = SortType.newest;
                              _applyFiltersAndSort();
                            });
                          },
                        ),
                        _buildFilterChip(
                          'En Eski',
                          Icons.history,
                          _sortType == SortType.oldest,
                          () {
                            setState(() {
                              _sortType = SortType.oldest;
                              _applyFiltersAndSort();
                            });
                          },
                        ),
                        _buildFilterChip(
                          'Büyüklük ↓',
                          Icons.trending_down,
                          _sortType == SortType.magnitude,
                          () {
                            setState(() {
                              _sortType = SortType.magnitude;
                              _applyFiltersAndSort();
                            });
                          },
                        ),
                        _buildFilterChip(
                          'Büyüklük ↑',
                          Icons.trending_up,
                          _sortType == SortType.magnitudeLow,
                          () {
                            setState(() {
                              _sortType = SortType.magnitudeLow;
                              _applyFiltersAndSort();
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Magnitude Filter Section
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.filter_alt,
                          size: 14,
                          color: Color(0xFF3B82F6),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Büyüklük',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF374151),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _buildFilterChip(
                          'Tümü',
                          Icons.all_inclusive,
                          _filterMagnitude == FilterMagnitude.all,
                          () {
                            setState(() {
                              _filterMagnitude = FilterMagnitude.all;
                              _applyFiltersAndSort();
                            });
                          },
                        ),
                        _buildFilterChip(
                          'Küçük (<3.0)',
                          Icons.radio_button_unchecked,
                          _filterMagnitude == FilterMagnitude.small,
                          () {
                            setState(() {
                              _filterMagnitude = FilterMagnitude.small;
                              _applyFiltersAndSort();
                            });
                          },
                          color: const Color(0xFF10B981),
                        ),
                        _buildFilterChip(
                          'Orta (3.0-4.9)',
                          Icons.adjust,
                          _filterMagnitude == FilterMagnitude.medium,
                          () {
                            setState(() {
                              _filterMagnitude = FilterMagnitude.medium;
                              _applyFiltersAndSort();
                            });
                          },
                          color: const Color(0xFFF59E0B),
                        ),
                        _buildFilterChip(
                          'Büyük (≥5.0)',
                          Icons.warning,
                          _filterMagnitude == FilterMagnitude.large,
                          () {
                            setState(() {
                              _filterMagnitude = FilterMagnitude.large;
                              _applyFiltersAndSort();
                            });
                          },
                          color: const Color(0xFFEF4444),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // City Filter Section
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.location_city,
                          size: 14,
                          color: Color(0xFF3B82F6),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'İl Seçimi',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF374151),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedRegion,
                          isExpanded: true,
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Color(0xFF6B7280),
                            size: 18,
                          ),
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: const Color(0xFF374151),
                            fontWeight: FontWeight.w500,
                          ),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedRegion = newValue;
                                _applyFiltersAndSort();
                              });
                            }
                          },
                          items: _turkishCities.map<DropdownMenuItem<String>>((
                            String city,
                          ) {
                            return DropdownMenuItem<String>(
                              value: city,
                              child: Row(
                                children: [
                                  if (city == 'Tümü')
                                    const Icon(
                                      Icons.public,
                                      size: 14,
                                      color: Color(0xFF6B7280),
                                    )
                                  else
                                    const Icon(
                                      Icons.location_on,
                                      size: 14,
                                      color: Color(0xFF3B82F6),
                                    ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      city,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Clear Filters Button
              if (_sortType != SortType.newest ||
                  _filterMagnitude != FilterMagnitude.all ||
                  _selectedRegion != 'Tümü' ||
                  _searchController.text.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _sortType = SortType.newest;
                        _filterMagnitude = FilterMagnitude.all;
                        _selectedRegion = 'Tümü';
                        _searchController.clear();
                        _applyFiltersAndSort();
                      });
                    },
                    icon: const Icon(Icons.clear_all, size: 16),
                    label: const Text('Filtreleri Temizle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF1F5F9),
                      foregroundColor: const Color(0xFF64748B),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(
                          color: Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap, {
    Color? color,
  }) {
    final chipColor = color ?? const Color(0xFF3B82F6);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [chipColor, chipColor.withOpacity(0.8)])
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? chipColor : const Color(0xFFE2E8F0),
            width: isSelected ? 0 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: chipColor.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Modern Search Bar
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF3B82F6).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: const Color(0xFF1E293B),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Şehir, bölge veya konum ara...',
          hintStyle: GoogleFonts.inter(
            color: const Color(0xFF9CA3AF),
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Container(
            padding: const EdgeInsets.all(12),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.search, color: Colors.white, size: 16),
            ),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? Container(
                  padding: const EdgeInsets.all(12),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _searchController.clear();
                        _applyFiltersAndSort();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.clear,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  // Modern Search Bar

  Widget _buildCompactSummaryCard() {
    final now = DateTime.now();
    final last24Hours = _filteredEarthquakes.where((earthquake) {
      final diff = now.difference(earthquake.dateTime).inHours;
      return diff <= 24;
    }).length;

    final totalCount = _filteredEarthquakes.length;
    final avgMagnitude = _filteredEarthquakes.isNotEmpty
        ? _filteredEarthquakes.map((e) => e.mag).reduce((a, b) => a + b) /
              _filteredEarthquakes.length
        : 0.0;
    final maxMagnitude = _filteredEarthquakes.isNotEmpty
        ? _filteredEarthquakes.map((e) => e.mag).reduce((a, b) => a > b ? a : b)
        : 0.0;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    const Color(0xFF3B82F6).withOpacity(0.02),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.analytics_outlined,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Deprem Özeti',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF10B981).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Canlı',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Stats
                  Row(
                    children: [
                      Expanded(
                        child: _buildCompactStatItem(
                          'Toplam',
                          totalCount.toString(),
                          Icons.all_inclusive,
                          const Color(0xFF3B82F6),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildCompactStatItem(
                          '24 Saat',
                          last24Hours.toString(),
                          Icons.schedule,
                          const Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildCompactStatItem(
                          'En Büyük',
                          maxMagnitude.toStringAsFixed(1),
                          Icons.trending_up,
                          const Color(0xFFEF4444),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildCompactStatItem(
                          'Ortalama',
                          avgMagnitude.toStringAsFixed(1),
                          Icons.analytics,
                          const Color(0xFFF59E0B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactStatItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.1), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 9,
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Güncel Deprem Verileri',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF10B981).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Canlı',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEarthquakeCard(int index) {
    final earthquake = _filteredEarthquakes[index];

    final dateTime = earthquake.dateTime;
    final timeFormat =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    final dateFormat = '${dateTime.day} ${_getMonthName(dateTime.month)}';

    final timeAgo = _getTimeAgo(dateTime);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          _navigateToDetail(earthquake);
        },
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                _getMagnitudeColor(earthquake.mag).withOpacity(0.01),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _getMagnitudeColor(earthquake.mag).withOpacity(0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
              BoxShadow(
                color: _getMagnitudeColor(earthquake.mag).withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: _getMagnitudeColor(earthquake.mag).withOpacity(0.03),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Enhanced Magnitude Badge
                  Hero(
                    tag: 'magnitude_${earthquake.earthquakeId}',
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getMagnitudeColor(earthquake.mag).withOpacity(0.1),
                            _getMagnitudeColor(
                              earthquake.mag,
                            ).withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getMagnitudeColor(
                            earthquake.mag,
                          ).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getMagnitudeColor(earthquake.mag),
                              _getMagnitudeColor(
                                earthquake.mag,
                              ).withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: _getMagnitudeColor(
                                earthquake.mag,
                              ).withOpacity(0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                            BoxShadow(
                              color: _getMagnitudeColor(
                                earthquake.mag,
                              ).withOpacity(0.2),
                              blurRadius: 32,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    earthquake.mag.toStringAsFixed(1),
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'ML',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: _getIntensityColor(earthquake.mag),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _getIntensityColor(
                                        earthquake.mag,
                                      ).withOpacity(0.6),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    _getMagnitudeColor(earthquake.mag),
                                    _getMagnitudeColor(
                                      earthquake.mag,
                                    ).withOpacity(0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: _getMagnitudeColor(
                                      earthquake.mag,
                                    ).withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Text(
                                _getMagnitudeLabel(earthquake.mag),
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF10B981,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF10B981,
                                    ).withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  timeAgo,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF10B981),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.location_on,
                                size: 14,
                                color: Color(0xFF3B82F6),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                earthquake.title,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1E293B),
                                  height: 1.3,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF3B82F6),
                                      Color(0xFF1E40AF),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF3B82F6,
                                      ).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.schedule,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$timeFormat • $dateFormat',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                earthquake.provider.toUpperCase(),
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF64748B),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFF8FAFC),
                      _getMagnitudeColor(earthquake.mag).withOpacity(0.02),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _getMagnitudeColor(earthquake.mag).withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        'En Yakın Şehir',
                        _getClosestCityInfo(earthquake),
                        Icons.location_city,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFFE2E8F0),
                            const Color(0xFFE2E8F0).withOpacity(0.3),
                            const Color(0xFFE2E8F0),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        'Hassas Saat',
                        _getPreciseTime(earthquake.dateTime),
                        Icons.access_time_filled,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFFE2E8F0),
                            const Color(0xFFE2E8F0).withOpacity(0.3),
                            const Color(0xFFE2E8F0),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        'Derinlik',
                        '${earthquake.depth.toStringAsFixed(1)} km',
                        Icons.vertical_align_bottom_outlined,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Az önce';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} dakika önce';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} saat önce';
    } else {
      return '${difference.inDays} gün önce';
    }
  }

  String _getMagnitudeLabel(double magnitude) {
    if (magnitude >= 5.0) return 'BÜYÜK';
    if (magnitude >= 4.0) return 'ORTA';
    if (magnitude >= 3.0) return 'KÜÇÜK';
    return 'ÇOK KÜÇÜK';
  }

  Color _getIntensityColor(double magnitude) {
    if (magnitude >= 5.0) return Colors.red;
    if (magnitude >= 4.0) return Colors.orange;
    if (magnitude >= 3.0) return Colors.yellow;
    return Colors.green;
  }

  // Detay sayfasına navigasyon fonksiyonu
  void _navigateToDetail(Earthquake earthquake) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            EarthquakeDetail(earthquake: earthquake),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          var offsetAnimation = animation.drive(tween);
          var fadeAnimation = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(parent: animation, curve: curve));

          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(opacity: fadeAnimation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF3B82F6)),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: const Color(0xFF6B7280),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Color _getMagnitudeColor(double magnitude) {
    if (magnitude >= 5.0) return const Color(0xFFEF4444); // Red
    if (magnitude >= 4.0) return const Color(0xFFF59E0B); // Orange
    if (magnitude >= 3.0) return const Color(0xFF3B82F6); // Blue
    return const Color(0xFF10B981); // Green
  }

  String _getMonthName(int month) {
    const months = [
      '',
      'Oca',
      'Şub',
      'Mar',
      'Nis',
      'May',
      'Haz',
      'Tem',
      'Ağu',
      'Eyl',
      'Eki',
      'Kas',
      'Ara',
    ];
    return months[month];
  }

  // Helper method to get closest city information
  String _getClosestCityInfo(Earthquake earthquake) {
    try {
      // Önce location_properties'den en yakın şehri almaya çalış
      if (earthquake.locationProperties.isNotEmpty &&
          earthquake.locationProperties.containsKey('closestCity')) {
        final closestCity = earthquake.locationProperties['closestCity'];
        if (closestCity != null && closestCity['name'] != null) {
          return closestCity['name'].toString();
        }
      }

      // API'den gelen location_properties verisi yoksa title'dan çıkarmaya çalış
      if (earthquake.title.contains('-')) {
        final parts = earthquake.title.split('-');
        if (parts.length >= 2) {
          final cityPart = parts[1].trim();
          final cityName = cityPart.replaceAll(RegExp(r'\([^)]*\)'), '').trim();
          return cityName.isNotEmpty ? cityName : 'Bilinmiyor';
        }
      }

      // Title'dan şehir bilgisini çıkarmaya çalış
      if (earthquake.title.contains('(') && earthquake.title.contains(')')) {
        final startIndex = earthquake.title.lastIndexOf('(');
        final endIndex = earthquake.title.lastIndexOf(')');
        if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
          return earthquake.title.substring(startIndex + 1, endIndex);
        }
      }

      return 'Bilinmiyor';
    } catch (e) {
      return 'Bilinmiyor';
    }
  }

  // Helper method to get precise time
  String _getPreciseTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }
}
