import 'package:flutter/foundation.dart';

import '../models/cart_item_model.dart';
import '../models/order_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItemModel> _items = [];
  List<CartItemModel> get items => List.unmodifiable(_items);
  String category = 'Paket Nasi';
  int get quantity {
    int totalQuantity = 0;
    for (final item in _items) {
      totalQuantity += item.quantity;
    }
    return totalQuantity;
  }

  int get subtotal {
    int totalPrice = 0;
    for (final item in _items) {
      totalPrice += item.total;
    }
    return totalPrice;
  }

  void selectCategory(String value) {
    category = value;
    notifyListeners();
  }

  void save(CartItemModel item) {
    final index = _items.indexWhere((savedItem) => savedItem.id == item.id);
    if (index < 0) {
      _items.add(item);
    } else {
      _items[index] = item;
    }
    notifyListeners();
  }

  void changeQuantity(String id, int value) {
    if (value < 1) {
      remove(id);
      return;
    }
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(quantity: value);
      notifyListeners();
    }
  }

  void remove(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  CheckoutSnapshot snapshot({String note = ''}) =>
      CheckoutSnapshot(_items, note: note);
  void clear() {
    _items.clear();
    notifyListeners();
  }
}
