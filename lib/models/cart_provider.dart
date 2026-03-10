import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String name;
  final double price;
  final String restaurantName;
  final String image;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.restaurantName,
    this.image = '',
    this.quantity = 1,
  });
}

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  int get itemCount {
    int total = 0;
    _items.forEach((key, item) {
      total += item.quantity;
    });
    return total;
  }

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, item) {
      total += item.price * item.quantity;
    });
    return total;
  }

  double get deliveryFee => totalAmount > 0 ? 40.0 : 0.0;

  double get taxAmount => totalAmount * 0.05;

  double get grandTotal => totalAmount + deliveryFee + taxAmount;

  String get restaurantName {
    if (_items.isEmpty) return '';
    return _items.values.first.restaurantName;
  }

  void addItem(String name, double price, String restaurantName, {String image = ''}) {
    final id = '${restaurantName}_$name';
    if (_items.containsKey(id)) {
      _items[id]!.quantity += 1;
    } else {
      _items[id] = CartItem(
        id: id,
        name: name,
        price: price,
        restaurantName: restaurantName,
        image: image,
      );
    }
    notifyListeners();
  }

  void removeItem(String id) {
    _items.remove(id);
    notifyListeners();
  }

  void decrementItem(String id) {
    if (!_items.containsKey(id)) return;
    if (_items[id]!.quantity > 1) {
      _items[id]!.quantity -= 1;
    } else {
      _items.remove(id);
    }
    notifyListeners();
  }

  void incrementItem(String id) {
    if (!_items.containsKey(id)) return;
    _items[id]!.quantity += 1;
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  static double parsePrice(String priceStr) {
    final cleaned = priceStr.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }
}
