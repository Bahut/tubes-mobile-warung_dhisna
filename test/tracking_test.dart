import 'package:flutter_test/flutter_test.dart';
import 'package:warung_dhiesna/data/mock_food_data.dart';
import 'package:warung_dhiesna/models/cart_item_model.dart';
import 'package:warung_dhiesna/models/order_model.dart';
import 'package:warung_dhiesna/models/payment_model.dart';
import 'package:warung_dhiesna/providers/order_provider.dart';
import 'package:warung_dhiesna/services/mock_payment_service.dart';

Future<OrderModel> mockOrder(
  MockPaymentService service,
  PaymentMethod method, {
  String id = 'WBD-1',
}) async {
  var payment = await service.create(
    orderId: id,
    amount: 21000,
    method: method,
  );
  // QRIS: Cek Status dulu (simulasi berhasil) sebelum jadi pesanan.
  if (method == PaymentMethod.qris) {
    payment = (await service.check(payment.id)).transaction!;
  }
  return OrderModel(
    id: id,
    checkout: CheckoutSnapshot([
      CartItemModel(id: '1', food: mockFoods.first, note: 'Sambal dipisah'),
    ]),
    customer: const CustomerInformation(
      name: 'Budi',
      phone: '081234567890',
      address: 'Kamar 204',
    ),
    payment: payment,
  );
}

