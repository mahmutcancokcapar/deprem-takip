// ignore_for_file: deprecated_member_use

import 'package:deprem_takip/pages/profile_page.dart';
import 'package:flutter/material.dart';

import 'acil_durum_aramalari.dart';
import 'belli_noktalar.dart';
import 'son_depremler_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _navAnimationController;
  late Animation<double> _navScaleAnimation;

  final List<NavItem> _navItems = [
    NavItem(
      icon: Icons.waves,
      activeIcon: Icons.waves,
      color: const Color(0xFF3B82F6),
    ),
    NavItem(
      icon: Icons.location_on_outlined,
      activeIcon: Icons.location_on,
      color: const Color(0xFF10B981),
    ),
    NavItem(
      icon: Icons.phone_outlined,
      activeIcon: Icons.phone,
      color: const Color(0xFFEF4444),
    ),
    NavItem(
      icon: Icons.person_2_outlined,
      activeIcon: Icons.person_2,
      color: const Color.fromARGB(255, 173, 239, 68),
    ),
  ];

  final List<Widget> _pages = [
    const SonDepremler(),
    const BelliNoktalar(),
    const AcilDurumAramalari(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _navAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _navScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _navAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _animationController.forward();
    _navAnimationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _navAnimationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Stack(
        children: [
          // Main Content
          FadeTransition(
            opacity: _fadeAnimation,
            child: _pages[_selectedIndex],
          ),

          // Custom Bottom Navigation Bar
          Positioned(
            left: 20,
            right: 20,
            bottom: 10,
            child: ScaleTransition(
              scale: _navScaleAnimation,
              child: _buildCustomBottomNav(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomBottomNav() {
    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_navItems.length, (index) {
            return _buildNavItem(index);
          }),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = _navItems[index];
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? item.color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? item.color : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isSelected ? item.activeIcon : item.icon,
                color: isSelected ? Colors.white : const Color(0xFF6B7280),
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final Color color;

  NavItem({required this.icon, required this.activeIcon, required this.color});
}
