import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/order_model.dart';
import '../models/payment_model.dart';

class OrderProvider extends ChangeNotifier {
  // now bisa diganti di test agar waktu bisa dimajukan.
  OrderProvider({DateTime Function()? now}) : _now = now ?? DateTime.now;
  final DateTime Function() _now;

  // Simulasi tracking tanpa backend: 3 tahap x 15 detik = 45 detik, lalu Selesai.
  static const stageSeconds = 15;

  final List<OrderModel> _orders = [];
  // Waktu tracking dimulai (halaman status pertama kali dibuka).
  // Status dan sisa waktu dihitung dari timestamp ini, jadi tetap benar
  // walau timer sempat berhenti saat aplikasi di background.
  final Map<String, DateTime> _trackingStartedAt = {};
  // Satu timer untuk semua pesanan, hanya untuk memperbarui tampilan tiap detik.
  Timer? _ticker;

  List<OrderModel> get orders => List.unmodifiable(_orders.reversed);
  OrderModel getById(String id) =>
      _orders.firstWhere((order) => order.id == id);

  void confirm(OrderModel order) {
    if (![
      PaymentStatus.success,
      PaymentStatus.awaitingCashPayment,
    ].contains(order.payment.status)) {
      throw StateError('Pembayaran belum dikonfirmasi');
    }
    if (_orders.any((savedOrder) => savedOrder.id == order.id)) {
      return;
    }
    _orders.add(order);
    notifyListeners();
  }

  // Dipanggil saat halaman Status Pesanan dibuka. Membuka ulang tidak mereset.
  void startTracking(String id) {
    if (_trackingStartedAt.containsKey(id) ||
        getById(id).status == OrderStatus.completed) {
      return;
    }
    _trackingStartedAt[id] = _now();
    _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  int _elapsedSeconds(String id) =>
      _now().difference(_trackingStartedAt[id]!).inSeconds;

  // Sisa detik tahap ini (15..1), atau null jika belum dimulai/sudah selesai.
  int? secondsLeft(String id) {
    if (!_trackingStartedAt.containsKey(id) ||
        getById(id).status == OrderStatus.completed) {
      return null;
    }
    return stageSeconds - _elapsedSeconds(id) % stageSeconds;
  }

  void _tick() {
    for (final id in _trackingStartedAt.keys) {
      // Tahap yang seharusnya berdasarkan waktu berjalan (maks. Selesai).
      final stage = (_elapsedSeconds(id) ~/ stageSeconds).clamp(
        0,
        OrderStatus.values.length - 1,
      );
      // Maju satu per satu sampai tahap itu; tidak pernah mundur.
      while (getById(id).status.index < stage) {
        _nextStatus(id);
      }
    }
    final allDone = _trackingStartedAt.keys.every(
      (id) => getById(id).status == OrderStatus.completed,
    );
    if (allDone) {
      _ticker?.cancel();
      _ticker = null;
    }
    notifyListeners();
  }

  // Khusus pengujian: memajukan status secara manual.
  void advance(String id) {
    if (kDebugMode) {
      _nextStatus(id);
      notifyListeners();
    }
  }

  // Maju satu tahap saja, tanpa mengubah status pembayaran.
  void _nextStatus(String id) {
    final orderIndex = _orders.indexWhere((order) => order.id == id);
    final order = _orders[orderIndex];
    if (order.status.index < OrderStatus.values.length - 1) {
      _orders[orderIndex] = order.copyWith(
        status: OrderStatus.values[order.status.index + 1],
      );
    }
  }

  void confirmCash(String id) {
    if (!kDebugMode) {
      return;
    }
    final orderIndex = _orders.indexWhere((order) => order.id == id);
    final order = _orders[orderIndex];
    if (order.payment.status == PaymentStatus.awaitingCashPayment) {
      _orders[orderIndex] = order.copyWith(
        payment: order.payment.withStatus(PaymentStatus.success),
      );
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
