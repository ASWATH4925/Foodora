import 'package:flutter/material.dart';

class OrderItem {
  final String name;
  final double price;
  final int quantity;

  OrderItem({
    required this.name,
    required this.price,
    required this.quantity,
  });
}

class PastOrder {
  final String id;
  final String restaurantName;
  final List<OrderItem> items;
  final double totalAmount;
  final DateTime orderDate;
  double rating;
  bool isRated;

  PastOrder({
    required this.id,
    required this.restaurantName,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
    this.rating = 0.0,
    this.isRated = false,
  });

  String get itemsSummary =>
      items.map((i) => '${i.name} x ${i.quantity}').join(', ');

  String get formattedDate {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = orderDate.hour > 12 ? orderDate.hour - 12 : orderDate.hour;
    final amPm = orderDate.hour >= 12 ? 'PM' : 'AM';
    final min = orderDate.minute.toString().padLeft(2, '0');
    return '${months[orderDate.month - 1]} ${orderDate.day}, $hour:$min $amPm';
  }
}

class OrderProvider extends ChangeNotifier {
  final List<PastOrder> _orders = [
    // Default past orders
    PastOrder(
      id: 'default_1',
      restaurantName: 'Sea Emperor',
      items: [OrderItem(name: 'Pepper BBQ', price: 112, quantity: 1)],
      totalAmount: 112,
      orderDate: DateTime(2025, 7, 14, 2, 11),
    ),
    PastOrder(
      id: 'default_2',
      restaurantName: 'Fireflies Restaurant',
      items: [OrderItem(name: 'Chicken Noodles', price: 150, quantity: 1)],
      totalAmount: 150,
      orderDate: DateTime(2025, 7, 10, 14, 30),
    ),
    PastOrder(
      id: 'default_3',
      restaurantName: 'Chai Truck',
      items: [OrderItem(name: 'Milk Tea', price: 30, quantity: 1)],
      totalAmount: 30,
      orderDate: DateTime(2025, 7, 5, 9, 0),
    ),
  ];

  List<PastOrder> get orders => [..._orders];

  // Most recently ordered food names for AI predictions
  List<String> get recentFoodNames {
    final foods = <String>[];
    for (final order in _orders.take(5)) {
      for (final item in order.items) {
        foods.add(item.name);
      }
    }
    return foods;
  }

  // Most ordered restaurants for AI predictions
  List<String> get frequentRestaurants {
    final counts = <String, int>{};
    for (final order in _orders) {
      counts[order.restaurantName] = (counts[order.restaurantName] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(3).map((e) => e.key).toList();
  }

  void addOrder(String restaurantName, List<OrderItem> items, double total) {
    _orders.insert(
      0,
      PastOrder(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        restaurantName: restaurantName,
        items: items,
        totalAmount: total,
        orderDate: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void rateOrder(String orderId, double rating) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      _orders[idx].rating = rating;
      _orders[idx].isRated = true;
      notifyListeners();
    }
  }
}
