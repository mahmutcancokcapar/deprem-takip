import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileService {
  final String baseUrl = 'https://depremtakip-api-production.up.railway.app/profileInfo';
  final String token;

  ProfileService({required this.token});

  Future<Map<String, dynamic>> getProfile() async {
    final url = Uri.parse('$baseUrl/profile');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'profile': data['profile']};
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Profil bulunamadı veya hata oluştu',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Sunucuya bağlanırken hata oluştu: $e',
      };
    }
  }
}
