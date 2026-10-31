import 'package:flutter/material.dart';

class SplashLogo extends StatelessWidget {
  const SplashLogo({super.key});
  @override
  Widget build(BuildContext context) => ClipOval(
    child: Image.asset(
      'assets/images/splash/splash_logo.png',
      width: 190,
      height: 190,
      fit: BoxFit.cover,
    ),
  );
}
