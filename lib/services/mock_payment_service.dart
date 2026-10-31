import 'package:flutter/foundation.dart';

import '../models/payment_model.dart';
import 'payment_service.dart';

class MockPaymentService implements PaymentService {
  // payOnCheck: untuk presentasi tanpa backend, "Cek Status" pada QRIS yang
  // masih berlaku langsung dianggap berhasil. Test memakai false (pending asli).
  MockPaymentService({DateTime Function()? now, this.payOnCheck = false})
    : _now = now ?? DateTime.now;
  final DateTime Function() _now;
  final bool payOnCheck;
  final Map<String, PaymentTransaction> _transactions = {};
  bool failNextCheck = false;
  @override
  Future<PaymentTransaction> create({
    required String orderId,
    required int amount,
    required PaymentMethod method,
  }) async {
    if (amount <= 0 || orderId.isEmpty) {
      throw ArgumentError('Transaksi tidak valid');
    }
    final key = '$orderId-${method.name}';
    // Order dan metode yang sama memakai transaksi yang sudah ada.
    return _transactions.putIfAbsent(
      key,
      () => PaymentTransaction(
        id: 'DEMO-$key',
        orderId: orderId,
        amount: amount,
        method: method,
        status: method == PaymentMethod.cash
            ? PaymentStatus.awaitingCashPayment
            : PaymentStatus.pending,
        createdAt: _now(),
        expiresAt: _now().add(const Duration(minutes: 15)),
      ),
    );
  }

  @override
  Future<PaymentResult> check(String transactionId) async {
    if (failNextCheck && kDebugMode) {
      failNextCheck = false;
      return const PaymentResult(
        error: 'Koneksi demo terputus. Silakan coba lagi.',
      );
    }
    final key = _transactions.keys
        .where(
          (transactionKey) =>
              _transactions[transactionKey]!.id == transactionId,
        )
        .firstOrNull;
    if (key == null) {
      return const PaymentResult(error: 'Transaksi tidak ditemukan.');
    }
    var transaction = _transactions[key]!;
    if (transaction.status == PaymentStatus.pending &&
        !_now().isBefore(transaction.expiresAt)) {
      transaction = transaction.withStatus(PaymentStatus.expired);
      _transactions[key] = transaction;
    } else if (payOnCheck && transaction.status == PaymentStatus.pending) {
      // Simulasi: QRIS yang belum kedaluwarsa dianggap sudah dibayar.
      transaction = transaction.withStatus(PaymentStatus.success);
      _transactions[key] = transaction;
    }
    return PaymentResult(transaction: transaction);
  }

  // Khusus widget test, bukan tombol UI.
  void simulate(String id, PaymentStatus status) {
    if (!kDebugMode) {
      return;
    }
    final key = _transactions.keys.firstWhere(
      (transactionKey) => _transactions[transactionKey]!.id == id,
    );
    final current = _transactions[key]!;
    if (current.status != PaymentStatus.pending) {
      return;
    }
    if (![
      PaymentStatus.pending,
      PaymentStatus.success,
      PaymentStatus.failed,
      PaymentStatus.expired,
    ].contains(status)) {
      return;
    }
    _transactions[key] = current.withStatus(
      !_now().isBefore(current.expiresAt) ? PaymentStatus.expired : status,
    );
  }
}
