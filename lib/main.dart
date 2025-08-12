import 'package:deprem_takip/pages/app_controller.dart';
import 'package:deprem_takip/services/notification_service.dart';
import 'package:deprem_takip/services/background_earthquake_service.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Bildirim servisini başlat
  await NotificationService.initialize();

  // Arka plan servisini başlat
  await BackgroundEarthquakeService.initialize();

  // Arka plan servisini kontrol et ve başlat
  await _initializeBackgroundService();

  runApp(const MyApp());
}

Future<void> _initializeBackgroundService() async {
  try {
    // Bildirimler açık mı kontrol et
    final notificationsEnabled = await BackgroundEarthquakeService.areNotificationsEnabled();
    
    if (notificationsEnabled) {
      // ignore: avoid_print
      print('🚀 Bildirimler açık, arka plan servisi başlatılıyor...');
      await BackgroundEarthquakeService.startPeriodicCheck();
      // ignore: avoid_print
      print('✅ Arka plan servisi başlatıldı');
    } else {
      // ignore: avoid_print
      print('📴 Bildirimler kapalı, arka plan servisi başlatılmadı');
    }
  } catch (e) {
    // ignore: avoid_print
    print('❌ Arka plan servisi başlatılamadı: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Deprem Takip',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const AppController(),
    );
  }
}
