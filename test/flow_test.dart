import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:warung_dhiesna/app.dart';
import 'package:warung_dhiesna/providers/cart_provider.dart';
import 'package:warung_dhiesna/providers/order_provider.dart';
import 'package:warung_dhiesna/providers/payment_provider.dart';
import 'package:warung_dhiesna/models/payment_model.dart';
import 'package:warung_dhiesna/screens/home/home_screen.dart';
import 'package:warung_dhiesna/screens/payment/payment_method_screen.dart';
import 'package:warung_dhiesna/services/mock_payment_service.dart';
import 'package:warung_dhiesna/widgets/checkout_bottom_bar.dart';
import 'package:warung_dhiesna/widgets/food_card.dart';

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      250,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await tester.pumpAndSettle();
  await Scrollable.ensureVisible(tester.element(finder), alignment: 0.5);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

void main() {
  WidgetController.hitTestWarningShouldBeFatal = true;
  for (final width in [320.0, 390.0, 430.0]) {
    testWidgets(
      'cash flow, edit, validation and all tracking stages at $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.runAsync(() async {
          await tester.pumpWidget(DhiesnaApp(now: tester.binding.clock.now));
          final context = tester.element(find.byType(Scaffold).first);
          for (final path in [
            'assets/images/splash/splash_logo.png',
            'assets/images/restaurant/header.png',
            'assets/images/restaurant/delivery.png',
          ]) {
            if (context.mounted) {
              await precacheImage(AssetImage(path), context);
            }
          }
        });
        await tester.pumpAndSettle();
        expect(find.byType(HomeScreen), findsOneWidget);
        final cart = tester
            .element(find.byType(HomeScreen))
            .read<CartProvider>();
        await tapVisible(tester, find.byType(FoodCard).first);
        await tapVisible(tester, find.byTooltip('Tambah jumlah').first);
        await tester.enterText(find.byType(TextField), 'Pedas sedang');
        await tapVisible(tester, find.text('Tambah Pesanan'));
        expect(cart.subtotal, 42000);
        await tapVisible(tester, find.text('PESAN (2)'));
        await tapVisible(tester, find.text('ubah'));
        expect(find.text('Pedas sedang'), findsOneWidget);
        await tapVisible(tester, find.text('Simpan Perubahan'));
        await tapVisible(tester, find.text('PESAN'));
        // Checkout: total hanya di bar bawah, tanpa kartu Detail Pembayaran.
        expect(find.text('Detail Pembayaran'), findsNothing);
        expect(
          find.descendant(
            of: find.byType(CheckoutBottomBar),
            matching: find.text('Rp42.000'),
          ),
          findsOneWidget,
        );
        await tapVisible(tester, find.text('Lanjutkan ke Pembayaran'));
        await tapVisible(tester, find.text('Lanjutkan →'));
        expect(find.text('Nama wajib diisi'), findsOneWidget);
        // Lokasi kosong untuk pesanan baru dan wajib diisi.
        expect(find.text('Lokasi pengantaran wajib diisi'), findsOneWidget);
        expect(find.textContaining('Meja 04'), findsNothing);
        await tester.enterText(find.byType(TextFormField).at(0), 'Nandana');
        await tester.enterText(
          find.byType(TextFormField).at(1),
          '081234567890',
        );
        await tester.enterText(
          find.byType(TextFormField).at(2),
          'Kamar 204, lantai 2',
        );
        await tapVisible(tester, find.text('Tunai di Tempat'));
        await tapVisible(tester, find.text('Lanjutkan →'));
        // Kembali dari pembayaran: isian lokasi tidak hilang.
        await tapVisible(tester, find.byIcon(Icons.arrow_back));
        expect(find.text('Kamar 204, lantai 2'), findsOneWidget);
        await tapVisible(tester, find.text('Lanjutkan →'));
        await tapVisible(tester, find.text('Pesan Sekarang'));
        expect(find.text('Ringkasan Pesanan'), findsOneWidget);
        final orders = tester
            .element(find.text('Ringkasan Pesanan'))
            .read<OrderProvider>();
        // Tanpa ongkir/biaya layanan: total = subtotal makanan.
        expect(orders.orders.single.checkout.total, 42000);
        expect(orders.orders.single.customer.address, 'Kamar 204, lantai 2');
        expect(find.textContaining('Kamar 204, lantai 2'), findsWidgets);
        expect(find.text('Catatan: Pedas sedang'), findsOneWidget);
        expect(find.textContaining('Lengkap dengan sambel'), findsNothing);
        expect(
          orders.orders.single.payment.status,
          PaymentStatus.awaitingCashPayment,
        );
        expect(cart.items, isEmpty);
        expect(find.text('Menunggu Pembayaran Tunai'), findsOneWidget);
        await tapVisible(tester, find.text('Lihat status pesanan'));
        expectNoDevControls();
        // Tracking maju sendiri setiap 5 detik, tanpa tombol.
        await expectAutoTracking(tester);
        expect(
          orders.orders.single.payment.status,
          PaymentStatus.awaitingCashPayment,
        );
        await tapVisible(tester, find.text('Pesan Lagi'));
        expect(find.byType(HomeScreen), findsOneWidget);
      },
    );
  }
  testWidgets('QRIS: Cek Status -> ringkasan -> tracking sampai selesai', (
    tester,
  ) async {
    final p = await openQris(tester);
    expectNoDevControls();
    expect(
      find.image(const AssetImage('assets/images/payment/qris.jpg')),
      findsOneWidget,
    );
    // Keterangan simulasi ada di Detail Pembayaran, bukan di bawah gambar.
    final note = find.text('Pembayaran simulasi untuk presentasi');
    expect(note, findsOneWidget);
    expect(
      tester.getTopLeft(note).dy,
      greaterThan(tester.getTopLeft(find.text('Detail Pembayaran')).dy),
    );
    // Gangguan jaringan: tetap di halaman QRIS dan bisa coba lagi.
    (p.service as MockPaymentService).failNextCheck = true;
    await tapVisible(tester, find.text('Cek Status Pembayaran'));
    expect(p.error, isNotNull);
    expect(find.text('Ringkasan Pesanan'), findsNothing);
    // Cek Status menjalankan simulasi berhasil lewat MockPaymentService.
    await tapVisible(tester, find.text('Coba Lagi'));
    expect(find.text('Ringkasan Pesanan'), findsOneWidget);
    expect(find.text('Lunas via QRIS'), findsOneWidget);
    final orders = tester
        .element(find.text('Ringkasan Pesanan'))
        .read<OrderProvider>();
    final order = orders.orders.single;
    expect(order.payment.amount, 21000);
    expect(order.checkout.total, 21000);
    expect(order.customer.address, 'Kamar 101');
    // Tracking belum berjalan sebelum halaman Status Pesanan dibuka.
    await tester.pump(const Duration(minutes: 1));
    await tapVisible(tester, find.text('Lihat status pesanan'));
    expect(find.text('Pesanan Dikonfirmasi'), findsWidgets);
    expect(find.text('00:15'), findsOneWidget);
    // Keluar lalu buka lagi: countdown melanjutkan, tidak mulai dari awal.
    await tester.pump(const Duration(seconds: 2));
    final leftBefore = orders.secondsLeft(order.id)!;
    await tapVisible(tester, find.byIcon(Icons.arrow_back));
    await tester.pump(const Duration(seconds: 3));
    await tapVisible(tester, find.text('Lihat status pesanan'));
    final leftAfter = orders.secondsLeft(order.id)!;
    expect(leftAfter, lessThanOrEqualTo(leftBefore - 3));
    expect(find.text('00:15'), findsNothing);
    expect(find.text('Pesanan Dikonfirmasi'), findsWidgets);
    expect(
      find.text('00:${leftAfter.toString().padLeft(2, '0')}'),
      findsOneWidget,
    );
    await tester.pump(Duration(seconds: leftAfter));
    await tester.pumpAndSettle();
    expect(find.text('Sedang Disiapkan'), findsWidgets);
    expect(find.text('00:15'), findsOneWidget);
    await tester.pump(const Duration(seconds: 45));
    await tester.pumpAndSettle();
    expect(find.text('Pesanan Selesai'), findsWidgets);
    expect(find.text('Pesan Lagi'), findsOneWidget);
    // Dibuka lagi setelah selesai: tetap Selesai, tanpa countdown.
    await tapVisible(tester, find.byIcon(Icons.arrow_back));
    await tapVisible(tester, find.text('Lihat status pesanan'));
    expect(find.text('Pesanan Selesai'), findsWidgets);
    expect(find.text('Tahap berikutnya dalam'), findsNothing);
    expect(orders.orders, hasLength(1));
    await tapVisible(tester, find.text('Pesan Lagi'));
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('QRIS expired ends the transaction without creating an order', (
    tester,
  ) async {
    final p = await openQris(tester);
    (p.service as MockPaymentService).simulate(
      p.transaction!.id,
      PaymentStatus.expired,
    );
    await tapVisible(tester, find.text('Cek Status Pembayaran'));
    expect(p.transaction!.status, PaymentStatus.expired);
    expect(find.textContaining('sudah berakhir'), findsOneWidget);
    final orders = tester
        .element(find.text('Pembayaran QRIS'))
        .read<OrderProvider>();
    expect(orders.orders, isEmpty);
    // Ganti metode kembali ke Data Pesanan dengan isian tetap ada.
    await tapVisible(tester, find.text('Ganti Metode Pembayaran'));
    expect(find.text('Kamar 101'), findsOneWidget);
  });
}

// Mulai dari Pesanan Dikonfirmasi, countdown 00:15 turun tiap detik,
// lalu tiap tahap 15 detik berurutan sampai selesai.
Future<void> expectAutoTracking(WidgetTester tester) async {
  expect(find.text('Pesanan Dikonfirmasi'), findsWidgets);
  expect(find.text('00:15'), findsOneWidget);
  await tester.pump(const Duration(seconds: 1));
  expect(find.text('00:14'), findsOneWidget);
  await tester.pump(const Duration(seconds: 13));
  expect(find.text('00:01'), findsOneWidget);
  expect(find.text('Pesanan Dikonfirmasi'), findsWidgets);
  for (final label in ['Sedang Disiapkan', 'Sedang Diantar']) {
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text(label), findsWidgets);
    expect(find.text('00:15'), findsOneWidget);
    await tester.pump(const Duration(seconds: 14));
  }
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
  // Tepat 45 detik: Sedang Diantar langsung jadi Selesai (tanpa tahap Tiba),
  // countdown hilang, Pesan Lagi langsung muncul.
  expect(find.text('Pesanan Selesai'), findsWidgets);
  expect(find.text('Pesanan Tiba'), findsNothing);
  expect(find.textContaining('00:'), findsNothing);
  expect(find.text('Tahap berikutnya dalam'), findsNothing);
  expect(find.text('Pesan Lagi'), findsOneWidget);
  await tester.pump(const Duration(minutes: 1));
  expect(find.text('Pesanan Selesai'), findsWidgets);
}

