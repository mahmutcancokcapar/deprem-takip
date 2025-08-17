// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:deprem_takip/models/model.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class EarthquakeDetail extends StatefulWidget {
  final Earthquake earthquake;

  const EarthquakeDetail({super.key, required this.earthquake});

  @override
  State<EarthquakeDetail> createState() => _EarthquakeDetailState();
}

class _EarthquakeDetailState extends State<EarthquakeDetail>
    with TickerProviderStateMixin {
  late AnimationController _mainAnimationController;
  late AnimationController _pulseAnimationController;
  late AnimationController _waveAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;

  bool _isMapExpanded = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startPeriodicAnimations();
  }

  void _initAnimations() {
    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _waveAnimationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _mainAnimationController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutBack),
          ),
        );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveAnimationController, curve: Curves.linear),
    );

    _mainAnimationController.forward();
  }

  void _startPeriodicAnimations() {
    _pulseAnimationController.repeat(reverse: true);
    _waveAnimationController.repeat();
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    _pulseAnimationController.dispose();
    _waveAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coordinates = widget.earthquake.geojson['coordinates'] as List;
    final longitude = coordinates[0];
    final latitude = coordinates[1];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        _buildHeroMagnitudeCard(),
                        const SizedBox(height: 20),
                        _buildLocationCard(),
                        const SizedBox(height: 20),
                        _buildMapCard(latitude, longitude),
                        const SizedBox(height: 20),
                        _buildNearestCitiesCard(),
                        const SizedBox(height: 20),
                        _buildDetailsCard(),
                        const SizedBox(height: 20),
                        _buildTimelineCard(),
                        const SizedBox(height: 20),
                        _buildActionButtons(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 100,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFFF8FAFC),
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withOpacity(0.08),
      elevation: 2,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1E293B),
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(
              Icons.ios_share_rounded,
              color: Colors.white,
              size: 18,
            ),
            onPressed: () => _shareEarthquakeData(),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 80, bottom: 16),
        title: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.info_rounded,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Deprem Detayları',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFFF8FAFC),
                const Color(0xFF3B82F6).withOpacity(0.01),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroMagnitudeCard() {
    return Hero(
      tag: 'magnitude-${widget.earthquake.earthquakeId}',
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getMagnitudeColor(widget.earthquake.mag),
                      _getMagnitudeColor(
                        widget.earthquake.mag,
                      ).withOpacity(0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: _getMagnitudeColor(
                        widget.earthquake.mag,
                      ).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Sol taraf - Büyüklük bilgisi
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.waves_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Büyüklük',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    widget.earthquake.mag.toStringAsFixed(1),
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 52,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      height: 0.9,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      'ML',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Sağ taraf - Durum ve seviye
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _getMagnitudeDescription(widget.earthquake.mag),
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.95),
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.end,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.25),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  _getTimeAgo(widget.earthquake.dateTime),
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildMagnitudeIndicator(),
                  ],
                ),
              ),
            );
          },
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
      return '${difference.inMinutes} dk önce';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} sa önce';
    } else {
      return '${difference.inDays} gün önce';
    }
  }

  Widget _buildMagnitudeIndicator() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Şiddet Göstergesi',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(widget.earthquake.mag / 10 * 100).toStringAsFixed(0)}%',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeOutCubic,
                width:
                    (MediaQuery.of(context).size.width - 120) *
                    (widget.earthquake.mag / 10).clamp(0.0, 1.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.4),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, const Color(0xFF3B82F6).withOpacity(0.01)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF3B82F6).withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Konum Bilgileri',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Deprem merkezi ve koordinatlar',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Location title section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFF8FAFC),
                  const Color(0xFF3B82F6).withOpacity(0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF3B82F6).withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.place_rounded,
                    color: Color(0xFF3B82F6),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.earthquake.title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildCoordinateRow(),
        ],
      ),
    );
  }

  Widget _buildCoordinateRow() {
    final coordinates = widget.earthquake.geojson['coordinates'] as List;
    final longitude = coordinates[0];
    final latitude = coordinates[1];

    return Column(
      children: [
        // En yakın şehir bilgisi
        if (_getClosestCityInfo().isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF10B981).withOpacity(0.08),
                  const Color(0xFF10B981).withOpacity(0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF10B981).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.location_city_rounded,
                    color: Color(0xFF10B981),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'En Yakın Şehir',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFF10B981),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getClosestCityInfo(),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Koordinat bilgileri
        Row(
          children: [
            Expanded(
              child: _buildCoordinateItem(
                'Enlem',
                '${latitude.toStringAsFixed(6)}°',
                Icons.my_location_rounded,
                const Color(0xFF059669),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCoordinateItem(
                'Boylam',
                '${longitude.toStringAsFixed(6)}°',
                Icons.explore_rounded,
                const Color(0xFFDC2626),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCoordinateItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Clipboard.setData(ClipboardData(text: value));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text('$label kopyalandı'),
              ],
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.06), color.withOpacity(0.02)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.15), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Dokunarak kopyala',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapCard(double latitude, double longitude) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, const Color(0xFF10B981).withOpacity(0.01)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF10B981).withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.map_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Harita Konumu',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      'Deprem merkezi görünümü',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: _isMapExpanded
                      ? const Color(0xFF10B981).withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _isMapExpanded = !_isMapExpanded;
                    });
                  },
                  icon: Icon(
                    _isMapExpanded ? Icons.fullscreen_exit : Icons.fullscreen,
                    color: const Color(0xFF6B7280),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                height: _isMapExpanded ? 280 : 180,
                child: Stack(
                  children: [
                    FlutterMap(
                      options: MapOptions(
                        center: LatLng(latitude, longitude),
                        zoom: _isMapExpanded ? 8 : 7,
                        maxZoom: 18,
                        minZoom: 3,
                        keepAlive: true,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains: const ['a', 'b', 'c'],
                          maxZoom: 19,
                          userAgentPackageName: 'com.depremtakip.app',
                          tileProvider: NetworkTileProvider(),
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(latitude, longitude),
                              width: 80,
                              height: 80,
                              child: AnimatedBuilder(
                                animation: _waveAnimation,
                                builder: (context, child) {
                                  return Center(
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Dalga halkaları
                                        for (int i = 0; i < 3; i++)
                                          AnimatedBuilder(
                                            animation: _waveAnimation,
                                            builder: (context, child) {
                                              final scale =
                                                  1.0 +
                                                  (i * 0.3) +
                                                  (_waveAnimation.value * 0.5);
                                              final opacity =
                                                  (1.0 - _waveAnimation.value) *
                                                  (1.0 - i * 0.3);
                                              return Transform.scale(
                                                scale: scale,
                                                child: Container(
                                                  width: 30,
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color:
                                                          _getMagnitudeColor(
                                                            widget
                                                                .earthquake
                                                                .mag,
                                                          ).withOpacity(
                                                            opacity.clamp(
                                                              0.0,
                                                              0.6,
                                                            ),
                                                          ),
                                                      width: 2,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        // Marker ikonu
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: _getMagnitudeColor(
                                              widget.earthquake.mag,
                                            ),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: _getMagnitudeColor(
                                                  widget.earthquake.mag,
                                                ).withOpacity(0.4),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.my_location_rounded,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, const Color(0xFFF59E0B).withOpacity(0.01)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFF59E0B).withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: const Color(0xFFF59E0B).withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.info_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Teknik Detaylar',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    'Deprem parametreleri',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDetailRow(
            'Derinlik',
            '${widget.earthquake.depth.toStringAsFixed(1)} km',
            Icons.vertical_align_bottom_rounded,
            const Color(0xFF7C3AED),
          ),
          _buildDetailRow(
            'Veri Sağlayıcı',
            widget.earthquake.provider.toUpperCase(),
            Icons.source_rounded,
            const Color(0xFF059669),
          ),
          _buildDetailRow(
            'Deprem ID',
            widget.earthquake.earthquakeId,
            Icons.fingerprint_rounded,
            const Color(0xFFDC2626),
          ),

          // En yakın havaalanı bilgisi
          if (_getNearestAirportInfo().isNotEmpty)
            _buildDetailRow(
              'En Yakın Havaalanı',
              _getNearestAirportInfo(),
              Icons.flight_rounded,
              const Color(0xFF2563EB),
            ),

          _buildDetailRow(
            'Koordinat Sistemi',
            'WGS84',
            Icons.public_rounded,
            const Color(0xFF2563EB),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.04), color.withOpacity(0.01)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard() {
    final dateTime = widget.earthquake.dateTime;
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    String timeAgo;
    if (difference.inDays > 0) {
      timeAgo = '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      timeAgo = '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      timeAgo = '${difference.inMinutes} dakika önce';
    } else {
      timeAgo = 'Az önce';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, const Color(0xFF8B5CF6).withOpacity(0.01)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Zaman Bilgileri',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    'Deprem tarihi ve süresi',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTimelineItem(
            'Deprem Zamanı',
            '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}',
            Icons.access_time_rounded,
            const Color(0xFF059669),
          ),
          const SizedBox(height: 14),
          _buildTimelineItem(
            'Geçen Süre',
            timeAgo,
            Icons.history_rounded,
            const Color(0xFFDC2626),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.04), color.withOpacity(0.01)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              'Bilgileri Paylaş',
              Icons.ios_share_rounded,
              const Color(0xFF3B82F6),
              () => _shareEarthquakeData(),
              isPrimary: true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              'Haritada Göster',
              Icons.map_rounded,
              const Color(0xFF10B981),
              () => _openInMap(),
              isPrimary: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    Function() onTap, {
    bool isPrimary = true,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        decoration: BoxDecoration(
          gradient: isPrimary
              ? LinearGradient(
                  colors: [color, color.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isPrimary ? null : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isPrimary
              ? null
              : Border.all(color: color.withOpacity(0.3), width: 1.5),
          boxShadow: [
            if (isPrimary)
              BoxShadow(
                color: color.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            BoxShadow(
              color: Colors.black.withOpacity(isPrimary ? 0.08 : 0.04),
              blurRadius: isPrimary ? 15 : 8,
              offset: Offset(0, isPrimary ? 6 : 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isPrimary ? Colors.white : color, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isPrimary ? Colors.white : color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openInMap() async {
    final coordinates = widget.earthquake.geojson['coordinates'] as List;
    final longitude = coordinates[0];
    final latitude = coordinates[1];

    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Harita açılamadı: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _shareEarthquakeData() async {
    try {
      final coordinates = widget.earthquake.geojson['coordinates'] as List;
      final longitude = coordinates[0];
      final latitude = coordinates[1];

      // Güvenli tarih formatlaması
      final dateTime = widget.earthquake.dateTime;
      final formattedDate =
          '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year}';
      final formattedTime =
          '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

      // Güzel formatlanmış paylaşım metni
      final shareText =
          '''🌍 Deprem Bilgileri

📍 Konum: ${widget.earthquake.title}
📊 Büyüklük: ${widget.earthquake.mag.toStringAsFixed(1)}
📏 Derinlik: ${widget.earthquake.depth.toStringAsFixed(1)} km
🌐 Koordinatlar: ${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}
⏰ Tarih: $formattedDate $formattedTime
🗺️ Harita: https://www.google.com/maps/search/?api=1&query=$latitude,$longitude

#Deprem #DepremTakip''';

      HapticFeedback.mediumImpact();

      // Doğrudan panoya kopyala - paylaşım dialog kullanma
      await Clipboard.setData(ClipboardData(text: shareText));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Deprem bilgileri panoya kopyalandı'),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Color(0xFF10B981),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Bilgiler kopyalanamadı'),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Color _getMagnitudeColor(double magnitude) {
    if (magnitude >= 7.0) return const Color(0xFF7F1D1D); // Very dark red
    if (magnitude >= 6.0) return const Color(0xFFDC2626); // Red
    if (magnitude >= 5.0) return const Color(0xFFEA580C); // Dark orange
    if (magnitude >= 4.0) return const Color(0xFFF59E0B); // Orange
    if (magnitude >= 3.0) return const Color(0xFF3B82F6); // Blue
    return const Color(0xFF10B981); // Green
  }

  String _getMagnitudeDescription(double magnitude) {
    if (magnitude >= 7.0) return 'Çok Büyük Deprem';
    if (magnitude >= 6.0) return 'Büyük Deprem';
    if (magnitude >= 5.0) return 'Orta Büyüklükte Deprem';
    if (magnitude >= 4.0) return 'Hafif Deprem';
    if (magnitude >= 3.0) return 'Zayıf Deprem';
    return 'Çok Zayıf Deprem';
  }

  // Helper method to get closest city information
  String _getClosestCityInfo() {
    try {
      // Önce location_properties'den en yakın şehri almaya çalış
      if (widget.earthquake.locationProperties.isNotEmpty &&
          widget.earthquake.locationProperties.containsKey('closestCity')) {
        final closestCity = widget.earthquake.locationProperties['closestCity'];
        if (closestCity != null && closestCity['name'] != null) {
          final distance = closestCity['distance'];
          final population = closestCity['population'];
          if (distance != null) {
            final distanceKm = (distance / 1000).round();
            String result = '${closestCity['name']} ($distanceKm km uzaklık)';
            if (population != null) {
              final populationStr = _formatPopulation(population);
              result += '\nNüfus: $populationStr';
            }
            return result;
          }
          return closestCity['name'].toString();
        }
      }

      // API'den gelen location_properties verisi yoksa title'dan çıkarmaya çalış
      if (widget.earthquake.title.contains('-')) {
        final parts = widget.earthquake.title.split('-');
        if (parts.length >= 2) {
          final cityPart = parts[1].trim();
          final cityName = cityPart.replaceAll(RegExp(r'\([^)]*\)'), '').trim();
          return cityName.isNotEmpty ? cityName : '';
        }
      }

      // Title'dan şehir bilgisini çıkarmaya çalış
      if (widget.earthquake.title.contains('(') &&
          widget.earthquake.title.contains(')')) {
        final startIndex = widget.earthquake.title.lastIndexOf('(');
        final endIndex = widget.earthquake.title.lastIndexOf(')');
        if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
          return widget.earthquake.title.substring(startIndex + 1, endIndex);
        }
      }

      return '';
    } catch (e) {
      return '';
    }
  }

  // Helper method to format population numbers
  String _formatPopulation(int population) {
    if (population >= 1000000) {
      return '${(population / 1000000).toStringAsFixed(1)}M';
    } else if (population >= 1000) {
      return '${(population / 1000).toStringAsFixed(0)}K';
    }
    return population.toString();
  }

  // Helper method to get nearest airport information
  String _getNearestAirportInfo() {
    try {
      if (widget.earthquake.locationProperties.isNotEmpty &&
          widget.earthquake.locationProperties.containsKey('airports')) {
        final airports = widget.earthquake.locationProperties['airports'];
        if (airports != null && airports is List && airports.isNotEmpty) {
          final nearestAirport = airports.first;
          if (nearestAirport != null && nearestAirport['name'] != null) {
            final distance = nearestAirport['distance'];
            final code = nearestAirport['code'];
            if (distance != null) {
              final distanceKm = (distance / 1000).round();
              String result = '${nearestAirport['name']}';
              if (code != null) {
                result += ' ($code)';
              }
              result += ' - $distanceKm km';
              return result;
            }
            return nearestAirport['name'].toString();
          }
        }
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  Widget _buildNearestCitiesCard() {
    if (widget.earthquake.locationProperties.isEmpty ||
        !widget.earthquake.locationProperties.containsKey('closestCities')) {
      return const SizedBox.shrink();
    }

    final closestCities = widget.earthquake.locationProperties['closestCities'];
    if (closestCities == null ||
        closestCities is! List ||
        closestCities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, const Color(0xFF8B5CF6).withOpacity(0.01)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.location_city_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'En Yakın Şehirler',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      'Deprem merkezine olan uzaklıklar',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...closestCities.take(5).map((city) => _buildCityItem(city)),
        ],
      ),
    );
  }

  Widget _buildCityItem(Map<String, dynamic> city) {
    final distance = city['distance'];
    final distanceKm = distance != null ? (distance / 1000).round() : 0;
    final population = city['population'];
    final populationStr = population != null
        ? _formatPopulation(population)
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF8FAFC),
            const Color(0xFF8B5CF6).withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.location_on,
              color: Color(0xFF8B5CF6),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  city['name']?.toString() ?? 'Bilinmiyor',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '$distanceKm km uzaklık',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    if (populationStr.isNotEmpty) ...[
                      const Text(
                        ' • ',
                        style: TextStyle(color: Color(0xFF6B7280)),
                      ),
                      Text(
                        'Nüfus: $populationStr',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
