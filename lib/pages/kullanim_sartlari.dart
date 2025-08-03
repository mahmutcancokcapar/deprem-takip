// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class KullanimSartlari extends StatefulWidget {
  const KullanimSartlari({super.key});

  @override
  State<KullanimSartlari> createState() => _KullanimSartlariState();
}

class _KullanimSartlariState extends State<KullanimSartlari> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Kullanım Şartları',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1976D2),
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
                  colors: [Color(0xFF1976D2), Color(0xFF2196F3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(Icons.assignment, size: 48, color: Colors.white),
                  const SizedBox(height: 12),
                  const Text(
                    'Kullanım Şartları',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Deprem Takip - MC MEDYA',
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
                      'Yürürlük tarihi: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Main Content
            _buildSection(
              icon: Icons.handshake,
              title: '1. Kabul ve Anlaşma',
              content:
                  'Deprem Takip mobil uygulamasını ("Uygulama") kullanarak, bu kullanım şartlarını tamamen kabul etmiş sayılırsınız. MC MEDYA ("Şirket") tarafından sunulan bu hizmetleri kullanmadan önce lütfen bu şartları dikkatlice okuyunuz. Bu şartları kabul etmiyorsanız uygulamayı kullanmayınız.',
            ),

            _buildSection(
              icon: Icons.description,
              title: '2. Hizmet Tanımı',
              content:
                  'Deprem Takip uygulaması, kullanıcılara aşağıdaki hizmetleri sunar:',
              items: [
                'Gerçek zamanlı deprem bildirimlerini alma',
                'Deprem verilerini görüntüleme ve analiz etme',
                'Konum bazlı deprem uyarıları',
                'Acil durum bilgileri ve rehberlik',
                'Deprem hazırlık önerileri',
                'Kullanıcı topluluğu ile bilgi paylaşımı',
              ],
            ),

            _buildSection(
              icon: Icons.person,
              title: '3. Kullanıcı Sorumlulukları',
              content:
                  'Uygulamayı kullanırken aşağıdaki kurallara uymanız gerekmektedir:',
              items: [
                'Doğru ve güncel bilgiler sağlamak',
                'Hesap güvenliğinizi korumak',
                'Yasalara uygun davranmak',
                'Başkalarının haklarına saygı göstermek',
                'Spam veya zararlı içerik paylaşmamak',
                'Sistemi kötüye kullanmamak',
              ],
            ),

            _buildSection(
              icon: Icons.block,
              title: '4. Yasaklanan Kullanımlar',
              content: 'Aşağıdaki eylemler kesinlikle yasaktır:',
              items: [
                'Uygulamayı ticari amaçlarla kötüye kullanmak',
                'Sahte veya yanıltıcı bilgi paylaşmak',
                'Zararlı yazılım veya virüs yayma',
                'Başka kullanıcıların hesaplarına izinsiz erişim',
                'Telif hakkı ihlali yapma',
                'Sistemi bozmaya yönelik faaliyetler',
              ],
            ),

            _buildSection(
              icon: Icons.gavel,
              title: '5. Fikri Mülkiyet Hakları',
              content:
                  'Uygulamadaki tüm içerik, tasarım, logo, metin ve yazılım MC MEDYA\'nın mülkiyetindedir. Bu materyaller:',
              items: [
                'Telif hakkı ile korunmaktadır',
                'İzin alınmadan kopyalanamaz',
                'Ticari amaçla kullanılamaz',
                'Değiştirilemez veya dağıtılamaz',
                'Tersine mühendislik yapılamaz',
              ],
            ),

            _buildSection(
              icon: Icons.warning,
              title: '6. Sorumluluk Reddi',
              content:
                  'MC MEDYA, uygulama kullanımı konusunda aşağıdaki konularda sorumluluk kabul etmez:',
              items: [
                'Deprem verilerinin %100 doğruluğu',
                'Hizmet kesintilerinden kaynaklanan zararlar',
                'Üçüncü taraf bağlantılarından doğan sorunlar',
                'Kullanıcı verilerinin kaybolması',
                'Uygulamanın kesintisiz çalışması',
                'Kullanıcıların yanlış kararları',
              ],
            ),

            _buildSection(
              icon: Icons.account_balance,
              title: '7. Hesap Yönetimi',
              content: 'Kullanıcı hesabınızla ilgili önemli bilgiler:',
              items: [
                'Hesap bilgilerinizi güncel tutmalısınız',
                'Şifrenizi güvenli saklamalısınız',
                'Hesabınızdan siz sorumlusunuz',
                'Şüpheli aktiviteyi bildirmelisiniz',
                'Hesap kapatma hakkımız saklıdır',
                'Veri yedekleme sizin sorumluluğunuzdur',
              ],
            ),

            _buildSection(
              icon: Icons.update,
              title: '8. Güncellemeler ve Değişiklikler',
              content: 'MC MEDYA aşağıdaki hakları saklı tutar:',
              items: [
                'Uygulamayı güncelleme ve geliştirme',
                'Kullanım şartlarını değiştirme',
                'Hizmetleri geçici olarak durdurma',
                'Yeni özellikler ekleme veya kaldırma',
                'Fiyatlandırma değişiklikleri yapma',
                'Kullanıcı hesaplarını askıya alma',
              ],
            ),

            _buildSection(
              icon: Icons.gps_fixed,
              title: '9. Konum Verilerinin Kullanımı',
              content: 'Deprem takibi için konum verileriniz:',
              items: [
                'Sadece deprem bildirimleri için kullanılır',
                'İzniniz olmadan paylaşılmaz',
                'Güvenli şekilde saklanır',
                'İstediğiniz zaman kapatabilirsiniz',
                'Doğruluk garantisi vermeyiz',
                'Üçüncü taraflarla paylaşılmaz',
              ],
            ),

            _buildSection(
              icon: Icons.balance,
              title: '10. Uygulanacak Hukuk',
              content:
                  'Bu kullanım şartları Türkiye Cumhuriyeti yasalarına tabidir. Ortaya çıkabilecek anlaşmazlıklar Türk mahkemelerinde çözümlenir. Uluslararası kullanıcılar için yerel yasalar da geçerli olabilir.',
            ),

            _buildSection(
              icon: Icons.contact_support,
              title: '11. İletişim ve Destek',
              content: 'Kullanım şartları hakkında sorularınız için:',
              items: [
                'Şirket: MC MEDYA',
                'E-posta: destek@mcmedya.com',
                'Web: https://mcmedya.netlify.app',
                'Uygulama içi destek sistemi',
              ],
            ),

            _buildSection(
              icon: Icons.event,
              title: '12. Yürürlük',
              content:
                  'Bu kullanım şartları, uygulamayı ilk kez kullandığınız andan itibaren yürürlükte olup, hesabınızı kapattığınız veya uygulamayı sildiğiniz tarihe kadar geçerli kalır. Bazı maddeler hesap kapatıldıktan sonra da geçerliliğini koruyabilir.',
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
                    Icons.verified,
                    color: const Color(0xFF1976D2),
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Güvenli ve Yasal Kullanım',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Türk Hukuku ve uluslararası standartlara uygun',
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
                    color: const Color(0xFF1976D2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: const Color(0xFF1976D2), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
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
                              color: Color(0xFF1976D2),
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