void main() {
  testWidgets('Tracking baru mulai saat dibuka, 15 detik per tahap', (
    tester,
  ) async {
    final orders = OrderProvider(now: tester.binding.clock.now);
    final order = await tester.runAsync(
      () => mockOrder(MockPaymentService(), PaymentMethod.cash),
    );
    orders.confirm(order!);
    orders.confirm(order); // konfirmasi ganda tidak membuat pesanan kedua
    expect(orders.orders, hasLength(1));
    // Belum dibuka: tidak ada countdown, status tidak maju.
    await tester.pump(const Duration(minutes: 2));
    expect(orders.getById('WBD-1').status, OrderStatus.confirmed);
    expect(orders.secondsLeft('WBD-1'), isNull);

    orders.startTracking('WBD-1');
    expect(orders.secondsLeft('WBD-1'), 15);
    await tester.pump(const Duration(seconds: 1));
    expect(orders.secondsLeft('WBD-1'), 14);
    // Membuka halaman lagi tidak mereset atau menggandakan timer.
    orders.startTracking('WBD-1');
    orders.startTracking('WBD-1');
    await tester.pump(const Duration(seconds: 13));
    expect(orders.secondsLeft('WBD-1'), 1);
    expect(orders.getById('WBD-1').status, OrderStatus.confirmed);
    for (final status in [
      OrderStatus.preparing,
      OrderStatus.delivering,
      OrderStatus.completed,
    ]) {
      await tester.pump(const Duration(seconds: 1));
      expect(orders.getById('WBD-1').status, status);
      await tester.pump(const Duration(seconds: 14));
    }
    expect(orders.secondsLeft('WBD-1'), isNull);
    await tester.pump(const Duration(minutes: 1));
    expect(orders.getById('WBD-1').status, OrderStatus.completed);
    // Progres pesanan tidak membuat pembayaran tunai lunas.
    expect(
      orders.getById('WBD-1').payment.status,
      PaymentStatus.awaitingCashPayment,
    );
    orders.dispose();
  });

  testWidgets('Pesanan baru tidak mengubah progres pesanan lama', (
    tester,
  ) async {
    final service = MockPaymentService(payOnCheck: true);
    final orders = OrderProvider(now: tester.binding.clock.now);
    final first = await tester.runAsync(
      () => mockOrder(service, PaymentMethod.qris, id: 'A'),
    );
    orders.confirm(first!);
    orders.startTracking('A');
    await tester.pump(const Duration(seconds: 20));
    final second = await tester.runAsync(
      () => mockOrder(service, PaymentMethod.cash, id: 'B'),
    );
    orders.confirm(second!);
    orders.startTracking('B');
    expect(orders.getById('A').status, OrderStatus.preparing);
    expect(orders.secondsLeft('A'), 10);
    expect(orders.getById('B').status, OrderStatus.confirmed);
    expect(orders.secondsLeft('B'), 15);
    await tester.pump(const Duration(seconds: 10));
    expect(orders.getById('A').status, OrderStatus.delivering);
    expect(orders.getById('B').status, OrderStatus.confirmed);
    expect(orders.secondsLeft('B'), 5);
    orders.dispose();
  });

  testWidgets('Kembali dari background: sisa waktu dihitung dari timestamp', (
    tester,
  ) async {
    var now = DateTime(2026, 1, 1, 12);
    final orders = OrderProvider(now: () => now);
    final order = await tester.runAsync(
      () => mockOrder(MockPaymentService(), PaymentMethod.cash),
    );
    orders.confirm(order!);
    orders.startTracking('WBD-1');
    // Aplikasi di background 41 detik: timer tidak berjalan sama sekali.
    now = now.add(const Duration(seconds: 41));
    expect(orders.secondsLeft('WBD-1'), 4);
    // Tick pertama setelah kembali langsung menampilkan tahap yang benar.
    await tester.pump(const Duration(seconds: 1));
    expect(orders.getById('WBD-1').status, OrderStatus.delivering);
    // Membuka halaman lagi tidak mengulang dari awal.
    orders.startTracking('WBD-1');
    expect(orders.secondsLeft('WBD-1'), 4);
    // Lewat dari 45 detik: Selesai, countdown hilang, timer berhenti.
    now = now.add(const Duration(minutes: 5));
    await tester.pump(const Duration(seconds: 1));
    expect(orders.getById('WBD-1').status, OrderStatus.completed);
    expect(orders.secondsLeft('WBD-1'), isNull);
    expect(
      orders.getById('WBD-1').payment.status,
      PaymentStatus.awaitingCashPayment,
    );
    orders.dispose();
  });

  testWidgets('Setelah Sedang Diantar langsung Pesanan Selesai di detik 45', (
    tester,
  ) async {
    var now = DateTime(2026, 1, 1, 12);
    final orders = OrderProvider(now: () => now);
    final order = await tester.runAsync(
      () => mockOrder(MockPaymentService(), PaymentMethod.cash),
    );
    orders.confirm(order!);
    orders.startTracking('WBD-1');
    now = now.add(const Duration(seconds: 44));
    await tester.pump(const Duration(seconds: 1));
    expect(orders.getById('WBD-1').status, OrderStatus.delivering);
    expect(orders.secondsLeft('WBD-1'), 1);
    now = now.add(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(orders.getById('WBD-1').status, OrderStatus.completed);
    expect(orders.secondsLeft('WBD-1'), isNull);
    // Timer sudah berhenti: waktu berjalan tidak mengubah apa pun lagi.
    now = now.add(const Duration(minutes: 5));
    await tester.pump(const Duration(minutes: 5));
    expect(orders.getById('WBD-1').status, OrderStatus.completed);
    orders.dispose();
  });

  test(
    'Cek Status QRIS berhasil tanpa mengubah nominal; tunai tetap belum lunas',
    () async {
      final service = MockPaymentService(payOnCheck: true);
      final qris = await service.create(
        orderId: 'q',
        amount: 26000,
        method: PaymentMethod.qris,
      );
      expect(qris.status, PaymentStatus.pending);
      final paid = (await service.check(qris.id)).transaction!;
      expect(paid.status, PaymentStatus.success);
      expect(paid.amount, 26000);
      final cash = await service.create(
        orderId: 'c',
        amount: 5000,
        method: PaymentMethod.cash,
      );
      expect(
        (await service.check(cash.id)).transaction!.status,
        PaymentStatus.awaitingCashPayment,
      );
    },
  );

  test('QRIS kedaluwarsa tidak berubah jadi berhasil saat dicek', () async {
    var now = DateTime(2026, 1, 1, 12);
    final service = MockPaymentService(now: () => now, payOnCheck: true);
    final qris = await service.create(
      orderId: 'q',
      amount: 21000,
      method: PaymentMethod.qris,
    );
    now = now.add(const Duration(minutes: 16));
    expect(
      (await service.check(qris.id)).transaction!.status,
      PaymentStatus.expired,
    );
  });

  test(
    'QRIS belum dibayar tidak bisa jadi pesanan, jadi tracking belum mulai',
    () async {
      final service = MockPaymentService();
      final payment = await service.create(
        orderId: 'p',
        amount: 21000,
        method: PaymentMethod.qris,
      );
      final orders = OrderProvider();
      expect(
        () => orders.confirm(
          OrderModel(
            id: 'p',
            checkout: CheckoutSnapshot([
              CartItemModel(id: '1', food: mockFoods.first),
            ]),
            customer: const CustomerInformation(
              name: 'Budi',
              phone: '081234567890',
              address: 'Kamar 204',
            ),
            payment: payment,
          ),
        ),
        throwsStateError,
      );
      expect(orders.orders, isEmpty);
      orders.dispose();
    },
  );
}
