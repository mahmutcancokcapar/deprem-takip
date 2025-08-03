// ignore_for_file: unused_local_variable, deprecated_member_use

import 'package:deprem_takip/pages/login_page.dart';
import 'package:deprem_takip/pages/register_page.dart';
import 'package:deprem_takip/pages/son_depremler_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      extendBodyBehindAppBar: true,
      appBar: AppBar(),
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
                  _buildHeader(),

                  const SizedBox(height: 50),

                  // Butonlar Bölümü
                  _buildActionButtons(context),

                  const SizedBox(height: 60),

                  // Bilgi Kartları
                  _buildInfoCards(),

                  const SizedBox(height: 40),
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
        // Logo Container
        SizedBox(
          width: 120,
          height: 120,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
          ),
        ),

        const SizedBox(height: 24),

        // Başlık
        Text(
          'Deprem Takip',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 8),

        // Alt başlık
        Text(
          'Türkiye\'nin deprem izleme platformu',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
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
          icon: Icons.login,
        ),

        const SizedBox(height: 16),

        // Kayıt Butonu
        _buildSecondaryButton(
          text: 'Kayıt Ol',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegisterPage()),
            );
          },
          icon: Icons.person_add,
        ),

        const SizedBox(height: 12),

        // Misafir Girişi
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SonDepremler()),
            );
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.visibility, size: 20, color: Color(0xFF64748B)),
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
      ],
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
      children: [
        _buildInfoCard(
          title: 'Deprem Takip Nedir?',
          description:
              'Türkiye\'de meydana gelen depremleri takip etmenizi sağlayan modern bir platformdur. Anlık bildirimler, detaylı raporlar ve kullanıcı dostu arayüzü ile depremler hakkında güncel bilgi sahibi olabilirsiniz.',
          icon: Icons.info_outline,
          gradient: const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
          ),
        ),

        const SizedBox(height: 20),

        _buildInfoCard(
          title: 'Kayıt Olma Avantajları',
          description:
              'Kayıt olarak depremler hakkında anlık bildirimler alabilir, detaylı raporları inceleyebilir ve uygulamanın tüm özelliklerinden faydalanabilirsiniz. Kişisel ayarlarınızı yönetebilir ve özelleştirilmiş deneyim yaşayabilirsiniz.',
          icon: Icons.star_outline,
          gradient: const LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF059669)],
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
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
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
    );
  }
}
