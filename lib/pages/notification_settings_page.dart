// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/background_earthquake_service.dart';
import '../services/notification_service.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _notificationsEnabled = false;
  double _minimumMagnitude = 1.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final enabled =
          await BackgroundEarthquakeService.areNotificationsEnabled();
      final magnitude = await BackgroundEarthquakeService.getMinimumMagnitude();

      setState(() {
        _notificationsEnabled = enabled;
        _minimumMagnitude = magnitude;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateNotificationSettings(bool enabled) async {
    if (enabled) {
      // İlk olarak bildirim izni iste
      await NotificationService.requestPermission();
      final hasPermission = await NotificationService.areNotificationsEnabled();

      if (!hasPermission) {
        _showPermissionDialog();
        return;
      }

      // Pil optimizasyonu uyarısı göster
      _showBatteryOptimizationDialog();
    }

    setState(() {
      _notificationsEnabled = enabled;
    });

    await BackgroundEarthquakeService.setNotificationsEnabled(enabled);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                enabled
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_off_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                enabled
                    ? 'Deprem bildirimleri açıldı. Arka plan servisi başlatılıyor...'
                    : 'Deprem bildirimleri kapatıldı',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: enabled
            ? const Color(0xFF10B981)
            : const Color(0xFFF59E0B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: Duration(seconds: enabled ? 4 : 2),
        elevation: 8,
      ),
    );
  }

  Future<void> _updateMinimumMagnitude(double magnitude) async {
    setState(() {
      _minimumMagnitude = magnitude;
    });

    await BackgroundEarthquakeService.setMinimumMagnitude(magnitude);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.tune_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Minimum büyüklük ${magnitude.toStringAsFixed(1)} olarak ayarlandı',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF3B82F6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        elevation: 8,
      ),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bildirim İzni Gerekli'),
          content: const Text(
            'Deprem bildirimlerini alabilmek için uygulama ayarlarından bildirim iznini açmanız gerekiyor.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tamam'),
            ),
          ],
        );
      },
    );
  }

  void _showBatteryOptimizationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('⚡ Önemli: Pil Optimizasyonu'),
          content: const Text(
            'Uygulama kapalıyken deprem bildirimlerini alabilmek için:\n\n'
            '1. Cihaz Ayarları → Pil → Uygulama optimizasyonu\n'
            '2. "Deprem Takip" uygulamasını bulun\n'
            '3. "Optimize etme" seçeneğini seçin\n\n'
            'Bu işlem yapılmazsa bildirimlerin gecikmesi ya da hiç gelmemesi mümkündür.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Anladım'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showBatteryOptimizationSteps();
              },
              child: const Text('Nasıl Yapılır?'),
            ),
          ],
        );
      },
    );
  }

  void _showBatteryOptimizationSteps() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('📱 Adım Adım Rehber'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Samsung Cihazlar için:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text(
                  '• Ayarlar → Cihaz bakımı → Pil → Uygulama güç yönetimi\n'
                  '• "Deprem Takip" → "Optimize edilmedi"\n\n',
                ),
                const Text(
                  'Xiaomi/MIUI için:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text(
                  '• Ayarlar → Uygulamalar → Uygulama yöneticisi\n'
                  '• "Deprem Takip" → Pil tasarrufu → "Kısıtlama yok"\n\n',
                ),
                const Text(
                  'Huawei için:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text(
                  '• Ayarlar → Pil → Uygulama başlatma\n'
                  '• "Deprem Takip" → Manuel yönetim → Tüm seçenekleri açın\n\n',
                ),
                const Text(
                  'Genel Android:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text(
                  '• Ayarlar → Pil → Pil optimizasyonu\n'
                  '• "Deprem Takip" → "Optimize etme"',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tamam'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9FC),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF1E293B),
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bildirim Ayarları',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
                height: 1.2,
              ),
            ),
            Text(
              'Deprem bildirimlerinizi özelleştirin',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
                height: 1.2,
              ),
            ),
          ],
        ),
        toolbarHeight: 80,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _buildNotificationToggle(),
                  const SizedBox(height: 20),
                  _buildMagnitudeSettings(),
                  const SizedBox(height: 20),
                  _buildInfoCard(),
                  const SizedBox(height: 20),
                  _buildTestButtons(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildNotificationToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _notificationsEnabled
                              ? [
                                  const Color(0xFF10B981),
                                  const Color(0xFF059669),
                                ]
                              : [
                                  const Color(0xFF9CA3AF),
                                  const Color(0xFF6B7280),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (_notificationsEnabled
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFF9CA3AF))
                                    .withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        _notificationsEnabled
                            ? Icons.notifications_active_rounded
                            : Icons.notifications_off_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Deprem Bildirimleri',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _notificationsEnabled
                                ? 'Aktif • Deprem bildirimlerini alacaksınız'
                                : 'Pasif • Bildirim almayacaksınız',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _notificationsEnabled
                          ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                          : [const Color(0xFF2563EB), const Color(0xFF1D4ED8)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (_notificationsEnabled
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFF2563EB))
                                .withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () =>
                          _updateNotificationSettings(!_notificationsEnabled),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _notificationsEnabled
                                  ? Icons.power_settings_new_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _notificationsEnabled
                                  ? 'Bildirimleri Kapat'
                                  : 'Bildirimleri Aç',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_notificationsEnabled)
            Container(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF10B981).withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF10B981),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Bildirimler aktif! Arka plan kontrolü başlatıldı.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF059669),
                        ),
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

  Widget _buildMagnitudeSettings() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3B82F6).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bildirim Eşiği',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Bu değerin üzerindeki depremler için bildirim alın',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Minimum Büyüklük',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF374151),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _getMagnitudeGradientColors(
                                  _minimumMagnitude,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: _getMagnitudeGradientColors(
                                    _minimumMagnitude,
                                  )[0].withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              _minimumMagnitude.toStringAsFixed(1),
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: _getMagnitudeGradientColors(
                            _minimumMagnitude,
                          )[0],
                          inactiveTrackColor: const Color(0xFFE2E8F0),
                          thumbColor: _getMagnitudeGradientColors(
                            _minimumMagnitude,
                          )[0],
                          overlayColor: _getMagnitudeGradientColors(
                            _minimumMagnitude,
                          )[0].withOpacity(0.2),
                          valueIndicatorColor: _getMagnitudeGradientColors(
                            _minimumMagnitude,
                          )[0],
                          trackHeight: 6,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 12,
                            elevation: 4,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 20,
                          ),
                        ),
                        child: Slider(
                          value: _minimumMagnitude,
                          min: 0.5,
                          max: 5.0,
                          divisions: 18,
                          onChanged: _notificationsEnabled
                              ? (value) => _updateMinimumMagnitude(value)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildMagnitudeLabel('0.5', 'Minimum'),
                          _buildMagnitudeLabel('2.5', 'Hafif'),
                          _buildMagnitudeLabel('5.0', 'Güçlü'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getMagnitudeInfoColor(
                      _minimumMagnitude,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getMagnitudeInfoColor(
                        _minimumMagnitude,
                      ).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: _getMagnitudeInfoColor(_minimumMagnitude),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _getMagnitudeDescription(_minimumMagnitude),
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: _getMagnitudeInfoColor(_minimumMagnitude),
                            height: 1.4,
                          ),
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

  Widget _buildMagnitudeLabel(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF9CA3AF),
          ),
        ),
      ],
    );
  }

  List<Color> _getMagnitudeGradientColors(double magnitude) {
    if (magnitude < 2.0) {
      return [const Color(0xFF10B981), const Color(0xFF059669)];
    } else if (magnitude < 3.0) {
      return [const Color(0xFFF59E0B), const Color(0xFFD97706)];
    } else if (magnitude < 4.0) {
      return [const Color(0xFFEF4444), const Color(0xFFDC2626)];
    } else {
      return [const Color(0xFF7C3AED), const Color(0xFF6D28D9)];
    }
  }

  Color _getMagnitudeInfoColor(double magnitude) {
    if (magnitude < 2.0) {
      return const Color(0xFF059669);
    } else if (magnitude < 3.0) {
      return const Color(0xFFD97706);
    } else if (magnitude < 4.0) {
      return const Color(0xFFDC2626);
    } else {
      return const Color(0xFF6D28D9);
    }
  }

  String _getMagnitudeDescription(double magnitude) {
    if (magnitude < 2.0) {
      return 'Çok hassas ayar - Küçük depremler bile bildirilecek';
    } else if (magnitude < 3.0) {
      return 'Orta hassasiyet - Hissedilebilir depremler bildirilecek';
    } else if (magnitude < 4.0) {
      return 'Dikkat seviyesi - Önemli depremler bildirilecek';
    } else {
      return 'Kritik seviye - Sadece büyük depremler bildirilecek';
    }
  }

  Widget _buildInfoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.lightbulb_outline_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nasıl Çalışır?',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Bildirim sisteminin detayları',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...[
              _buildInfoItem(
                Icons.schedule_rounded,
                'Otomatik Kontrol',
                'Uygulama arka planda 15 dakikada bir deprem verilerini kontrol eder',
                const Color(0xFF3B82F6),
              ),
              _buildInfoItem(
                Icons.filter_alt_rounded,
                'Akıllı Filtreleme',
                'Belirlediğiniz minimum büyüklük ve üzerindeki depremler için bildirim gönderilir',
                const Color(0xFF10B981),
              ),
              _buildInfoItem(
                Icons.priority_high_rounded,
                'Kritik Uyarılar',
                '4.0 ve üzeri depremler için her zaman özel bildirim alırsınız',
                const Color(0xFFEF4444),
              ),
              _buildInfoItem(
                Icons.power_rounded,
                'Sürekli Çalışma',
                'Uygulama kapalıyken bile bildirimler gelir (pil optimizasyonu kapatılmalı)',
                const Color(0xFF8B5CF6),
              ),
              _buildInfoItem(
                Icons.refresh_rounded,
                'Otomatik Başlatma',
                'Cihaz yeniden başladığında otomatik olarak tekrar çalışmaya başlar',
                const Color(0xFF06B6D4),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.science_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Test Bildirimleri',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Farklı türdeki bildirim formatlarını test edin',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (!_notificationsEnabled)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: const Color(0xFFD97706),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Test butonları için önce bildirimleri açmanız gerekiyor',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFD97706),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              _buildTestButton(
                'Basit Test',
                Icons.check_circle_outline_rounded,
                const Color(0xFF10B981),
                _sendBasicTestNotification,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTestButton(
                      'Normal\nDeprem',
                      Icons.notifications_rounded,
                      const Color(0xFF3B82F6),
                      _sendNormalTestNotification,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTestButton(
                      'Büyük\nDeprem',
                      Icons.warning_rounded,
                      const Color(0xFFEF4444),
                      _sendCriticalTestNotification,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sendBasicTestNotification() async {
    try {
      await NotificationService.showEarthquakeNotification(
        title: '🧪 Test Bildirimi',
        body: 'Bu bir test bildirimidir. Deprem bildirimleri düzgün çalışıyor!',
        magnitude: 2.5,
        location: 'Test Konumu',
      );

      _showSuccessMessage('Basit test bildirimi gönderildi!');
    } catch (e) {
      _showErrorMessage('Test bildirimi gönderilemedi: $e');
    }
  }

  Future<void> _sendNormalTestNotification() async {
    try {
      await BackgroundEarthquakeService.sendTestNotification();
      _showSuccessMessage('Normal deprem test bildirimi gönderildi!');
    } catch (e) {
      _showErrorMessage('Normal test bildirimi gönderilemedi: $e');
    }
  }

  Future<void> _sendCriticalTestNotification() async {
    try {
      await BackgroundEarthquakeService.sendCriticalTestNotification();
      _showSuccessMessage('Büyük deprem test bildirimi gönderildi!');
    } catch (e) {
      _showErrorMessage('Kritik test bildirimi gönderilemedi: $e');
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        elevation: 8,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.error_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        elevation: 8,
      ),
    );
  }

  /*Widget _buildDebugButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.bug_report,
                  color: Colors.orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Debug & Manuel Kontrol',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Arka plan servisini manuel olarak test edin:',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _notificationsEnabled
                  ? _manualEarthquakeCheck
                  : null,
              icon: const Icon(Icons.search, size: 18),
              label: const Text('Manuel Deprem Kontrolü'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _notificationsEnabled
                      ? _restartBackgroundService
                      : null,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Servisi Yeniden Başlat'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showDebugInfo,
                  icon: const Icon(Icons.info, size: 18),
                  label: const Text('Debug Bilgisi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }*/

  /*Future<void> _manualEarthquakeCheck() async {
    try {
      _showSuccessMessage('Manuel kontrol başlatıldı...');
      
      // Debug logları console'da görünecek
      await BackgroundEarthquakeService.checkForNewEarthquakes();
      
      _showSuccessMessage('Manuel kontrol tamamlandı! Debug loglarını console\'da kontrol edin.');
    } catch (e) {
      _showErrorMessage('Manuel kontrol hatası: $e');
    }
  }*/

  /*Future<void> _restartBackgroundService() async {
    try {
      // Önce servisi durdur
      await BackgroundEarthquakeService.stopPeriodicCheck();
      
      // Kısa bir bekleme
      await Future.delayed(const Duration(seconds: 2));
      
      // Tekrar başlat
      await BackgroundEarthquakeService.startPeriodicCheck();
      
      _showSuccessMessage('Arka plan servisi yeniden başlatıldı!');
    } catch (e) {
      _showErrorMessage('Servis yeniden başlatılamadı: $e');
    }
  }*/

  /*void _showDebugInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Debug Bilgisi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Bildirimler: ${_notificationsEnabled ? "Açık" : "Kapalı"}'),
            Text('• Minimum büyüklük: ${_minimumMagnitude.toStringAsFixed(1)}'),
            const Text('• Kontrol aralığı: 15 dakika'),
            const Text('• Debug logları console\'da görünür'),
            const SizedBox(height: 16),
            const Text(
              'Sorun yaşıyorsanız:\n'
              '1. Test bildirimlerini deneyin\n'
              '2. Manuel kontrolü çalıştırın\n'
              '3. Servisi yeniden başlatın\n'
              '4. Cihaz ayarlarından pil optimizasyonunu kapatın',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }*/
}
