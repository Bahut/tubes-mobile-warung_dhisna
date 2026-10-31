import 'package:flutter/foundation.dart';

import '../services/payment_service.dart';
import '../models/payment_model.dart';

class PaymentProvider extends ChangeNotifier {
  PaymentProvider(this.service);
  final PaymentService service;
  PaymentTransaction? transaction;
  bool loading = false;
  String? error;
  Future<bool> create(String orderId, int amount, PaymentMethod method) async {
    // Abaikan klik tambahan selama pembuatan transaksi belum selesai.
    if (loading) {
      return false;
    }
    loading = true;
    error = null;
    notifyListeners();
    try {
      transaction = await service.create(
        orderId: orderId,
        amount: amount,
        method: method,
      );
      return true;
    } catch (_) {
      error = 'Transaksi demo gagal dibuat. Coba lagi.';
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> check() async {
    if (loading || transaction == null) {
      return;
    }
    loading = true;
    error = null;
    notifyListeners();
    try {
      final result = await service.check(transaction!.id);
      error = result.error;
      if (result.transaction != null) {
        transaction = result.transaction;
      }
    } catch (_) {
      error = 'Gagal memeriksa pembayaran. Coba lagi.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
