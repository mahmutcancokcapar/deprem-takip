import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = 'https://depremtakip-api-production.up.railway.app/auth';

  // Login Fonksiyonu
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'token': data['token'],
          'user': data['user'],
          'message': data['message'],
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Bilinmeyen hata oluştu',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Sunucuya bağlanırken hata oluştu: $e',
      };
    }
  }

  // Register Fonksiyonu
  Future<Map<String, dynamic>> registerUser({
    required String fullname,
    required String email,
    required String username,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullname': fullname,
          'email': email,
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'],
          'user': data['user'],
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Kayıt işlemi başarısız oldu',
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
