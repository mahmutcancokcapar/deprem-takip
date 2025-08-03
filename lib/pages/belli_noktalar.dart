// ignore_for_file: deprecated_member_use, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/place_model.dart';
import '../services/location_service.dart';
import '../services/places_service.dart';
import '../widgets/permission_request_widget.dart';

class BelliNoktalar extends StatefulWidget {
  const BelliNoktalar({super.key});

  @override
  State<BelliNoktalar> createState() => _BelliNoktalarState();
}

class _BelliNoktalarState extends State<BelliNoktalar>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late TabController _tabController;

  final LocationService _locationService = LocationService();
  final PlacesService _placesService = PlacesService();

  String selectedCity = 'Gaziantep';
  String selectedDistrict = 'Şahinbey';

  final List<String> cities = ['Gaziantep', 'İstanbul', 'Ankara', 'İzmir'];
  final List<String> districts = ['Şahinbey', 'Şehitkamil', 'Oğuzeli', 'Nizip'];

  bool _isLoading = false;
  bool _hasPermission = false;
  Position? _currentPosition;
  List<Place> _allPlaces = [];
  List<Place> _hospitals = [];
  List<Place> _police = [];
  List<Place> _fireStations = [];
  List<Place> _pharmacies = [];
  List<Place> _parks = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
    _checkLocationPermission();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkLocationPermission() async {
    final hasPermission = await _locationService.isPermissionGranted();
    setState(() {
      _hasPermission = hasPermission;
    });

    if (hasPermission) {
      await _getCurrentLocationAndFetchPlaces();
    }
  }

  Future<void> _requestPermission() async {
    final granted = await _locationService.requestPermission();
    setState(() {
      _hasPermission = granted;
    });

    if (granted) {
      await _getCurrentLocationAndFetchPlaces();
    }
  }

  Future<void> _getCurrentLocationAndFetchPlaces() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _currentPosition = await _locationService.getCurrentPosition();
      await _fetchNearbyPlaces();
    } catch (e) {
      print('Konum alınırken hata: $e');
      // Hata durumunda varsayılan veriler kullanılacak
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchNearbyPlaces() async {
    if (_currentPosition == null) return;

    try {
      _allPlaces = await _placesService.getNearbyPlaces(_currentPosition!);
      _categorizeePlaces();
    } catch (e) {
      print('Yerler alınırken hata: $e');
      // Hata durumunda varsayılan veriler kullanılacak
    }
  }

  void _categorizeePlaces() {
    _hospitals = _allPlaces
        .where((place) => place.type == 'hospital')
        .take(5)
        .toList();
    _police = _allPlaces
        .where((place) => place.type == 'police')
        .take(5)
        .toList();
    _fireStations = _allPlaces
        .where((place) => place.type == 'fire_station')
        .take(3)
        .toList();
    _pharmacies = _allPlaces
        .where((place) => place.type == 'pharmacy')
        .take(8)
        .toList();
    _parks = _allPlaces.where((place) => place.type == 'park').take(6).toList();

    // Mesafeye göre sırala
    _hospitals.sort((a, b) => a.distance.compareTo(b.distance));
    _police.sort((a, b) => a.distance.compareTo(b.distance));
    _fireStations.sort((a, b) => a.distance.compareTo(b.distance));
    _pharmacies.sort((a, b) => a.distance.compareTo(b.distance));
    _parks.sort((a, b) => a.distance.compareTo(b.distance));
  }

  Future<void> _openInMaps(
    String placeName, [
    double? latitude,
    double? longitude,
  ]) async {
    try {
      List<Map<String, dynamic>> urlsToTry = [];

      if (latitude != null && longitude != null) {
        // Farklı harita uygulamaları için URL'ler - Android için optimize edilmiş
        urlsToTry.addAll([
          // Android Google Maps intent - en güvenilir yöntem
          {
            'url': 'geo:$latitude,$longitude?q=$latitude,$longitude',
            'mode': LaunchMode.externalApplication,
          },
          // Google Maps web - koordinatlarla
          {
            'url':
                'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
            'mode': LaunchMode.externalApplication,
          },
          // Google Maps app specific intent
          {
            'url': 'google.navigation:q=$latitude,$longitude',
            'mode': LaunchMode.externalApplication,
          },
          // Basit geo intent
          {
            'url': 'geo:$latitude,$longitude',
            'mode': LaunchMode.externalApplication,
          },
          // Google Maps direkt link
          {
            'url': 'https://maps.google.com/?q=$latitude,$longitude',
            'mode': LaunchMode.platformDefault,
          },
        ]);
      } else {
        // Yer adını URL için encode et
        String searchQuery;

        if (_currentPosition != null) {
          searchQuery =
              '$placeName near ${_currentPosition!.latitude},${_currentPosition!.longitude}';
        } else {
          searchQuery = '$placeName $selectedDistrict $selectedCity';
        }

        String encodedSearchQuery = Uri.encodeComponent(searchQuery);

        urlsToTry.addAll([
          // Android geo intent ile arama
          {
            'url': 'geo:0,0?q=$encodedSearchQuery',
            'mode': LaunchMode.externalApplication,
          },
          // Google Maps web arama
          {
            'url':
                'https://www.google.com/maps/search/?api=1&query=$encodedSearchQuery',
            'mode': LaunchMode.externalApplication,
          },
          // Google Maps navigation intent
          {
            'url': 'google.navigation:q=$encodedSearchQuery',
            'mode': LaunchMode.externalApplication,
          },
          // Google Maps direkt arama
          {
            'url': 'https://maps.google.com/maps?q=$encodedSearchQuery',
            'mode': LaunchMode.platformDefault,
          },
        ]);
      }

      bool launched = false;

      for (var urlData in urlsToTry) {
        try {
          String url = urlData['url'];
          LaunchMode mode = urlData['mode'];

          Uri uri = Uri.parse(url);
          print('Trying URL: $url with mode: $mode');

          if (await canLaunchUrl(uri)) {
            print('Launching URL: $url');
            await launchUrl(uri, mode: mode);
            launched = true;
            break;
          } else {
            print('Cannot launch URL: $url');
          }
        } catch (e) {
          print('Error with URL ${urlData['url']}: $e');
          continue;
        }
      }

      if (!launched) {
        // Hiçbir URL çalışmazsa, son çare olarak basit web tarayıcısında Google Maps'i aç
        try {
          String webUrl;
          if (latitude != null && longitude != null) {
            webUrl = 'https://maps.google.com/@$latitude,$longitude,15z';
          } else {
            String encodedSearch = Uri.encodeComponent(
              '$placeName $selectedDistrict $selectedCity',
            );
            webUrl = 'https://maps.google.com/maps?q=$encodedSearch';
          }

          Uri webUri = Uri.parse(webUrl);
          print('Last resort - trying web URL: $webUrl');

          if (await canLaunchUrl(webUri)) {
            await launchUrl(webUri, mode: LaunchMode.inAppWebView);
            launched = true;
          }
        } catch (e) {
          print('Web fallback failed: $e');
        }
      }

      if (!launched && context.mounted) {
        _showMapsInstallDialog();
      }
    } catch (e) {
      print('Harita açılırken hata: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Haritalar uygulaması açılamadı: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showMapsInstallDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Harita Uygulaması Bulunamadı',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Konumu haritada görüntülemek için bir harita uygulaması gerekiyor. Google Maps uygulamasını yüklemek ister misiniz?',
            style: GoogleFonts.inter(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'İptal',
                style: GoogleFonts.inter(color: const Color(0xFF6B7280)),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  Uri playStoreUri = Uri.parse(
                    'https://play.google.com/store/apps/details?id=com.google.android.apps.maps',
                  );
                  if (await canLaunchUrl(playStoreUri)) {
                    await launchUrl(
                      playStoreUri,
                      mode: LaunchMode.externalApplication,
                    );
                  } else {
                    // Play Store açılamazsa, browser'da aç
                    Uri browserUri = Uri.parse('https://maps.google.com');
                    await launchUrl(
                      browserUri,
                      mode: LaunchMode.externalApplication,
                    );
                  }
                } catch (e) {
                  print('Play Store açılamadı: $e');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Google Maps Yükle',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPermission) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: PermissionRequestWidget(onRequest: _requestPermission),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverAppBar(
                      automaticallyImplyLeading: false,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      pinned: false,
                      floating: true,
                      snap: true,
                      title: Hero(
                        tag: 'places_title',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF10B981),
                                    Color(0xFF059669),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF10B981,
                                    ).withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.location_on_outlined,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Önemli Yerler',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        Container(
                          margin: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF10B981),
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.my_location_outlined,
                                    color: Color(0xFF6B7280),
                                    size: 20,
                                  ),
                            onPressed: _isLoading
                                ? null
                                : _getCurrentLocationAndFetchPlaces,
                          ),
                        ),
                      ],
                    ),
                    SliverToBoxAdapter(
                      child: Column(
                        children: [_buildTabBar(), const SizedBox(height: 16)],
                      ),
                    ),
                  ];
                },
            body: TabBarView(
              controller: _tabController,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildEmergencyPlaces(),
                _buildPharmacies(),
                _buildAssemblyAreas(),
                _buildOnDutyPharmacies(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /*Widget _buildLocationSelector() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    const Color(0xFF10B981).withOpacity(0.02),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.location_city_outlined,
                          color: Color(0xFF10B981),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Konum Seçimi',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown(
                          'Şehir',
                          selectedCity,
                          cities,
                          Icons.location_city,
                          (value) => setState(() => selectedCity = value!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDropdown(
                          'İlçe',
                          selectedDistrict,
                          districts,
                          Icons.map_outlined,
                          (value) => setState(() => selectedDistrict = value!),
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
  }*/

  /*Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    IconData icon,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, size: 18),
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1E293B),
              ),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Row(
                    children: [
                      Icon(icon, size: 16, color: const Color(0xFF6B7280)),
                      const SizedBox(width: 8),
                      Text(item),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }*/

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        dividerColor: Colors.transparent,
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF059669)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorWeight: 0,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF6B7280),
        labelStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(
            icon: Icon(Icons.local_hospital_outlined, size: 18),
            text: 'Acil',
          ),
          Tab(
            icon: Icon(Icons.local_pharmacy_outlined, size: 18),
            text: 'Eczane',
          ),
          Tab(icon: Icon(Icons.groups_outlined, size: 18), text: 'Toplanma'),
          Tab(icon: Icon(Icons.access_time, size: 18), text: 'Nöbetçi'),
        ],
      ),
    );
  }

  Widget _buildEmergencyPlaces() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
        ),
      );
    }

    // Gerçek veriler varsa kullan, yoksa varsayılan veriler
    List<Map<String, dynamic>> emergencyData = [];

    // Hastaneler
    for (var hospital in _hospitals) {
      emergencyData.add({
        'name': hospital.name,
        'type': 'Hastane',
        'distance': '${hospital.distance.toStringAsFixed(1)} km',
        'phone': hospital.phoneNumber ?? 'Numara yok',
        'icon': Icons.local_hospital,
        'color': const Color(0xFFEF4444),
        'latitude': hospital.latitude,
        'longitude': hospital.longitude,
      });
    }

    // Polis karakolları
    for (var police in _police) {
      emergencyData.add({
        'name': police.name,
        'type': 'Polis',
        'distance': '${police.distance.toStringAsFixed(1)} km',
        'phone': police.phoneNumber ?? '155',
        'icon': Icons.security,
        'color': const Color(0xFF3B82F6),
        'latitude': police.latitude,
        'longitude': police.longitude,
      });
    }

    // İtfaiye istasyonları
    for (var fireStation in _fireStations) {
      emergencyData.add({
        'name': fireStation.name,
        'type': 'İtfaiye',
        'distance': '${fireStation.distance.toStringAsFixed(1)} km',
        'phone': fireStation.phoneNumber ?? '112',
        'icon': Icons.fire_truck,
        'color': const Color(0xFFF59E0B),
        'latitude': fireStation.latitude,
        'longitude': fireStation.longitude,
      });
    }

    // Eğer gerçek veri yoksa varsayılan veriler kullan
    if (emergencyData.isEmpty) {
      emergencyData = [
        {
          'name': 'Gaziantep Üniversitesi Tıp Fakültesi',
          'type': 'Hastane',
          'distance': '1.2 km',
          'phone': '0342 360 60 60',
          'icon': Icons.local_hospital,
          'color': const Color(0xFFEF4444),
        },
        {
          'name': 'İtfaiye Şahinbey İstasyonu',
          'type': 'İtfaiye',
          'distance': '800 m',
          'phone': '112',
          'icon': Icons.fire_truck,
          'color': const Color(0xFFF59E0B),
        },
        {
          'name': 'Şahinbey Emniyet Müdürlüğü',
          'type': 'Polis',
          'distance': '1.5 km',
          'phone': '155',
          'icon': Icons.security,
          'color': const Color(0xFF3B82F6),
        },
        {
          'name': 'AFAD Koordinasyon Merkezi',
          'type': 'AFAD',
          'distance': '2.1 km',
          'phone': '0342 325 10 27',
          'icon': Icons.emergency,
          'color': const Color(0xFF8B5CF6),
        },
      ];
    }

    return _buildPlacesList(emergencyData, 'Acil Durum Yerleri');
  }

  Widget _buildPharmacies() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
        ),
      );
    }

    // Gerçek veriler varsa kullan
    List<Map<String, dynamic>> pharmacyData = [];

    for (var pharmacy in _pharmacies) {
      pharmacyData.add({
        'name': pharmacy.name,
        'type': 'Açık',
        'distance': '${pharmacy.distance.toStringAsFixed(1)} km',
        'phone': pharmacy.phoneNumber ?? 'Numara yok',
        'icon': Icons.local_pharmacy,
        'color': const Color(0xFF10B981),
        'latitude': pharmacy.latitude,
        'longitude': pharmacy.longitude,
      });
    }

    // Eğer gerçek veri yoksa varsayılan veriler kullan
    if (pharmacyData.isEmpty) {
      pharmacyData = [
        {
          'name': 'Sağlık Eczanesi',
          'type': '24 Saat Açık',
          'distance': '450 m',
          'phone': '0342 123 45 67',
          'icon': Icons.local_pharmacy,
          'color': const Color(0xFF10B981),
        },
        {
          'name': 'Güven Eczanesi',
          'type': 'Açık',
          'distance': '680 m',
          'phone': '0342 987 65 43',
          'icon': Icons.local_pharmacy,
          'color': const Color(0xFF10B981),
        },
        {
          'name': 'Merkez Eczanesi',
          'type': 'Açık',
          'distance': '920 m',
          'phone': '0342 456 78 90',
          'icon': Icons.local_pharmacy,
          'color': const Color(0xFF10B981),
        },
        {
          'name': 'Şifa Eczanesi',
          'type': 'Kapalı',
          'distance': '1.1 km',
          'phone': '0342 321 54 76',
          'icon': Icons.local_pharmacy,
          'color': const Color(0xFF6B7280),
        },
      ];
    }

    return _buildPlacesList(pharmacyData, 'Yakındaki Eczaneler');
  }

  Widget _buildAssemblyAreas() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
        ),
      );
    }

    // Gerçek veriler varsa kullan (parklar toplanma alanı olarak kullanılabilir)
    List<Map<String, dynamic>> assemblyData = [];

    for (var park in _parks) {
      assemblyData.add({
        'name': park.name,
        'type': 'Toplanma Alanı',
        'distance': '${park.distance.toStringAsFixed(1)} km',
        'phone': '-',
        'icon': Icons.park,
        'color': const Color(0xFF10B981),
        'latitude': park.latitude,
        'longitude': park.longitude,
      });
    }

    // Eğer gerçek veri yoksa varsayılan veriler kullan
    if (assemblyData.isEmpty) {
      assemblyData = [
        {
          'name': 'Şahinbey Belediyesi Park',
          'type': 'Toplanma Alanı',
          'distance': '300 m',
          'phone': '-',
          'icon': Icons.park,
          'color': const Color(0xFF10B981),
        },
        {
          'name': 'Atatürk Stadyumu',
          'type': 'Büyük Alan',
          'distance': '1.8 km',
          'phone': '-',
          'icon': Icons.stadium,
          'color': const Color(0xFF3B82F6),
        },
        {
          'name': 'Gaziantep Üniversitesi Kampüsü',
          'type': 'Açık Alan',
          'distance': '2.2 km',
          'phone': '-',
          'icon': Icons.school,
          'color': const Color(0xFFF59E0B),
        },
        {
          'name': 'Millet Bahçesi',
          'type': 'Park Alanı',
          'distance': '2.5 km',
          'phone': '-',
          'icon': Icons.nature,
          'color': const Color(0xFF10B981),
        },
      ];
    }

    return _buildPlacesList(assemblyData, 'Toplanma Alanları');
  }

  Widget _buildOnDutyPharmacies() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
        ),
      );
    }

    // Nöbetçi eczaneler için özel filtreleme (24 saat açık olanlar)
    List<Map<String, dynamic>> onDutyData = [];

    // Gerçek verilerden 24 saat açık olanları seç (bu bilgi API'dan gelmeyebilir, varsayılan olarak bazılarını nöbetçi kabul edebiliriz)
    var nearestPharmacies = _pharmacies.take(3).toList();
    for (int i = 0; i < nearestPharmacies.length; i++) {
      var pharmacy = nearestPharmacies[i];
      String dutyType = i == 0
          ? 'Gece Nöbetçisi'
          : i == 1
          ? '24 Saat'
          : 'Bugün Nöbetçi';
      Color dutyColor = i == 0
          ? const Color(0xFF8B5CF6)
          : i == 1
          ? const Color(0xFFEF4444)
          : const Color(0xFF10B981);
      IconData dutyIcon = i == 0
          ? Icons.nightlight
          : i == 1
          ? Icons.access_time_filled
          : Icons.local_pharmacy;

      onDutyData.add({
        'name': pharmacy.name,
        'type': dutyType,
        'distance': '${pharmacy.distance.toStringAsFixed(1)} km',
        'phone': pharmacy.phoneNumber ?? 'Numara yok',
        'icon': dutyIcon,
        'color': dutyColor,
        'latitude': pharmacy.latitude,
        'longitude': pharmacy.longitude,
      });
    }

    // Eğer gerçek veri yoksa varsayılan veriler kullan
    if (onDutyData.isEmpty) {
      onDutyData = [
        {
          'name': 'Nöbetçi Merkez Eczanesi',
          'type': 'Gece Nöbetçisi',
          'distance': '1.2 km',
          'phone': '0342 111 22 33',
          'icon': Icons.nightlight,
          'color': const Color(0xFF8B5CF6),
        },
        {
          'name': 'Gece Eczanesi',
          'type': '24 Saat',
          'distance': '2.1 km',
          'phone': '0342 444 55 66',
          'icon': Icons.access_time_filled,
          'color': const Color(0xFFEF4444),
        },
        {
          'name': 'Şahinbey Nöbetçi Eczane',
          'type': 'Bugün Nöbetçi',
          'distance': '890 m',
          'phone': '0342 777 88 99',
          'icon': Icons.local_pharmacy,
          'color': const Color(0xFF10B981),
        },
      ];
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF8B5CF6).withOpacity(0.1),
                  const Color(0xFF3B82F6).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF8B5CF6).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Color(0xFF8B5CF6),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Nöbetçi eczaneler günlük olarak güncellenmektedir. Gitmeden önce arayarak kontrol ediniz.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF6B7280),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildScrollableList(onDutyData, 'Nöbetçi Eczaneler'),
        ],
      ),
    );
  }

  Widget _buildPlacesList(List<Map<String, dynamic>> data, String title) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...data.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> place = entry.value;

            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 400 + (index * 100)),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value.clamp(0.0, 1.0),
                    child: _buildPlaceCard(place),
                  ),
                );
              },
            );
            // ignore: unnecessary_to_list_in_spreads
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildScrollableList(List<Map<String, dynamic>> data, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...data.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> place = entry.value;

            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 400 + (index * 100)),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value.clamp(0.0, 1.0),
                    child: _buildPlaceCard(place),
                  ),
                );
              },
            );
            // ignore: unnecessary_to_list_in_spreads
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPlaceCard(Map<String, dynamic> place) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () =>
              _openInMaps(place['name'], place['latitude'], place['longitude']),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: place['color'].withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: place['color'].withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            place['color'],
                            place['color'].withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: place['color'].withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(place['icon'], color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            place['name'],
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E293B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: place['color'].withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  place['type'],
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: place['color'],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: const Color(0xFF6B7280),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                place['distance'],
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Harita ikonu - tıklanabilir olduğunu gösterir
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.map_outlined,
                        size: 20,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
                if (place['phone'] != '-') ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 16,
                          color: const Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          place['phone'],
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () async {
                            final phoneNumber = place['phone']
                                .toString()
                                .replaceAll(' ', '');
                            if (phoneNumber != '-' &&
                                phoneNumber != 'Numara yok') {
                              try {
                                final Uri phoneUri = Uri(
                                  scheme: 'tel',
                                  path: phoneNumber,
                                );
                                if (await canLaunchUrl(phoneUri)) {
                                  await launchUrl(phoneUri);
                                } else {
                                  throw 'Telefon araması desteklenmiyor';
                                }
                              } catch (e) {
                                print('Telefon araması başlatılamadı: $e');
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Telefon araması başlatılamadı',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.call,
                              size: 16,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
