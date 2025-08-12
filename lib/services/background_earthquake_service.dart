import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import '../models/model.dart';
import 'notification_service.dart';

class BackgroundEarthquakeService {
  static const int _alarmId = 1;
  static const String _lastEarthquakeKey = 'last_earthquake_id';
  static const String _minimumMagnitudeKey = 'minimum_magnitude';
  static const String _notificationsEnabledKey = 'notifications_enabled';

  static Future<void> initialize() async {
    await AndroidAlarmManager.initialize();
  }

  static Future<void> startPeriodicCheck() async {
    // Her 15 dakikada bir kontrol et
    await AndroidAlarmManager.periodic(
      const Duration(minutes: 15),
      _alarmId,
      checkForNewEarthquakes,
      wakeup: true,
      exact: true,
      allowWhileIdle: true,
    );
  }

  static Future<void> stopPeriodicCheck() async {
    await AndroidAlarmManager.cancel(_alarmId);
  }

  static Future<void> setMinimumMagnitude(double magnitude) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_minimumMagnitudeKey, magnitude);
  }

  static Future<double> getMinimumMagnitude() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_minimumMagnitudeKey) ?? 1.0;
  }

  static Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);

    if (enabled) {
      await startPeriodicCheck();
    } else {
      await stopPeriodicCheck();
    }
  }

  static Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? false;
  }

  static Future<void> _saveLastEarthquakeId(String earthquakeId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastEarthquakeKey, earthquakeId);
  }

  static Future<String?> _getLastEarthquakeId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastEarthquakeKey);
  }

  static Future<List<Earthquake>> _fetchLatestEarthquakes() async {
    try {
      final response = await http
          .get(
            Uri.parse('https://api.orhanaydogdu.com.tr/deprem/kandilli/live'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'User-Agent': 'Mozilla/5.0 (compatible; Flutter App)',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse.containsKey('status') &&
            jsonResponse['status'] == true &&
            jsonResponse.containsKey('result')) {
          final List<dynamic> jsonData = jsonResponse['result'];

          List<Earthquake> earthquakes = [];
          // Sadece ilk 10 depremi kontrol et (performans için)
          for (int i = 0; i < jsonData.length && i < 10; i++) {
            try {
              final earthquake = Earthquake.fromJson(jsonData[i]);
              earthquakes.add(earthquake);
            } catch (e) {
              continue;
            }
          }
          return earthquakes;
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Arka plan deprem verisi alınamadı: $e');
    }
    return [];
  }

  // Bu fonksiyon static ve top-level olmalı ki AndroidAlarmManager çağırabilsin
  @pragma('vm:entry-point')
  static Future<void> checkForNewEarthquakes() async {
    try {
      // Bildirimlerin açık olup olmadığını kontrol et
      final notificationsEnabled = await areNotificationsEnabled();
      if (!notificationsEnabled) return;

      final minimumMagnitude = await getMinimumMagnitude();
      final lastEarthquakeId = await _getLastEarthquakeId();

      final earthquakes = await _fetchLatestEarthquakes();
      if (earthquakes.isEmpty) return;

      // En yeni depremi al
      final latestEarthquake = earthquakes.first;

      // Eğer bu deprem daha önce bildirilmediyse ve minimum büyüklüğün üzerindeyse
      if (latestEarthquake.earthquakeId != lastEarthquakeId &&
          latestEarthquake.mag >= minimumMagnitude) {
        // Normal deprem bildirimi
        await _sendEarthquakeNotification(latestEarthquake, false);
        await _saveLastEarthquakeId(latestEarthquake.earthquakeId);
      }

      // Büyük depremler için (4.0 ve üzeri) her zaman bildirim gönder
      final significantEarthquakes = earthquakes
          .where((eq) => eq.mag >= 4.0 && eq.earthquakeId != lastEarthquakeId)
          .toList();

      for (final earthquake in significantEarthquakes) {
        // Büyük deprem bildirimi
        await _sendEarthquakeNotification(earthquake, true);
        await _saveLastEarthquakeId(earthquake.earthquakeId);
        break; // Sadece bir büyük deprem bildirimi gönder
      }
    } catch (e) {
      // ignore: avoid_print
      print('Arka plan deprem kontrolü hatası: $e');
    }
  }

  static Future<void> _sendEarthquakeNotification(
    Earthquake earthquake,
    bool isCritical,
  ) async {
    // Büyüklüğe göre emoji ve seviye belirleme
    final emoji = _getMagnitudeEmoji(earthquake.mag);
    final level = _getMagnitudeLevel(earthquake.mag);
    final intensityColor = _getIntensityDescription(earthquake.mag);

    // Koordinatları al
    final coordinates = earthquake.geojson['coordinates'] as List;
    final latitude = coordinates[1];
    final longitude = coordinates[0];

    // Zaman bilgisi
    final timeAgo = _getTimeAgo(earthquake.dateTime);
    final formattedTime = _formatDateTime(earthquake.dateTime);

    // Bildirim başlığı
    String title;
    if (isCritical || earthquake.mag >= 4.0) {
      title = '$emoji BÜYÜK DEPREM UYARISI!';
    } else {
      title = '$emoji Deprem Bildirimi';
    }

    // Detaylı bildirim içeriği
    String body =
        '''🌍 ${earthquake.title}

📊 Büyüklük: ${earthquake.mag.toStringAsFixed(1)} ($level)
$intensityColor

📏 Derinlik: ${earthquake.depth.toStringAsFixed(1)} km
🌐 ${latitude.toStringAsFixed(2)}°, ${longitude.toStringAsFixed(2)}°

⏰ $formattedTime ($timeAgo)
📡 Kaynak: ${earthquake.provider.toUpperCase()}''';

    await NotificationService.showEarthquakeNotification(
      title: title,
      body: body,
      magnitude: earthquake.mag,
      location: earthquake.title,
    );
  }

  static String _getMagnitudeEmoji(double magnitude) {
    if (magnitude >= 7.0) return '💥';
    if (magnitude >= 6.0) return '🚨';
    if (magnitude >= 5.0) return '⚠️';
    if (magnitude >= 4.0) return '📳';
    if (magnitude >= 3.0) return '🌊';
    if (magnitude >= 2.0) return '📍';
    return '🌍';
  }

  static String _getMagnitudeLevel(double magnitude) {
    if (magnitude >= 7.0) return 'AŞIRI BÜYÜK';
    if (magnitude >= 6.0) return 'ÇOK BÜYÜK';
    if (magnitude >= 5.0) return 'BÜYÜK';
    if (magnitude >= 4.0) return 'ORTA';
    if (magnitude >= 3.0) return 'KÜÇÜK';
    if (magnitude >= 2.0) return 'ÇOK KÜÇÜK';
    return 'MINIMAL';
  }

  static String _getIntensityDescription(double magnitude) {
    if (magnitude >= 7.0) {
      return '🔴 Çok tehlikeli! Derhal güvenli alana gidin!';
    }
    if (magnitude >= 6.0) return '🟠 Tehlikeli! Dikkatli olun!';
    if (magnitude >= 5.0) return '🟡 Orta şiddetli deprem';
    if (magnitude >= 4.0) return '🟢 Hafif sarsıntı hissedilebilir';
    if (magnitude >= 3.0) return '🔵 Zayıf deprem';
    return '⚪ Çok zayıf deprem';
  }

  static String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }

  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Test amaçlı bildirim gönderme fonksiyonu
  static Future<void> sendTestNotification() async {
    // Test depremi oluştur
    final testEarthquake = Earthquake(
      earthquakeId: 'test_${DateTime.now().millisecondsSinceEpoch}',
      provider: 'KANDILLI',
      title: 'İstanbul - Beyoğlu',
      date: DateTime.now().toIso8601String(),
      mag: 4.2,
      depth: 12.5,
      geojson: {
        'type': 'Point',
        'coordinates': [28.9784, 41.0082],
      },
      locationProperties: {'closestCity': 'İstanbul', 'distance': '5.2 km'},
      dateTime: DateTime.now(),
      createdAt: DateTime.now().millisecondsSinceEpoch,
      locationTz: 'Europe/Istanbul',
    );

    await _sendEarthquakeNotification(testEarthquake, false);
  }

  // Büyük deprem test bildirimi
  static Future<void> sendCriticalTestNotification() async {
    final testEarthquake = Earthquake(
      earthquakeId: 'critical_test_${DateTime.now().millisecondsSinceEpoch}',
      provider: 'KANDILLI',
      title: 'Ankara - Çankaya',
      date: DateTime.now().toIso8601String(),
      mag: 6.3,
      depth: 8.2,
      geojson: {
        'type': 'Point',
        'coordinates': [32.8597, 39.9334],
      },
      locationProperties: {'closestCity': 'Ankara', 'distance': '2.1 km'},
      dateTime: DateTime.now(),
      createdAt: DateTime.now().millisecondsSinceEpoch,
      locationTz: 'Europe/Istanbul',
    );

    await _sendEarthquakeNotification(testEarthquake, true);
  }
}
