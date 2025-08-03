import 'package:deprem_takip/pages/main_page.dart';
import 'package:deprem_takip/pages/welcome_page.dart';
import 'package:deprem_takip/services/storage_service.dart';
import 'package:flutter/material.dart';

class AppController extends StatefulWidget {
  const AppController({super.key});

  @override
  State<AppController> createState() => _AppControllerState();
}

class _AppControllerState extends State<AppController> {
  bool isLoading = true;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final loggedIn = await StorageService.isLoggedIn();
      setState(() {
        isLoggedIn = loggedIn;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoggedIn = false;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return isLoggedIn ? const MainPage() : const WelcomePage();
  }
}
