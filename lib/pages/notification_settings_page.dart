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
    }

    setState(() {
      _notificationsEnabled = enabled;
    });

    await BackgroundEarthquakeService.setNotificationsEnabled(enabled);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          enabled
              ? 'Deprem bildirimleri açıldı'
              : 'Deprem bildirimleri kapatıldı',
        ),
        backgroundColor: enabled ? Colors.green : Colors.orange,
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
        content: Text(
          'Minimum büyüklük ${magnitude.toStringAsFixed(1)} olarak ayarlandı',
        ),
        backgroundColor: Colors.blue,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Bildirim Ayarları',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Bildirim Durumu'),
                  const SizedBox(height: 12),
                  _buildNotificationToggle(),
                  const SizedBox(height: 24),

                  _buildSectionTitle('Minimum Deprem Büyüklüğü'),
                  const SizedBox(height: 12),
                  _buildMagnitudeSettings(),
                  const SizedBox(height: 24),

                  _buildSectionTitle('Bildirim Hakkında'),
                  const SizedBox(height: 12),
                  _buildInfoCard(),
                  const SizedBox(height: 24),

                  _buildSectionTitle('Test Bildirimleri'),
                  const SizedBox(height: 12),
                  _buildTestButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1E293B),
      ),
    );
  }

  Widget _buildNotificationToggle() {
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _notificationsEnabled
                  ? Colors.green.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _notificationsEnabled
                  ? Icons.notifications_active
                  : Icons.notifications_off,
              color: _notificationsEnabled ? Colors.green : Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Deprem Bildirimleri',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _notificationsEnabled
                      ? 'Aktif - Depremler için bildirim alacaksınız'
                      : 'Pasif - Bildirim almayacaksınız',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _notificationsEnabled,
            onChanged: _updateNotificationSettings,
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildMagnitudeSettings() {
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
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.tune, color: Colors.blue, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bildirim Eşiği',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      'Bu değerin üzerindeki depremler için bildirim alın',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Minimum Büyüklük: ${_minimumMagnitude.toStringAsFixed(1)}',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.blue,
              inactiveTrackColor: Colors.blue.withOpacity(0.2),
              thumbColor: Colors.blue,
              overlayColor: Colors.blue.withOpacity(0.2),
              valueIndicatorColor: Colors.blue,
            ),
            child: Slider(
              value: _minimumMagnitude,
              min: 0.5,
              max: 5.0,
              divisions: 18,
              label: _minimumMagnitude.toStringAsFixed(1),
              onChanged: _notificationsEnabled
                  ? (value) => _updateMinimumMagnitude(value)
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0.5',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                ),
              ),
              Text(
                '5.0',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
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
                  Icons.info_outline,
                  color: Colors.orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Nasıl Çalışır?',
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
            '• Uygulama arka planda 15 dakikada bir deprem verilerini kontrol eder\n'
            '• Belirlediğiniz minimum büyüklük ve üzerindeki depremler için bildirim gönderilir\n'
            '• 4.0 ve üzeri depremler için her zaman özel bildirim alırsınız\n'
            '• Bildirimler Firebase kullanmadan, tamamen cihazınızda çalışır',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF64748B),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestButtons() {
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
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.science_outlined,
                  color: Colors.purple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Test Bildirimleri',
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
            'Farklı türdeki bildirim formatlarını test edin:',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _notificationsEnabled
                      ? _sendNormalTestNotification
                      : null,
                  icon: const Icon(Icons.notifications, size: 18),
                  label: const Text('Normal Deprem'),
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
                  onPressed: _notificationsEnabled
                      ? _sendCriticalTestNotification
                      : null,
                  icon: const Icon(Icons.warning, size: 18),
                  label: const Text('Büyük Deprem'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
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
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _notificationsEnabled
                  ? _sendBasicTestNotification
                  : null,
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: const Text('Basit Test Bildirimi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
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
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
