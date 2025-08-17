// ignore_for_file: unused_local_variable, deprecated_member_use

import 'package:deprem_takip/pages/login_page.dart';
import 'package:deprem_takip/pages/register_page.dart';
import 'package:deprem_takip/pages/son_depremler_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _slideController;
  late AnimationController _shimmerController;
  late AnimationController _floatingController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
        );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    _floatingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      _shimmerController.repeat();
    });
    _floatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _slideController.dispose();
    _shimmerController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo ve Başlık Bölümü
                  SlideTransition(
                    position: _slideAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: _buildHeader(),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Özellikler Bölümü
                  _buildFeaturesSection(),

                  const SizedBox(height: 40),

                  // Butonlar Bölümü
                  SlideTransition(
                    position: _slideAnimation,
                    child: _buildActionButtons(context),
                  ),

                  const SizedBox(height: 50),

                  // İstatistikler
                  _buildStatsSection(),

                  const SizedBox(height: 40),

                  // Bilgi Kartları
                  _buildInfoCards(),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Animated Logo Container with Floating Effect
        AnimatedBuilder(
          animation: _floatingAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _floatingAnimation.value * 8 - 4),
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(35),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFE0F2FE), // Açık mavi
                      Color(0xFFBAE6FD), // Açık mavi
                      Color(0xFF7DD3FC), // Açık mavi
                      Color(0xFF38BDF8), // Orta mavi
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF38BDF8).withOpacity(0.4),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      blurRadius: 15,
                      offset: const Offset(-5, -5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(35),
                  child: Stack(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFF0F9FF),
                              Color(0xFFE0F2FE),
                              Color(0xFFBAE6FD),
                            ],
                          ),
                        ),
                      ),
                      // Logo resmi
                      Positioned.fill(
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      // Shimmer efekti logo için
                      AnimatedBuilder(
                        animation: _shimmerAnimation,
                        builder: (context, child) {
                          return Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.transparent,
                                    Colors.white.withOpacity(0.1),
                                    Colors.white.withOpacity(0.3),
                                    Colors.white.withOpacity(0.1),
                                    Colors.transparent,
                                  ],
                                  stops: [
                                    0.0,
                                    (_shimmerAnimation.value - 0.3).clamp(
                                      0.0,
                                      1.0,
                                    ),
                                    _shimmerAnimation.value.clamp(0.0, 1.0),
                                    (_shimmerAnimation.value + 0.3).clamp(
                                      0.0,
                                      1.0,
                                    ),
                                    1.0,
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      // Parlaklık efekti
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.2),
                                Colors.transparent,
                                Colors.white.withOpacity(0.1),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 28),

        // Animasyonlu Ana Başlık
        AnimatedBuilder(
          animation: _shimmerAnimation,
          builder: (context, child) {
            return ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  colors: const [
                    Color(0xFF64748B),
                    Color(0xFF3B82F6),
                    Color(0xFF1E40AF),
                    Color(0xFF3B82F6),
                    Color(0xFF64748B),
                  ],
                  stops: [
                    0.0,
                    _shimmerAnimation.value - 0.3,
                    _shimmerAnimation.value,
                    _shimmerAnimation.value + 0.3,
                    1.0,
                  ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
                ).createShader(bounds);
              },
              child: Text(
                'Deprem Takip',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 12),

        // Alt başlık - KANDILLI referansı ile
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF3B82F6).withOpacity(0.1),
                const Color(0xFF1E40AF).withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF3B82F6).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Text(
            'Türkiye\'nin En Güvenilir Deprem İzleme Platformu',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: const Color(0xFF1E40AF),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesSection() {
    return AnimatedBuilder(
      animation: _slideAnimation,
      child: Column(
        children: [
          Text(
            'Platform Özellikleri',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildFeatureItem(
                  icon: Icons.notifications_active,
                  title: 'Anlık Bildirim',
                  description: 'Deprem anında hemen haberdar olun',
                  color: const Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFeatureItem(
                  icon: Icons.map,
                  title: 'Harita Görünümü',
                  description: 'Depremleri harita üzerinde görün',
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFeatureItem(
                  icon: Icons.analytics,
                  title: 'Detaylı Analiz',
                  description: 'Kapsamlı deprem raporları',
                  color: const Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFeatureItem(
                  icon: Icons.security,
                  title: 'Güvenli Veri',
                  description: 'KANDILLI kaynaklı güvenilir veriler',
                  color: const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
        ],
      ),
      builder: (context, child) {
        return SlideTransition(position: _slideAnimation, child: child);
      },
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatingAnimation.value * 3 - 1.5),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.8),
                  blurRadius: 8,
                  offset: const Offset(-2, -2),
                ),
              ],
              border: Border.all(color: color.withOpacity(0.1), width: 1),
            ),
            child: Column(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.2), width: 1),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsSection() {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_floatingAnimation.value * 5 + 2.5),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1E40AF),
                  Color(0xFF3B82F6),
                  Color(0xFF60A5FA),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withOpacity(0.4),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(-5, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Platform İstatistikleri',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem('24/7', 'Kesintisiz\nİzleme'),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    Expanded(
                      child: _buildStatItem('< 1dk', 'Bildirim\nSüresi'),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    Expanded(
                      child: _buildStatItem('KANDILLI', 'Resmi\nKaynak'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Hemen Başlayın',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hesabınızla giriş yapın veya yeni hesap oluşturun',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Ana Giriş Butonu
          _buildPrimaryButton(
            text: 'Giriş Yap',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            backgroundColor: const Color(0xFF3B82F6),
            textColor: Colors.white,
            icon: Icons.login_rounded,
          ),

          const SizedBox(height: 16),

          // Kayıt Butonu
          _buildSecondaryButton(
            text: 'Yeni Hesap Oluştur',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterPage()),
              );
            },
            icon: Icons.person_add_rounded,
          ),

          const SizedBox(height: 20),

          // Ayırıcı çizgi
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color: const Color(0xFF64748B).withOpacity(0.2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'veya',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  color: const Color(0xFF64748B).withOpacity(0.2),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Misafir Girişi
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SonDepremler()),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color: const Color(0xFF64748B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.visibility_rounded,
                    size: 20,
                    color: const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Giriş Yapmadan Devam Et',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color textColor,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 12),
            Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String text,
    required VoidCallback onPressed,
    required IconData icon,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: const Color(0xFF3B82F6)),
            const SizedBox(width: 12),
            Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF3B82F6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Neden Deprem Takip?',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 24),

        _buildInfoCard(
          title: 'Gerçek Zamanlı Deprem Verileri',
          description:
              'KANDILLI Rasathanesi\'nden gelen güncel verilerle Türkiye\'de meydana gelen tüm depremleri anlık olarak takip edin. Büyüklük, derinlik, konum ve zaman bilgilerini detaylı şekilde görüntüleyin.',
          icon: Icons.speed_rounded,
          gradient: const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
          ),
        ),

        const SizedBox(height: 20),

        _buildInfoCard(
          title: 'Akıllı Bildirim Sistemi',
          description:
              'Konum bazlı akıllı bildirimlerle size yakın bölgelerde meydana gelen depremleri anında öğrenin. Büyüklük ve mesafe filtrelerini ayarlayarak kişiselleştirilmiş uyarılar alın.',
          icon: Icons.notifications_active_rounded,
          gradient: const LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF059669)],
          ),
        ),

        const SizedBox(height: 20),

        _buildInfoCard(
          title: 'İnteraktif Harita Görünümü',
          description:
              'Depremleri interaktif harita üzerinde görselleştirin. Büyüklüğe göre renk kodlaması, filtreleme seçenekleri ve detaylı deprem bilgileriyle kapsamlı analiz yapın.',
          icon: Icons.map_rounded,
          gradient: const LinearGradient(
            colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
          ),
        ),

        const SizedBox(height: 20),

        _buildInfoCard(
          title: 'Güvenlik ve Gizlilik',
          description:
              'Verileriniz end-to-end şifreleme ile korunur. Kişisel bilgileriniz hiçbir zaman üçüncü taraflarla paylaşılmaz. KVKK uyumlu güvenli platform.',
          icon: Icons.security_rounded,
          gradient: const LinearGradient(
            colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
          ),
        ),

        const SizedBox(height: 30),

        // Footer Bilgi
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF3B82F6).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: const Color(0xFF3B82F6),
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                'Bilgi',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bu uygulama deprem riskini azaltmak veya deprem tahmininde bulunmak için tasarlanmamıştır. Sadece gerçekleşen depremleri izlemek ve bilgilendirmek amacıyla geliştirilmiştir.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF64748B),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String description,
    required IconData icon,
    required LinearGradient gradient,
  }) {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatingAnimation.value * 2 - 1),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.9),
                  blurRadius: 10,
                  offset: const Offset(-3, -3),
                ),
              ],
              border: Border.all(
                color: gradient.colors.first.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: gradient,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: gradient.colors.first.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(icon, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      height: 1.6,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