// Buka halaman QRIS lewat alur pelanggan yang asli.
Future<PaymentProvider> openQris(WidgetTester tester) async {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.runAsync(() async {
    await tester.pumpWidget(DhiesnaApp(now: tester.binding.clock.now));
    final context = tester.element(find.byType(Scaffold).first);
    for (final path in [
      'assets/images/splash/splash_logo.png',
      'assets/images/restaurant/header.png',
      'assets/images/restaurant/delivery.png',
    ]) {
      if (context.mounted) {
        await precacheImage(AssetImage(path), context);
      }
    }
  });
  await tester.pumpAndSettle();
  await tapVisible(tester, find.byType(FoodCard).first);
  await tapVisible(tester, find.text('Tambah Pesanan'));
  await tapVisible(tester, find.text('PESAN (1)'));
  await tapVisible(tester, find.text('PESAN'));
  await tapVisible(tester, find.text('Lanjutkan ke Pembayaran'));
  final p = tester
      .element(find.byType(PaymentMethodScreen))
      .read<PaymentProvider>();
  await tester.enterText(find.byType(TextFormField).at(0), 'Budi');
  await tester.enterText(find.byType(TextFormField).at(1), '+6281234567890');
  await tester.enterText(find.byType(TextFormField).at(2), 'Kamar 101');
  await tapVisible(tester, find.text('Lanjutkan →'));
  return p;
}

void expectNoDevControls() {
  for (final label in [
    'MODE DEMO',
    'Simulasi',
    'Lanjut:',
    'success',
    'failed',
    'expired',
    'Error jaringan',
  ]) {
    expect(find.textContaining(label), findsNothing, reason: label);
  }
}
