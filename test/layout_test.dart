import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:warung_dhiesna/data/mock_food_data.dart';
import 'package:warung_dhiesna/models/cart_item_model.dart';
import 'package:warung_dhiesna/models/order_model.dart';
import 'package:warung_dhiesna/models/payment_model.dart';
import 'package:warung_dhiesna/providers/cart_provider.dart';
import 'package:warung_dhiesna/providers/order_provider.dart';
import 'package:warung_dhiesna/providers/payment_provider.dart';
import 'package:warung_dhiesna/services/mock_payment_service.dart';
import 'package:warung_dhiesna/theme/app_theme.dart';
import 'package:warung_dhiesna/widgets/cart_floating_bar.dart';
import 'package:warung_dhiesna/screens/home/home_screen.dart';
import 'package:warung_dhiesna/screens/food/food_detail_screen.dart';
import 'package:warung_dhiesna/screens/cart/cart_screen.dart';
import 'package:warung_dhiesna/screens/checkout/checkout_screen.dart';
import 'package:warung_dhiesna/screens/payment/payment_method_screen.dart';
import 'package:warung_dhiesna/screens/payment/qris_payment_screen.dart';
import 'package:warung_dhiesna/screens/payment/cash_payment_screen.dart';
import 'package:warung_dhiesna/screens/order/order_summary_screen.dart';
import 'package:warung_dhiesna/screens/order/order_status_screen.dart';

void main() {
  setUpAll(() async {
    final flutterRoot =
        Platform.environment['FLUTTER_ROOT'] ?? '/home/bahut/flutter';
    final fonts = <String, List<String>>{
      'PlusJakartaSans': [
        for (final weight in [
          'Regular',
          'Medium',
          'SemiBold',
          'Bold',
          'ExtraBold',
        ])
          'assets/fonts/PlusJakartaSans-$weight.ttf',
      ],
      'MaterialIcons': [
        '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
      ],
    };
    for (final font in fonts.entries) {
      final loader = FontLoader(font.key);
      for (final path in font.value) {
        final file = File(path);
        if (await file.exists()) {
          loader.addFont(file.readAsBytes().then(ByteData.sublistView));
        }
      }
      await loader.load();
    }
  });
  for (final settings in [(390.0, 1.0), (320.0, 1.5)]) {
    testWidgets(
      'All screens render at ${settings.$1}, text scale ${settings.$2}',
      (tester) async {
        tester.view.physicalSize = Size(settings.$1, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final cart = CartProvider()
          ..save(
            CartItemModel(
              id: '1',
              food: mockFoods.first,
              note: 'Pedas sedang, acar dipisah',
            ),
          );
        final checkout = cart.snapshot();
        final payment = PaymentProvider(MockPaymentService());
        await payment.create(
          'WBD-DEMO-001',
          checkout.total,
          PaymentMethod.qris,
        );
        final orders = OrderProvider();
        const customer = CustomerInformation(
          name: 'Nandana',
          phone: '081234567890',
          address: 'Kamar 204, lantai 2',
        );
        orders.confirm(
          OrderModel(
            id: 'WBD-DEMO-001',
            checkout: checkout,
            customer: customer,
            payment: payment.transaction!.withStatus(PaymentStatus.success),
          ),
        );
        final pages = <String, Widget>{
          'home': const HomeScreen(),
          'detail': FoodDetailScreen(food: mockFoods.first),
          'cart': const CartScreen(),
          'checkout': const CheckoutScreen(),
          'customer': PaymentMethodScreen(checkout: checkout),
          'qris': QrisPaymentScreen(checkout: checkout, customer: customer),
          'cash': CashPaymentScreen(checkout: checkout, customer: customer),
          'summary': const OrderSummaryScreen(orderId: 'WBD-DEMO-001'),
          for (final status in OrderStatus.values)
            'status_${status.name}': const OrderStatusScreen(
              orderId: 'WBD-DEMO-001',
            ),
        };
        for (final page in pages.entries) {
          if (page.key.startsWith('status_') &&
              page.key != 'status_confirmed') {
            orders.advance('WBD-DEMO-001');
          }
          final key = GlobalKey();
          await tester.runAsync(() async {
            await tester.pumpWidget(
              MultiProvider(
                providers: [
                  ChangeNotifierProvider.value(value: cart),
                  ChangeNotifierProvider.value(value: payment),
                  ChangeNotifierProvider.value(value: orders),
                ],
                child: MaterialApp(
                  theme: appTheme(),
                  debugShowCheckedModeBanner: false,
                  builder: (context, child) => MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(textScaler: TextScaler.linear(settings.$2)),
                    child: child!,
                  ),
                  home: RepaintBoundary(key: key, child: page.value),
                ),
              ),
            );
            final context = tester.element(find.byType(Scaffold).first);
            for (final asset in [
              'assets/images/restaurant/header.png',
              'assets/images/restaurant/delivery.png',
              'assets/images/payment/qris.jpg',
            ]) {
              if (context.mounted) {
                await precacheImage(AssetImage(asset), context);
              }
            }
          });
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: page.key);
          if (page.key == 'home') {
            expect(
              tester.getSize(find.byType(Scaffold)).height,
              greaterThan(600),
            );
            expect(
              tester.getSize(find.byType(CartFloatingBar)).height,
              lessThan(120),
            );
          }
          if (const bool.fromEnvironment('CAPTURE_PREVIEWS') &&
              settings.$2 == 1) {
            await tester.runAsync(() async {
              final boundary =
                  key.currentContext!.findRenderObject()!
                      as RenderRepaintBoundary;
              final image = await boundary.toImage(pixelRatio: 2);
              final bytes = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );
              final file = File('docs/previews/${page.key}.png');
              await file.parent.create(recursive: true);
              await file.writeAsBytes(bytes!.buffer.asUint8List());
              image.dispose();
            });
          }
          if (page.key == 'customer' || page.key == 'detail') {
            tester.view.viewInsets = const FakeViewPadding(bottom: 300);
            await tester.pumpAndSettle();
            expect(
              tester.takeException(),
              isNull,
              reason: '${page.key} keyboard',
            );
            tester.view.resetViewInsets();
          }
          await tester.pumpWidget(const SizedBox());
        }
        cart.dispose();
        payment.dispose();
        orders.dispose();
      },
    );
  }
}
