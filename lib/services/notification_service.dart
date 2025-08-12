import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Android için ayarlar
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS için ayarlar
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Bildirime tıklandığında yapılacak işlemler
        if (kDebugMode) {
          print('Bildirime tıklandı: ${response.payload}');
        }
      },
    );

    // Android için bildirim kanalı oluştur
    await _createNotificationChannel();
  }

  static Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'earthquake_channel',
      'Deprem Bildirimleri',
      description: 'Deprem uyarıları için bildirim kanalı',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> showEarthquakeNotification({
    required String title,
    required String body,
    required double magnitude,
    required String location,
  }) async {
    // Büyüklüğe göre bildirim önceliği belirle
    Importance importance;
    Priority priority;
    String channelId;

    if (magnitude >= 4.0) {
      importance = Importance.max;
      priority = Priority.high;
      channelId = 'earthquake_high';
    } else if (magnitude >= 2.0) {
      importance = Importance.high;
      priority = Priority.defaultPriority;
      channelId = 'earthquake_medium';
    } else {
      importance = Importance.defaultImportance;
      priority = Priority.low;
      channelId = 'earthquake_low';
    }

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      'Deprem Bildirimleri',
      channelDescription: 'Deprem uyarıları için bildirim kanalı',
      importance: importance,
      priority: priority,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
      color: Color(_getColorByMagnitude(magnitude) ?? 0xFF10B981),
      styleInformation: BigTextStyleInformation(
        body,
        htmlFormatBigText: true,
        contentTitle: title,
        htmlFormatContentTitle: true,
      ),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      platformChannelSpecifics,
      payload: 'earthquake_${magnitude}_$location',
    );
  }

  static int? _getColorByMagnitude(double magnitude) {
    if (magnitude >= 4.0) {
      return 0xFFEF4444; // Kırmızı
    } else if (magnitude >= 2.0) {
      return 0xFFF59E0B; // Turuncu
    } else {
      return 0xFF10B981; // Yeşil
    }
  }

  static Future<bool> areNotificationsEnabled() async {
    final bool? result = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.areNotificationsEnabled();
    return result ?? false;
  }

  static Future<void> requestPermission() async {
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
        
    // Android için pil optimizasyonu iznini iste
    await _requestBatteryOptimizationExemption();
  }
  
  static Future<void> _requestBatteryOptimizationExemption() async {
    try {
      // Not: Bu Android native kod gerektirir, şimdilik sadece log bırakıyoruz
      // ignore: avoid_print
      print('💡 Kullanıcıdan pil optimizasyonunu kapatması istenmeli');
    } catch (e) {
      // ignore: avoid_print
      print('Pil optimizasyonu izni istenemedi: $e');
    }
  }
}
