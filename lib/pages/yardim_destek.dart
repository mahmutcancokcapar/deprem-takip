// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class YardimDestek extends StatefulWidget {
  const YardimDestek({super.key});

  @override
  State<YardimDestek> createState() => _YardimDestekState();
}

class _YardimDestekState extends State<YardimDestek>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  int selectedFaqIndex = -1;
  String selectedCategory = 'Genel';

  final List<Map<String, dynamic>> faqCategories = [
    {'name': 'Genel', 'icon': Icons.help_outline, 'color': Color(0xFF2196F3)},
    {
      'name': 'Bildirimler',
      'icon': Icons.notifications,
      'color': Color(0xFFFF9800),
    },
    {'name': 'Harita', 'icon': Icons.map, 'color': Color(0xFF4CAF50)},
    {'name': 'Hesap', 'icon': Icons.account_circle, 'color': Color(0xFF9C27B0)},
  ];

  final Map<String, List<Map<String, String>>> faqData = {
    'Genel': [
      {
        'question': 'Deprem Takip uygulaması nasıl çalışır?',
        'answer':
            'Deprem Takip uygulaması, gerçek zamanlı deprem verilerini yalnızca Kandilli Rasathanesi ve Deprem Araştırma Enstitüsü’nden alır ve size anlık bildirimler gönderir. Konum bazlı uyarılar ve harita görünümü sayesinde deprem aktivitelerini kolayca takip etmenizi sağlar.',
      },
      {
        'question': 'Veriler ne kadar güvenilir?',
        'answer':
            'Uygulamamızda yalnızca Kandilli Rasathanesi ve Deprem Araştırma Enstitüsü gibi resmi ve güvenilir kurumların verileri kullanılır. Tüm veriler otomatik olarak doğrulanır ve en güncel bilgiler kullanıcılarımıza sunulur.',
      },
      {
        'question': 'Uygulama ücretsiz mi?',
        'answer':
            'Evet, Deprem Takip uygulaması tamamen ücretsizdir. Temel özellikler hiçbir ücret ödemeden kullanılabilir.',
      },
    ],
    'Bildirimler': [
      {
        'question': 'Bildirimler nasıl çalışır?',
        'answer':
            'Konum izni verdiğinizde, bulunduğunuz bölgeye yakın depremler için otomatik bildirim alırsınız. Bildirim ayarlarını istediğiniz gibi özelleştirebilirsiniz.',
      },
      {
        'question': 'Bildirim alamıyorum, ne yapmalıyım?',
        'answer':
            'Ayarlar > Bildirimler bölümünden bildirimlerin açık olduğundan emin olun. Ayrıca telefon ayarlarından uygulama bildirimlerinin izinli olduğunu kontrol edin.',
      },
    ],
    'Harita': [
      {
        'question': 'Harita üzerindeki renkler ne anlama geliyor?',
        'answer':
            'Yeşil: 0-3 büyüklük (hafif), Sarı: 3-5 büyüklük (orta), Turuncu: 5-7 büyüklük (güçlü), Kırmızı: 7+ büyüklük (çok güçlü) depremlerini temsil eder.',
      },
      {
        'question': 'Harita yüklenmiyor, ne yapabilirim?',
        'answer':
            'İnternet bağlantınızı kontrol edin. GPS izni verildiğinden emin olun. Uygulama yeniden başlatmayı deneyin.',
      },
    ],
    'Hesap': [
      {
        'question': 'Hesap nasıl oluşturulur?',
        'answer':
            'Ana sayfada "Kayıt Ol" butonuna tıklayın. E-posta ve şifre bilgilerinizi girin. Doğrulama e-postasını kontrol edin.',
      },
      {
        'question': 'Şifremi unuttum, ne yapmalıyım?',
        'answer':
            'Giriş sayfasında "Şifremi Unuttum" bağlantısına tıklayın. E-posta adresinizi girin, size şifre sıfırlama bağlantısı gönderilecek.',
      },
    ],
  };

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
          'Yardım & Destek',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: const Color(0xFFFF5722),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF5722), Color(0xFFFF7043)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
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
                        Icons.support_agent,
                        size: 40,
                        color: Color(0xFFFF5722),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Size Nasıl Yardımcı Olabiliriz?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '7/24 destek ekibimiz hizmetinizde',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Quick Actions
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hızlı İşlemler',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF424242),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickAction(
                            icon: Icons.chat_bubble_outline,
                            title: 'Canlı Destek',
                            subtitle: 'Anında yardım',
                            color: const Color(0xFF00BCD4),
                            onTap: () => _showLiveChatDialog(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickAction(
                            icon: Icons.email_outlined,
                            title: 'E-posta',
                            subtitle: 'Detaylı destek',
                            color: const Color(0xFF4CAF50),
                            onTap: () => _showEmailDialog(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickAction(
                            icon: Icons.bug_report_outlined,
                            title: 'Hata Bildir',
                            subtitle: 'Sorun bildir',
                            color: const Color(0xFFE91E63),
                            onTap: () => _showBugReportDialog(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickAction(
                            icon: Icons.star_outline,
                            title: 'Değerlendir',
                            subtitle: 'Geri bildirim',
                            color: const Color(0xFFFF9800),
                            onTap: () => _showRatingDialog(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // FAQ Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sık Sorulan Sorular',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF424242),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Category Tabs
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: faqCategories.map((category) {
                          bool isSelected =
                              selectedCategory == category['name'];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedCategory = category['name'];
                                selectedFaqIndex = -1;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? category['color']
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    category['icon'],
                                    size: 18,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey[600],
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    category['name'],
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey[600],
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // FAQ Items
                    ...faqData[selectedCategory]!.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, String> faq = entry.value;
                      bool isExpanded = selectedFaqIndex == index;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isExpanded
                                ? faqCategories.firstWhere(
                                    (cat) => cat['name'] == selectedCategory,
                                  )['color']
                                : Colors.grey[200]!,
                          ),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(
                                faq['question']!,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                              trailing: Icon(
                                isExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                color: faqCategories.firstWhere(
                                  (cat) => cat['name'] == selectedCategory,
                                )['color'],
                              ),
                              onTap: () {
                                setState(() {
                                  selectedFaqIndex = isExpanded ? -1 : index;
                                });
                              },
                            ),
                            if (isExpanded)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  16,
                                ),
                                child: Text(
                                  faq['answer']!,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    height: 1.5,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                      // ignore: unnecessary_to_list_in_spreads
                    }).toList(),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Contact Information
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.grey[800]!, Colors.grey[900]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'İletişim Bilgileri',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildContactInfo(
                      Icons.email,
                      'E-posta',
                      'destek@mcmedya.com',
                    ),
                    _buildContactInfo(
                      Icons.access_time,
                      'Çalışma Saatleri',
                      '7/24 Destek',
                    ),
                    _buildContactInfo(
                      Icons.language,
                      'Website',
                      'https://mcmedya.netlify.app',
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

  Widget _buildQuickAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Text(
            '$title: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey[300])),
          ),
        ],
      ),
    );
  }

  void _showLiveChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Canlı Destek'),
        content: const Text(
          'Canlı destek özelliği yakında aktif olacak. Şimdilik e-posta yoluyla iletişime geçebilirsiniz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showEmailDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('E-posta Gönder'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-posta Adresiniz',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Konu',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: 'Mesajınız',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mesajınız gönderildi!')),
              );
            },
            child: const Text('Gönder'),
          ),
        ],
      ),
    );
  }

  void _showBugReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hata Bildir'),
        content: const Text(
          'Karşılaştığınız hatayı detaylı olarak açıklayın. Ekran görüntüsü ekleyebilirsiniz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showEmailDialog();
            },
            child: const Text('Devam Et'),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Uygulamayı Değerlendir'),
        content: const Text(
          'Deprem Takip uygulamasını beğendiniz mi? App Store\'da değerlendirmenizi paylaşın.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Daha Sonra'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Play Store\'a yönlendiriliyorsunuz...'),
                ),
              );
            },
            child: const Text('Değerlendir'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
