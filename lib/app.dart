import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/payment_provider.dart';
import 'services/mock_payment_service.dart';
import 'screens/splash/splash_screen.dart';

class DhiesnaApp extends StatelessWidget {
  const DhiesnaApp({super.key, this.now});
  // Sumber waktu tracking; diisi oleh test, aplikasi memakai jam sistem.
  final DateTime Function()? now;
  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => CartProvider()),
      ChangeNotifierProvider(create: (_) => OrderProvider(now: now)),
      ChangeNotifierProvider(
        create: (_) => PaymentProvider(MockPaymentService(payOnCheck: true)),
      ),
    ],
    child: MaterialApp(
      title: 'Warung Ibu Kost Dhiesna',
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      builder: (context, child) => Container(
        color: const Color(0xFFE2F2F7),
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: child!,
        ),
      ),
      home: const SplashScreen(),
    ),
  );
}
