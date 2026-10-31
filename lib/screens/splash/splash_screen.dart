import 'package:flutter/material.dart';

import '../../widgets/splash_logo.dart';
import '../../widgets/splash_loading.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => initialize());
  }

  Future<void> initialize() async {
    await precacheImage(
      const AssetImage('assets/images/splash/splash_logo.png'),
      context,
    );
    if (!mounted) {
      return;
    }
    await precacheImage(
      const AssetImage('assets/images/restaurant/header.png'),
      context,
    );
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SplashLogo(),
              SizedBox(height: 28),
              Text(
                'Warung Ibu Kost Dhiesna',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                'Masakan rumahan, rasa istimewa.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              SplashLoading(),
            ],
          ),
        ),
      ),
    ),
  );
}
