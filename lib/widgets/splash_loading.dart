import 'package:flutter/material.dart';

class SplashLoading extends StatelessWidget {
  const SplashLoading({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 26,
    height: 26,
    child: CircularProgressIndicator(strokeWidth: 2.5),
  );
}
