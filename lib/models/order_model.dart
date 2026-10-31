import 'cart_item_model.dart';
import 'payment_model.dart';

// Tahap "tiba" digabung ke "selesai": setelah diantar langsung selesai.
enum OrderStatus { confirmed, preparing, delivering, completed }

class CustomerInformation {
  const CustomerInformation({
    required this.name,
    required this.phone,
    required this.address,
  });
  final String name, phone, address;
}

// Salinan checkout tidak ikut berubah ketika keranjang diedit.
class CheckoutSnapshot {
  CheckoutSnapshot(List<CartItemModel> items, {this.note = ''})
    : items = List.unmodifiable(items) {
    if (items.isEmpty) {
      throw ArgumentError('Keranjang kosong');
    }
  }
  final List<CartItemModel> items;
  final String note;
  int get subtotal {
    int totalPrice = 0;
    for (final item in items) {
      totalPrice += item.total;
    }
    return totalPrice;
  }

  // Belum ada ongkir atau biaya layanan: total = harga makanan/minuman saja.
  int get total => subtotal;
}

class OrderModel {
  const OrderModel({
    required this.id,
    required this.checkout,
    required this.customer,
    required this.payment,
    this.status = OrderStatus.confirmed,
  });
  final String id;
  final CheckoutSnapshot checkout;
  final CustomerInformation customer;
  final PaymentTransaction payment;
  final OrderStatus status;
  OrderModel copyWith({PaymentTransaction? payment, OrderStatus? status}) =>
      OrderModel(
        id: id,
        checkout: checkout,
        customer: customer,
        payment: payment ?? this.payment,
        status: status ?? this.status,
      );
}
