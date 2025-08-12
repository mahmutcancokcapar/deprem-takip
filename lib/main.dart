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

  runApp(const MyApp());
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
