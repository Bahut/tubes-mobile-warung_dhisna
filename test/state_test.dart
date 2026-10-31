import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warung_dhiesna/data/mock_food_data.dart';
import 'package:warung_dhiesna/models/cart_item_model.dart';
import 'package:warung_dhiesna/models/food_model.dart';
import 'package:warung_dhiesna/models/order_model.dart';
import 'package:warung_dhiesna/models/payment_model.dart';
import 'package:warung_dhiesna/providers/cart_provider.dart';
import 'package:warung_dhiesna/providers/order_provider.dart';
import 'package:warung_dhiesna/providers/payment_provider.dart';
import 'package:warung_dhiesna/services/mock_payment_service.dart';
import 'package:warung_dhiesna/widgets/order_item_tile.dart';

void main() {
  FoodModel food(String id) => mockFoods.firstWhere((f) => f.id == id);

  test('Total tanpa biaya tambahan: nasi ayam + es teh = Rp26.000', () {
    final cart = CartProvider()
      ..save(CartItemModel(id: '1', food: food('nasi_ayam')))
      ..save(CartItemModel(id: '2', food: food('es_teh')));
    expect(cart.subtotal, 26000);
    expect(cart.snapshot().total, 26000);
  });

  testWidgets('Rincian pesanan hanya menampilkan catatan pelanggan', (
    tester,
  ) async {
    Future<void> show(String note) => tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OrderItemTile(
            item: CartItemModel(id: '1', food: food('es_teh'), note: note),
          ),
        ),
      ),
    );
    await show('');
    expect(find.textContaining('Catatan'), findsNothing);
    expect(find.text('Es teh ukuran besar'), findsNothing);
    await show('   ');
    expect(find.textContaining('Catatan'), findsNothing);
    await show(' Es sedikit ');
    expect(find.text('Catatan: Es sedikit'), findsOneWidget);
    expect(find.text('Es teh ukuran besar'), findsNothing);
  });

  test('Menu asli: 44 menu, 7 kategori, id unik, harga sesuai', () {
    expect(mockFoods.length, 44);
    expect(foodCategories.length, 7);
    expect(mockFoods.map((food) => food.id).toSet().length, 44);
    expect(mockFoods.map((food) => food.image).toSet().length, 44);
    expect(mockFoods.every((f) => foodCategories.contains(f.category)), isTrue);
    final counts = [
      for (final c in foodCategories)
        mockFoods.where((f) => f.category == c).length,
    ];
    expect(counts, [9, 8, 5, 4, 6, 5, 7]);
    final total = mockFoods.fold<int>(0, (sum, food) => sum + food.price);
    expect(total, 524000);
  });
  test('Different items and orders stay separate when one is edited', () async {
    final cart = CartProvider();
    cart.save(CartItemModel(id: 'rice', food: mockFoods[0]));
    cart.save(CartItemModel(id: 'chicken', food: mockFoods[1]));
    cart.save(cart.items.first.copyWith(quantity: 2));
    expect(cart.items.length, 2);
    expect(cart.subtotal, 63000);
    expect(cart.items.last.quantity, 1);
    final orders = OrderProvider();
    final service = MockPaymentService();
    for (final orderId in ['first', 'second']) {
      final payment = await service.create(
        orderId: orderId,
        amount: cart.snapshot().total,
        method: PaymentMethod.cash,
      );
      orders.confirm(
        OrderModel(
          id: orderId,
          checkout: cart.snapshot(),
          customer: const CustomerInformation(
            name: 'Budi',
            phone: '081234567890',
            address: 'Meja 04',
          ),
          payment: payment,
        ),
      );
    }
    expect(orders.orders.length, 2);
    orders.advance('second');
    expect(orders.getById('first').status, OrderStatus.confirmed);
    expect(orders.getById('second').status, OrderStatus.preparing);
  });
  test(
    'Options, quantity, editing and immutable checkout use the same total',
    () {
      const food = FoodModel(
        id: 'nasi_test',
        name: 'Nasi test',
        description: '',
        price: 28000,
        category: 'Paket Nasi',
        options: [
          FoodOption('telur', 'Telur tambahan', 5000),
          FoodOption('ayam', 'Ayam suwir', 7000),
        ],
      );
      final cart = CartProvider();
      cart.save(
        CartItemModel(
          id: '1',
          food: food,
          quantity: 2,
          options: {'telur': 1},
          note: 'Pedas',
        ),
      );
      expect(cart.subtotal, 66000);
      final snapshot = cart.snapshot(note: 'Antar ke meja');
      expect(snapshot.total, 66000);
      cart.changeQuantity('1', 3);
      expect(cart.subtotal, 99000);
      expect(snapshot.total, 66000);
      expect(snapshot.items.single.note, 'Pedas');
      expect(() => snapshot.items.clear(), throwsUnsupportedError);
      cart.save(
        cart.items.single.copyWith(options: {'ayam': 1}, note: 'Tanpa acar'),
      );
      expect(cart.subtotal, 105000);
      cart.changeQuantity('1', 0);
      expect(cart.items, isEmpty);
      expect(() => cart.snapshot(), throwsArgumentError);
      expect(
        () => CartItemModel(id: 'bad', food: food, quantity: 0),
        throwsArgumentError,
      );
      expect(
        () => CartItemModel(id: 'bad', food: food, options: {'unknown': 1}),
        throwsArgumentError,
      );
    },
  );
  test(
    'QRIS idempotency, pending checks, retry, success and terminal states',
    () async {
      var now = DateTime(2026, 10, 31, 12);
      final service = MockPaymentService(now: () => now);
      final p = PaymentProvider(service);
      final first = p.create('order1', 30000, PaymentMethod.qris);
      expect(await p.create('order1', 30000, PaymentMethod.qris), isFalse);
      expect(await first, isTrue);
      final t = p.transaction!;
      expect(
        await service.create(
          orderId: 'order1',
          amount: 30000,
          method: PaymentMethod.qris,
        ),
        same(t),
      );
      await p.check();
      expect(p.transaction!.status, PaymentStatus.pending);
      service.failNextCheck = true;
      await p.check();
      expect(p.error, isNotNull);
      await p.check();
      expect(p.error, isNull);
      service.simulate(t.id, PaymentStatus.success);
      await p.check();
      expect(p.transaction!.status, PaymentStatus.success);
      service.simulate(t.id, PaymentStatus.pending);
      now = now.add(const Duration(hours: 1));
      await p.check();
      expect(p.transaction!.status, PaymentStatus.success);
    },
  );
  test(
    'Expiry follows transaction time; cash and order progress stay separate',
    () async {
      var now = DateTime(2026);
      final service = MockPaymentService(now: () => now);
      final qris = await service.create(
        orderId: 'q',
        amount: 30000,
        method: PaymentMethod.qris,
      );
      now = now.add(const Duration(minutes: 15));
      expect(
        (await service.check(qris.id)).transaction!.status,
        PaymentStatus.expired,
      );
      final cart = CartProvider()
        ..save(CartItemModel(id: '1', food: mockFoods.first));
      final orders = OrderProvider();
      const customer = CustomerInformation(
        name: 'Nandana',
        phone: '081234567890',
        address: 'Meja 04',
      );
      expect(
        () => orders.confirm(
          OrderModel(
            id: 'q',
            checkout: cart.snapshot(),
            customer: customer,
            payment: qris,
          ),
        ),
        throwsStateError,
      );
      final cash = await service.create(
        orderId: 'c',
        amount: cart.snapshot().total,
        method: PaymentMethod.cash,
      );
      final order = OrderModel(
        id: 'c',
        checkout: cart.snapshot(),
        customer: customer,
        payment: cash,
      );
      orders.confirm(order);
      orders.confirm(order);
      expect(orders.orders.length, 1);
      for (final stage in OrderStatus.values.skip(1)) {
        orders.advance('c');
        expect(orders.getById('c').status, stage);
        expect(
          orders.getById('c').payment.status,
          PaymentStatus.awaitingCashPayment,
        );
      }
      orders.advance('c');
      expect(orders.getById('c').status, OrderStatus.completed);
      orders.confirmCash('c');
      expect(orders.getById('c').payment.status, PaymentStatus.success);
    },
  );
  test(
    'Failed and expired attempts never become paid through checks',
    () async {
      for (final status in [PaymentStatus.failed, PaymentStatus.expired]) {
        final service = MockPaymentService();
        final t = await service.create(
          orderId: status.name,
          amount: 30000,
          method: PaymentMethod.qris,
        );
        service.simulate(t.id, status);
        service.simulate(t.id, PaymentStatus.success);
        expect((await service.check(t.id)).transaction!.status, status);
      }
    },
  );
}
