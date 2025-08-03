// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Settings Variables
  bool notificationsEnabled = true;
  bool soundEnabled = true;
  bool vibrationEnabled = true;
  bool locationEnabled = true;
  bool darkModeEnabled = false;
  bool autoUpdateEnabled = true;
  bool emergencyAlertsEnabled = true;

  double magnitudeThreshold = 3.0;
  double distanceThreshold = 50.0;

  String selectedLanguage = 'Türkçe';
  String selectedTheme = 'Açık';
  String updateFrequency = '1 dakika';

  final List<String> languages = ['Türkçe', 'English', 'العربية'];
  final List<String> themes = ['Açık', 'Koyu', 'Sistem'];
  final List<String> updateFrequencies = [
    '30 saniye',
    '1 dakika',
    '5 dakika',
    '10 dakika',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Ayarlar',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF673AB7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore, color: Colors.white),
            onPressed: _showResetDialog,
            tooltip: 'Varsayılana Sıfırla',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF673AB7), Color(0xFF9C27B0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.settings,
                        size: 40,
                        color: Color(0xFF673AB7),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Uygulama Ayarları',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Deprem Takip deneyiminizi kişiselleştirin',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Bildirimler
              _buildSettingsSection(
                title: 'Bildirimler',
                icon: Icons.notifications,
                color: const Color(0xFFFF9800),
                children: [
                  _buildSwitchTile(
                    title: 'Bildirimler',
                    subtitle: 'Deprem uyarılarını al',
                    value: notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        notificationsEnabled = value;
                      });
                    },
                  ),
                  _buildSwitchTile(
                    title: 'Ses',
                    subtitle: 'Bildirim sesi çal',
                    value: soundEnabled,
                    onChanged: notificationsEnabled
                        ? (value) {
                            setState(() {
                              soundEnabled = value;
                            });
                          }
                        : null,
                  ),
                  _buildSwitchTile(
                    title: 'Titreşim',
                    subtitle: 'Bildirimde titret',
                    value: vibrationEnabled,
                    onChanged: notificationsEnabled
                        ? (value) {
                            setState(() {
                              vibrationEnabled = value;
                            });
                          }
                        : null,
                  ),
                  _buildSwitchTile(
                    title: 'Acil Uyarılar',
                    subtitle: 'Büyük depremler için özel uyarı',
                    value: emergencyAlertsEnabled,
                    onChanged: (value) {
                      setState(() {
                        emergencyAlertsEnabled = value;
                      });
                    },
                  ),
                ],
              ),

              // Deprem Filtreleri
              _buildSettingsSection(
                title: 'Deprem Filtreleri',
                icon: Icons.tune,
                color: const Color(0xFFE91E63),
                children: [
                  _buildSliderTile(
                    title: 'Minimum Büyüklük',
                    subtitle:
                        '${magnitudeThreshold.toStringAsFixed(1)} ve üzeri depremler',
                    value: magnitudeThreshold,
                    min: 1.0,
                    max: 7.0,
                    divisions: 12,
                    onChanged: (value) {
                      setState(() {
                        magnitudeThreshold = value;
                      });
                    },
                  ),
                  _buildSliderTile(
                    title: 'Maksimum Mesafe',
                    subtitle: '${distanceThreshold.toInt()} km yarıçapında',
                    value: distanceThreshold,
                    min: 10.0,
                    max: 500.0,
                    divisions: 49,
                    onChanged: locationEnabled
                        ? (value) {
                            setState(() {
                              distanceThreshold = value;
                            });
                          }
                        : null,
                  ),
                  _buildDropdownTile(
                    title: 'Güncelleme Sıklığı',
                    subtitle: 'Veri güncelleme aralığı',
                    value: updateFrequency,
                    items: updateFrequencies,
                    onChanged: (value) {
                      setState(() {
                        updateFrequency = value!;
                      });
                    },
                  ),
                ],
              ),

              // Konum ve Harita
              _buildSettingsSection(
                title: 'Konum ve Harita',
                icon: Icons.location_on,
                color: const Color(0xFF4CAF50),
                children: [
                  _buildSwitchTile(
                    title: 'Konum İzni',
                    subtitle: 'Yakın depremler için gerekli',
                    value: locationEnabled,
                    onChanged: (value) {
                      setState(() {
                        locationEnabled = value;
                        if (!value) {
                          // Konum kapatıldığında mesafe filtresi de devre dışı kalır
                        }
                      });
                    },
                  ),
                  _buildSwitchTile(
                    title: 'Otomatik Güncelleme',
                    subtitle: 'Harita verilerini otomatik güncelle',
                    value: autoUpdateEnabled,
                    onChanged: (value) {
                      setState(() {
                        autoUpdateEnabled = value;
                      });
                    },
                  ),
                ],
              ),

              // Görünüm
              _buildSettingsSection(
                title: 'Görünüm',
                icon: Icons.palette,
                color: const Color(0xFF2196F3),
                children: [
                  _buildDropdownTile(
                    title: 'Tema',
                    subtitle: 'Uygulama görünümü',
                    value: selectedTheme,
                    items: themes,
                    onChanged: (value) {
                      setState(() {
                        selectedTheme = value!;
                        darkModeEnabled = value == 'Koyu';
                      });
                    },
                  ),
                  _buildDropdownTile(
                    title: 'Dil',
                    subtitle: 'Uygulama dili',
                    value: selectedLanguage,
                    items: languages,
                    onChanged: (value) {
                      setState(() {
                        selectedLanguage = value!;
                      });
                    },
                  ),
                ],
              ),
              // Tehlikeli Alanlar
              _buildSettingsSection(
                title: 'Tehlikeli İşlemler',
                icon: Icons.warning,
                color: const Color(0xFFF44336),
                children: [
                  _buildNavigationTile(
                    title: 'Verileri Sıfırla',
                    subtitle: 'Tüm ayarları varsayılana döndür',
                    icon: Icons.restore,
                    onTap: () => _showResetDialog(),
                    isDestructive: true,
                  ),
                  _buildNavigationTile(
                    title: 'Hesabı Sil',
                    subtitle: 'Hesabı kalıcı olarak sil',
                    icon: Icons.delete_forever,
                    onTap: () => _showDeleteAccountDialog(),
                    isDestructive: true,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Version Info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    Icon(Icons.smartphone, color: Colors.grey[600], size: 32),
                    const SizedBox(height: 12),
                    const Text(
                      'Deprem Takip',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sürüm 1.0.0 (Build 100)',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'MC MEDYA © ${DateTime.now().year}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: onChanged == null ? Colors.grey[400] : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: onChanged == null ? Colors.grey[400] : Colors.grey[600],
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF673AB7),
      ),
    );
  }

  Widget _buildSliderTile({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: onChanged == null ? Colors.grey[400] : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: onChanged == null ? Colors.grey[400] : Colors.grey[600],
              fontSize: 12,
            ),
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
            activeColor: const Color(0xFF673AB7),
            inactiveColor: Colors.grey[300],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String subtitle,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
      trailing: DropdownButton<String>(
        value: value,
        items: items.map((String item) {
          return DropdownMenuItem<String>(value: item, child: Text(item));
        }).toList(),
        onChanged: onChanged,
        underline: Container(),
      ),
    );
  }

  Widget _buildNavigationTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red[600] : Colors.grey[600],
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDestructive ? Colors.red[600] : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDestructive ? Colors.red[400] : Colors.grey[600],
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: isDestructive ? Colors.red[400] : Colors.grey[400],
      ),
      onTap: onTap,
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange[600]),
            const SizedBox(width: 12),
            const Text('Ayarları Sıfırla'),
          ],
        ),
        content: const Text(
          'Tüm ayarlar varsayılan değerlere döndürülecek. Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              _resetSettings();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('Sıfırla'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red[600]),
            const SizedBox(width: 12),
            const Text('Hesabı Sil'),
          ],
        ),
        content: const Text(
          'Hesabınız kalıcı olarak silinecek. Bu işlem geri alınamaz. Devam etmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Hesap silme işlemi başlatıldı...'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _resetSettings() {
    setState(() {
      notificationsEnabled = true;
      soundEnabled = true;
      vibrationEnabled = true;
      locationEnabled = true;
      darkModeEnabled = false;
      autoUpdateEnabled = true;
      emergencyAlertsEnabled = true;
      magnitudeThreshold = 3.0;
      distanceThreshold = 50.0;
      selectedLanguage = 'Türkçe';
      selectedTheme = 'Açık';
      updateFrequency = '1 dakika';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ayarlar varsayılan değerlere döndürüldü')),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
