// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:deprem_takip/services/directory_service.dart';
import 'package:deprem_takip/services/storage_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AcilDurumAramalari extends StatefulWidget {
  const AcilDurumAramalari({super.key});

  @override
  State<AcilDurumAramalari> createState() => _AcilDurumAramalariState();
}

class _AcilDurumAramalariState extends State<AcilDurumAramalari> {
  static const Color _backgroundColor = Color(0xFFF8FAFC);
  static const Color _primaryRed = Color(0xFFEF4444);
  static const Color _darkRed = Color(0xFFDC2626);
  static const Color _primaryBlue = Color(0xFF3B82F6);
  static const Color _cyan = Color(0xFF06B6D4);
  static const Color _darkCyan = Color(0xFF0891B2);
  static const Color _textPrimary = Color(0xFF1E293B);
  static const Color _textSecondary = Color(0xFF475569);
  static const Color _cardGray = Color(0xFF64748B);

  List<Contact> contacts = [];
  Contact? selectedContact;
  DirectoryService? directoryService;
  bool isLoadingContacts = false;

  final List<Map<String, dynamic>> _emergencyServices = [
    {
      'name': 'İlk Yardım',
      'number': '112',
      'icon': Icons.medical_services,
      'isPrimary': true,
    },
    {
      'name': 'AFAD',
      'number': '122',
      'icon': Icons.security,
      'isPrimary': false,
    },
    {
      'name': 'İtfaiye',
      'number': '110',
      'icon': Icons.fire_truck,
      'isPrimary': false,
    },
    {
      'name': 'Polis',
      'number': '155',
      'icon': Icons.local_police,
      'isPrimary': false,
    },
    {
      'name': 'Jandarma',
      'number': '156',
      'icon': Icons.shield,
      'isPrimary': false,
    },
    {
      'name': 'Doğalgaz',
      'number': '187',
      'icon': Icons.gas_meter,
      'isPrimary': false,
    },
    {
      'name': 'Orman Yangını',
      'number': '177',
      'icon': Icons.forest,
      'isPrimary': false,
    },
    {
      'name': 'Zehir Danışma',
      'number': '114',
      'icon': Icons.healing,
      'isPrimary': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    final token = await StorageService.getToken();
    if (token != null) {
      directoryService = DirectoryService(token: token);
      await _loadContacts();
    }
  }

  Future<void> _loadContacts() async {
    if (directoryService == null) return;

    setState(() {
      isLoadingContacts = true;
    });

    try {
      final result = await directoryService!.getContacts();
      if (result['success'] && mounted) {
        final List<dynamic> contactsData = result['contacts'] ?? [];
        setState(() {
          contacts = contactsData
              .map(
                (contact) => Contact(
                  id: contact['id'],
                  name: contact['name'],
                  phone: contact['phone'],
                  isDefault: contact['default'] ?? false,
                ),
              )
              .toList();

          // Varsayılan kişiyi otomatik seç
          selectedContact = contacts.firstWhere(
            (contact) => contact.isDefault,
            orElse: () => contacts.isNotEmpty
                ? contacts.first
                : Contact(id: -1, name: '', phone: '', isDefault: false),
          );

          if (selectedContact?.id == -1) {
            selectedContact = null;
          }

          isLoadingContacts = false;
        });
      } else {
        setState(() {
          isLoadingContacts = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingContacts = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEmergencyHeader(),
              const SizedBox(height: 20),
              _buildInfoCard(),
              const SizedBox(height: 24),
              _buildSectionTitle('Acil Durum Numaraları'),
              const SizedBox(height: 16),
              _buildEmergencyGrid(),
              const SizedBox(height: 24),
              _buildQuickAccessCard(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _primaryRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.phone, color: _primaryRed, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            'Acil Durum',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_primaryRed, _darkRed],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primaryRed.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.emergency, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Acil Durumda',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Hızlı ve güvenli arama yapın',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _primaryBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _primaryBlue.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.info_outline,
              color: _primaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tüm acil durum numaraları artık 112\'de birleştirilmiştir. Ancak özel durumlar için aşağıdaki numaraları da kullanabilirsiniz.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: _textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: _textPrimary,
      ),
    );
  }

  Widget _buildEmergencyGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: _emergencyServices.length,
      itemBuilder: (context, index) {
        final service = _emergencyServices[index];
        return _buildEmergencyCard(
          service['name'] as String,
          service['number'] as String,
          service['icon'] as IconData,
          service['isPrimary'] as bool,
        );
      },
    );
  }

  Widget _buildEmergencyCard(
    String name,
    String number,
    IconData icon,
    bool isPrimary,
  ) {
    final cardColor = isPrimary ? _primaryRed : _cardGray;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: isPrimary
            ? Border.all(color: _primaryRed.withOpacity(0.2), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: isPrimary
                ? _primaryRed.withOpacity(0.1)
                : Colors.black.withOpacity(0.04),
            blurRadius: isPrimary ? 20 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _makePhoneCall(number),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, color: cardColor, size: 28),
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    number,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: cardColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccessCard() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: _showEmergencyContactsModal,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_cyan, _darkCyan],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _cyan.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.dialer_sip,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hızlı Erişim',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Buradan rehberine eklediğiniz herhangi bir kullanıcıya konumunuzla birlikte direkt olarak acil durum mesajı gönderebilirsiniz.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEmergencyContactsModal() {
    if (contacts.isEmpty) {
      _showErrorMessage('Rehberinizde kayıtlı kişi bulunamadı');
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _primaryRed.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.emergency, color: _primaryRed, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Acil Durum Mesajı Gönder',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Acil durum mesajı göndermek istediğiniz kişiyi seçin:',
                  style: GoogleFonts.inter(fontSize: 14, color: _textSecondary),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    final contact = contacts[index];
                    final isSelected = selectedContact?.id == contact.id;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _primaryRed.withOpacity(0.1)
                            : Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(color: _primaryRed, width: 2)
                            : Border.all(color: Colors.grey[200]!),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: contact.isDefault
                              ? const Color(0xFF4CAF50)
                              : _cardGray,
                          child: Text(
                            contact.name.isNotEmpty
                                ? contact.name[0].toUpperCase()
                                : 'K',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                contact.name,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? _primaryRed
                                      : _textPrimary,
                                ),
                              ),
                            ),
                            if (contact.isDefault)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4CAF50),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'VARSAYıLAN',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Text(
                          contact.phone,
                          style: GoogleFonts.inter(
                            color: isSelected
                                ? _primaryRed.withOpacity(0.8)
                                : _textSecondary,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check_circle, color: _primaryRed)
                            : const Icon(
                                Icons.radio_button_unchecked,
                                color: Colors.grey,
                              ),
                        onTap: () {
                          setModalState(() {
                            selectedContact = contact;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: selectedContact != null
                            ? () {
                                Navigator.pop(context);
                                _sendEmergencyMessage();
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryRed,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          selectedContact != null
                              ? 'SMS ile Acil Durum Mesajı Gönder'
                              : 'Lütfen bir kişi seçin',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: OutlinedButton(
                        onPressed: selectedContact != null
                            ? () {
                                Navigator.pop(context);
                                _shareEmergencyMessage();
                              }
                            : null,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _primaryRed,
                          side: BorderSide(
                            color: selectedContact != null
                                ? _primaryRed
                                : Colors.grey,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Alternatif Yöntemle Paylaş',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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

  // SMS alternatifi için paylaşım fonksiyonu
  Future<void> _shareEmergencyMessage() async {
    if (selectedContact == null) return;

    // Loading dialog'u göster
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Konum alınıyor...'),
            ],
          ),
        );
      },
    );

    try {
      // Konum izni kontrolü
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Navigator.of(context).pop(); // Loading dialog'u kapat
          _showErrorMessage('Konum izni gerekli');
          return;
        }
      }

      // Konum al
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      Navigator.of(context).pop(); // Loading dialog'u kapat

      // Zengin ve detaylı mesaj formatı
      final currentTime = DateTime.now();
      final timeString =
          '${currentTime.day.toString().padLeft(2, '0')}/${currentTime.month.toString().padLeft(2, '0')}/${currentTime.year} ${currentTime.hour.toString().padLeft(2, '0')}:${currentTime.minute.toString().padLeft(2, '0')}';
      final mapsUrl =
          'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}';

      String message =
          '🆘 ACİL DURUM ALARMI! 🆘\n\n'
          'Sayın ${selectedContact!.name},\n\n'
          'Bu mesajı gönderen kişi acil bir durumla karşılaştı ve derhal yardımınıza ihtiyacı var!\n\n'
          '📍 KONUM BİLGİSİ:\n'
          'Koordinatlar: ${position.latitude}, ${position.longitude}\n'
          'Harita Linki: $mapsUrl\n\n'
          '⏰ Mesaj Zamanı: $timeString\n\n'
          '🚨 YAPILMASI GEREKENLER:\n'
          '• Bu kişiyi derhal arayın\n'
          '• Gerekirse 112\'yi arayın\n'
          '• Yakındaysanız konuma gidin\n\n'
          '⚠️ Bu mesaj Deprem Takip uygulaması aracılığıyla otomatik olarak gönderilmiştir.\n'
          'Lütfen ciddiye alın ve hemen harekete geçin!';

      await Share.share(
        message,
        subject: '🆘 ACİL DURUM - Derhal Yardım Gerekiyor!',
      );
    } catch (e) {
      Navigator.of(context).pop(); // Loading dialog'u kapat

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Konum alınamadı: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _sendEmergencyMessage() async {
    if (selectedContact == null) return;

    try {
      // Konum izni kontrolü
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showErrorMessage('Konum izni gerekli');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showErrorMessage(
          'Konum izni kalıcı olarak reddedildi. Ayarlardan izin verin.',
        );
        return;
      }

      // Loading dialog göster
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Konum alınıyor...'),
            ],
          ),
        ),
      );

      // Mevcut konumu al
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Loading dialog'unu kapat
      Navigator.of(context).pop();

      // Telefon numarasını temizle - sadece rakamlar ve + işareti
      final cleanPhone = selectedContact!.phone.replaceAll(
        RegExp(r'[^\d+]'),
        '',
      );

      // Zengin ve kullanıcı dostu mesaj - Google Maps işaretli link ile
      final currentTime = DateTime.now();
      final timeString =
          '${currentTime.day.toString().padLeft(2, '0')}/${currentTime.month.toString().padLeft(2, '0')}/${currentTime.year} ${currentTime.hour.toString().padLeft(2, '0')}:${currentTime.minute.toString().padLeft(2, '0')}';
      final mapsUrl =
          'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}';

      final emergencyMessage =
          '🆘 ACİL DURUM ALARMI! 🆘\n\n'
          'Sayın ${selectedContact!.name},\n\n'
          'Bu mesajı gönderen kişi acil bir durumla karşılaştı ve derhal yardımınıza ihtiyacı var!\n\n'
          '📍 KONUM BİLGİSİ:\n'
          'Koordinatlar: ${position.latitude}, ${position.longitude}\n'
          'Harita Linki: $mapsUrl\n\n'
          '⏰ Mesaj Zamanı: $timeString\n\n'
          '🚨 YAPILMASI GEREKENLER:\n'
          '• Bu kişiyi derhal arayın\n'
          '• Gerekirse 112\'yi arayın\n'
          '• Yakındaysanız konuma gidin\n\n'
          '⚠️ Bu mesaj Deprem Takip uygulaması aracılığıyla otomatik olarak gönderilmiştir.\n'
          'Lütfen ciddiye alın ve hemen harekete geçin!';

      // SMS URI - mesaj içeriği ile
      String smsUrl =
          'sms:$cleanPhone?body=${Uri.encodeComponent(emergencyMessage)}';

      try {
        final smsUri = Uri.parse(smsUrl);

        if (await canLaunchUrl(smsUri)) {
          final success = await launchUrl(
            smsUri,
            mode: LaunchMode.externalApplication,
          );

          if (success) {
            // SMS uygulaması başarıyla açıldı
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Acil durum mesajı hazırlandı - ${selectedContact!.name}',
                ),
                backgroundColor: const Color(0xFF4CAF50),
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          } else {
            _showSmsAlternativeDialog();
          }
        } else {
          _showSmsAlternativeDialog();
        }
      } catch (e) {
        // SMS açılamadıysa alternatif öner
        _showSmsAlternativeDialog();
      }
    } catch (e) {
      // Loading dialog'unu kapat (eğer açıksa)
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      _showErrorMessage('Hata oluştu: $e');
    }
  }

  void _showSmsAlternativeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            const SizedBox(width: 8),
            const Text('SMS Gönderilemiyor'),
          ],
        ),
        content: const Text(
          'SMS uygulaması açılamadı. WhatsApp, Telegram gibi alternatif yöntemlerle mesajı paylaşmak ister misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _shareEmergencyMessage();
            },
            style: ElevatedButton.styleFrom(backgroundColor: _primaryRed),
            child: const Text(
              'Alternatif Paylaş',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    try {
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

      final telUri = Uri(scheme: 'tel', path: cleanNumber);

      if (await canLaunchUrl(telUri)) {
        final success = await launchUrl(
          telUri,
          mode: LaunchMode.externalApplication,
        );

        if (!success) {
          _showErrorMessage('Arama uygulaması açılamadı');
        }
      } else {
        _showErrorMessage('Bu cihazda arama desteklenmiyor');
      }
    } catch (e) {
      _showErrorMessage('Arama sırasında hata oluştu');
    }
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _primaryRed,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class Contact {
  int id;
  String name;
  String phone;
  bool isDefault;

  Contact({
    required this.id,
    required this.name,
    required this.phone,
    required this.isDefault,
  });
}
