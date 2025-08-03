// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class Hakkinda extends StatefulWidget {
  const Hakkinda({super.key});

  @override
  State<Hakkinda> createState() => _HakkindaState();
}

class _HakkindaState extends State<Hakkinda> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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
          'Hakkında',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF9C27B0),
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
                    colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
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
                        image: const DecorationImage(
                          image: AssetImage('assets/images/logo.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Deprem Takip',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sürüm 1.0.0',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Text(
                        'Güvenilir Deprem Takip Uygulaması',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // About Section
              _buildInfoCard(
                icon: Icons.info_outline,
                title: 'Uygulama Hakkında',
                content:
                    'Deprem Takip, Türkiye ve dünya genelindeki deprem aktivitelerini gerçek zamanlı olarak takip etmenizi sağlayan güvenilir bir mobil uygulamadır. Güncel deprem verilerini, haritalar üzerinde görselleştirmeyi ve kişiselleştirilmiş bildirimler almayı mümkün kılar.',
                color: const Color(0xFF2196F3),
              ),

              // Features Section
              _buildInfoCard(
                icon: Icons.star,
                title: 'Özellikler',
                color: const Color(0xFF4CAF50),
                items: [
                  'Gerçek zamanlı deprem verileri',
                  'İnteraktif harita görünümü',
                  'Kişiselleştirilmiş bildirimler',
                  'Deprem geçmişi ve istatistikler',
                  'Konum bazlı uyarılar',
                  'Acil durum rehberi',
                  'Offline veri erişimi',
                  'Çoklu dil desteği',
                ],
              ),

              // Company Section
              _buildInfoCard(
                icon: Icons.business,
                title: 'MC MEDYA',
                content:
                    'MC MEDYA, teknoloji ve medya alanında faaliyet gösteren yenilikçi bir şirkettir. Kullanıcı odaklı çözümler geliştirerek, toplumsal fayda sağlayan uygulamalar üretmeyi misyon edinmiştir.',
                color: const Color(0xFFFF9800),
              ),

              // Mission & Vision
              _buildInfoCard(
                icon: Icons.visibility,
                title: 'Misyon & Vizyon',
                content:
                    'Misyonumuz: Deprem risklerini minimize etmek ve halkı bilinçlendirmek için teknolojinin gücünden faydalanmak.\n\nVizyonumuz: Deprem güvenliği konusunda Türkiye\'nin en güvenilir dijital platformu olmak.',
                color: const Color(0xFF9C27B0),
              ),

              // Data Sources
              _buildInfoCard(
                icon: Icons.source,
                title: 'Veri Kaynakları',
                content:
                    'Uygulamamızda kullanılan deprem verileri yalnızca Kandilli Rasathanesi ve Deprem Araştırma Enstitüsü’nden alınmaktadır. Bu kurumların sağladığı güncel ve güvenilir veriler, kullanıcılarımıza hızlı ve doğru deprem bilgisi sunmak amacıyla kullanılmaktadır.',
                color: const Color(0xFFE91E63),
              ),

              // Contact Section
              _buildContactCard(),

              // Stats Section
              _buildStatsCard(),

              const SizedBox(height: 24),

              // Footer
              Container(
                width: double.infinity,
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
                  children: [
                    Icon(Icons.favorite, color: Colors.red[400], size: 32),
                    const SizedBox(height: 12),
                    const Text(
                      'Güvenliğiniz İçin Geliştirildi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'MC MEDYA © ${DateTime.now().year} - Tüm hakları saklıdır',
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
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

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    String? content,
    List<String>? items,
    required Color color,
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (content != null)
              Text(
                content,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                  height: 1.6,
                ),
              ),
            if (items != null) ...[
              const SizedBox(height: 12),
              ...items
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[700],
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  // ignore: unnecessary_to_list_in_spreads
                  .toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00BCD4).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.contact_mail,
                    color: Color(0xFF00BCD4),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'İletişim',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00BCD4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildContactItem(Icons.email, 'E-posta', 'info@mcmedya.com'),
            _buildContactItem(Icons.web, 'Website', 'https://mcmedya.netlify.app'),
            _buildContactItem(
              Icons.support_agent,
              'Destek',
              'destek@mcmedya.com',
            ),
            _buildContactItem(
              Icons.bug_report,
              'Hata Bildirimi',
              'bug@mcmedya.com',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00BCD4), size: 20),
          const SizedBox(width: 12),
          Text(
            '$title: ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF667eea), const Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Uygulama İstatistikleri',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildStatItem('500K+', 'Kullanıcı')),
                Expanded(child: _buildStatItem('24/7', 'Monitoring')),
                Expanded(child: _buildStatItem('99.9%', 'Uptime')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8)),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
