// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class GizlilikPol extends StatefulWidget {
  const GizlilikPol({super.key});

  @override
  State<GizlilikPol> createState() => _GizlilikPolState();
}

class _GizlilikPolState extends State<GizlilikPol> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Gizlilik Politikası',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(Icons.security, size: 48, color: Colors.white),
                  const SizedBox(height: 12),
                  const Text(
                    'Deprem Takip',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'MC MEDYA tarafından geliştirilmiştir',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Son güncelleme: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Main Content
            _buildSection(
              icon: Icons.info_outline,
              title: '1. Genel Bilgiler',
              content:
                  'Bu gizlilik politikası, Deprem Takip mobil uygulaması ("Uygulama") aracılığıyla MC MEDYA ("Şirket", "biz", "bizim") tarafından toplanan kişisel verilerin işlenmesi hakkında sizi bilgilendirmek amacıyla hazırlanmıştır. 6698 sayılı Kişisel Verilerin Korunması Kanunu (KVKK) kapsamında haklarınız korunmaktadır.',
            ),

            _buildSection(
              icon: Icons.data_usage,
              title: '2. Toplanan Veriler',
              content:
                  'Uygulamamız aracılığıyla aşağıdaki kişisel verileriniz toplanmaktadır:',
              items: [
                'Ad ve Soyad bilgileriniz',
                'E-posta adresiniz',
                'Telefon numaranız (isteğe bağlı)',
                'Konum bilgileri (deprem bildirimleri için)',
                'Cihaz bilgileri ve uygulama kullanım verileri',
              ],
            ),

            _buildSection(
              icon: Icons.track_changes,
              title: '3. Verilerin Kullanım Amaçları',
              content:
                  'Toplanan verileriniz aşağıdaki amaçlarla kullanılmaktadır:',
              items: [
                'Deprem bildirimlerini size ulaştırmak',
                'Kullanıcı hesabınızı oluşturmak ve yönetmek',
                'Size özel içerik ve bildirimler sunmak',
                'Uygulama performansını iyileştirmek',
                'Hukuki yükümlülükleri yerine getirmek',
                'İletişim kurarak destek sağlamak',
              ],
            ),

            _buildSection(
              icon: Icons.share,
              title: '4. Veri Paylaşımı',
              content:
                  'Kişisel verileriniz aşağıdaki durumlar dışında üçüncü taraflarla paylaşılmaz:',
              items: [
                'Yasal zorunluluklar gereği resmi makamlarla',
                'Hizmet sağlayıcılarımızla (sadece hizmet sunumu için)',
                'Açık rızanızın bulunduğu durumlarda',
                'Can ve mal güvenliği açısından acil durumlar',
              ],
            ),

            _buildSection(
              icon: Icons.security,
              title: '5. Veri Güvenliği',
              content:
                  'Kişisel verilerinizin güvenliği bizim için önceliklidir. Verilerinizi korumak için:',
              items: [
                'SSL şifreleme teknolojisi kullanılır',
                'Düzenli güvenlik testleri yapılır',
                'Sadece yetkili personel veriye erişebilir',
                'Güncel güvenlik protokolleri uygulanır',
                'Veri yedekleme sistemleri mevcuttur',
              ],
            ),

            _buildSection(
              icon: Icons.account_circle,
              title: '6. Haklarınız',
              content: 'KVKK kapsamında aşağıdaki haklara sahipsiniz:',
              items: [
                'Kişisel verilerinizin işlenip işlenmediğini öğrenme',
                'İşlenen verileriniz hakkında bilgi talep etme',
                'Verilerin düzeltilmesini veya silinmesini isteme',
                'Veri işleme faaliyetlerine itiraz etme',
                'Zararın giderilmesini talep etme',
              ],
            ),

            _buildSection(
              icon: Icons.contact_mail,
              title: '7. İletişim',
              content:
                  'Gizlilik politikamız hakkında sorularınız için bizimle iletişime geçebilirsiniz:',
              items: [
                'Şirket: MC MEDYA',
                'E-posta: info@mcmedya.com',
                'Web: https://mcmedya.netlify.app',
              ],
            ),

            _buildSection(
              icon: Icons.update,
              title: '8. Politika Güncellemeleri',
              content:
                  'Bu gizlilik politikası gerektiğinde güncellenebilir. Önemli değişiklikler uygulama üzerinden size bildirilecektir. Politikanın güncel halini düzenli olarak kontrol etmenizi öneririz.',
            ),

            const SizedBox(height: 32),

            // Footer
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
                  Icon(
                    Icons.verified_user,
                    color: const Color(0xFF2E7D32),
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Verileriniz Güvende',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'KVKK ve GDPR uyumlu veri işleme',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
    List<String>? items,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: const Color(0xFF2E7D32), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              content,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            if (items != null) ...[
              const SizedBox(height: 12),
              ...items
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2E7D32),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                                height: 1.4,
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
