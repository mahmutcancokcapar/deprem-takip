import 'dart:convert';
import 'package:http/http.dart' as http;

class DirectoryService {
  final String baseUrl = 'https://depremtakip-api-production.up.railway.app/directory';
  final String token;

  DirectoryService({required this.token});

  // Yeni kişi ekle
  Future<Map<String, dynamic>> addContact(String name, String phone) async {
    final url = Uri.parse('$baseUrl/contacts');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'name': name, 'phone': phone}),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'],
          'contact': data['contact'],
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Kişi eklenemedi',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Sunucuya bağlanırken hata oluştu: $e',
      };
    }
  }

  // Kişileri listele
  Future<Map<String, dynamic>> getContacts() async {
    final url = Uri.parse('$baseUrl/contacts');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'contacts': data['contacts']};
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Kişiler alınamadı',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Sunucuya bağlanırken hata oluştu: $e',
      };
    }
  }

  // Kişiyi güncelle
  Future<Map<String, dynamic>> updateContact({
    required int id,
    String? name,
    String? phone,
    bool? isDefault,
  }) async {
    final url = Uri.parse('$baseUrl/contacts/$id');

    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (phone != null) body['phone'] = phone;
    if (isDefault != null) body['default'] = isDefault;

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'],
          'contact': data['contact'],
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Güncelleme başarısız',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Sunucuya bağlanırken hata oluştu: $e',
      };
    }
  }

  // Kişiyi sil
  Future<Map<String, dynamic>> deleteContact(int id) async {
    final url = Uri.parse('$baseUrl/contacts/$id');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'message': data['message']};
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Silme başarısız',
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
