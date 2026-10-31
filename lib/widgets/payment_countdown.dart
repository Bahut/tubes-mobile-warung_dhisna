import 'dart:async';

import 'package:flutter/material.dart';

class PaymentCountdown extends StatefulWidget {
  const PaymentCountdown({
    super.key,
    required this.expiresAt,
    required this.onExpired,
  });
  final DateTime expiresAt;
  final VoidCallback onExpired;
  @override
  State<PaymentCountdown> createState() => _PaymentCountdownState();
}

class _PaymentCountdownState extends State<PaymentCountdown>
    with WidgetsBindingObserver {
  Timer? timer;
  bool notified = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    timer = Timer.periodic(const Duration(seconds: 1), (_) => tick());
    WidgetsBinding.instance.addPostFrameCallback((_) => tick());
  }

  void tick() {
    if (!mounted) {
      return;
    }
    if (!DateTime.now().isBefore(widget.expiresAt) && !notified) {
      notified = true;
      widget.onExpired();
    }
    setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      tick();
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Hitung dari waktu kedaluwarsa agar tetap benar setelah aplikasi ditinggal.
    final seconds = widget.expiresAt
        .difference(DateTime.now())
        .inSeconds
        .clamp(0, 86400);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Icon(Icons.schedule, size: 20),
            const SizedBox(width: 10),
            const Expanded(child: Text('Batas waktu pembayaran')),
            Text(
              '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
