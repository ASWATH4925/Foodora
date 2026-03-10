import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swiggy_ui/models/cart_provider.dart';
import 'package:swiggy_ui/models/restaurant_detail.dart';
import 'package:swiggy_ui/models/spotlight_best_top_food.dart';
import 'package:swiggy_ui/utils/app_colors.dart';
import 'package:swiggy_ui/widgets/veg_badge_view.dart';

class CategoryDishesScreen extends StatelessWidget {
  final String categoryName;

  const CategoryDishesScreen({Key? key, required this.categoryName})
      : super(key: key);

  /// Maps category display names to search keywords.
  static List<String> _keywordsFor(String category) {
    final lower = category.toLowerCase().replaceAll('\n', ' ').trim();
    final map = {
      'cold beverages': ['cold coffee', 'iced tea', 'shake', 'lassi', 'juice', 'kokum', 'buttermilk', 'cold'],
      'veg only': ['veg', 'paneer', 'gobi', 'aloo', 'dal', 'palak', 'matar', 'veg thali', 'veg meals', 'uttapam'],
      'only on foodora': ['special', 'express', 'combo'],
      'offers': ['off', 'combo', 'deal'],
      'meals': ['meal', 'thali', 'rice', 'sambar rice', 'curd rice', 'full meals', 'mini meals'],
      'milkshakes': ['shake', 'milkshake', 'lassi', 'badam milk', 'mango shake'],
      'kawaii sushi': ['sushi', 'japanese', 'roll'],
      'bread': ['bread', 'naan', 'roti', 'paratha', 'parotta', 'pav', 'bun'],
    };
    return map[lower] ?? [lower.replaceAll(' ', '')];
  }

  @override
  Widget build(BuildContext context) {
    final keywords = _keywordsFor(categoryName);
    final allRestaurants = <SpotlightBestTopFood>[
      ...SpotlightBestTopFood.getPopularAllRestaurants(),
      ...SpotlightBestTopFood.getAllRestaurantsNearby(),
      ...SpotlightBestTopFood.getSpotlightRestaurants().expand((l) => l),
      ...SpotlightBestTopFood.getBestRestaurants().expand((l) => l),
      ...SpotlightBestTopFood.getTopRestaurants().expand((l) => l),
    ];

    // Deduplicate
    final seen = <String>{};
    final unique = <SpotlightBestTopFood>[];
    for (final r in allRestaurants) {
      if (!seen.contains(r.name)) {
        seen.add(r.name);
        unique.add(r);
      }
    }

    // Search menus for matching dishes
    final results = <_RestaurantDishes>[];
    for (final r in unique) {
      final menus = RestaurantDetail.getMenusFor(r.name);
      final matched = <RestaurantDetail>[];
      for (final menuList in menus) {
        for (final dish in menuList) {
          final title = dish.title.toLowerCase();
          final desc = dish.desc.toLowerCase();
          for (final kw in keywords) {
            if (title.contains(kw) || desc.contains(kw)) {
              matched.add(dish);
              break;
            }
          }
        }
      }
      if (matched.isNotEmpty) {
        results.add(_RestaurantDishes(restaurant: r, dishes: matched));
      }
    }

    final cleanName = categoryName.replaceAll('\n', ' ').trim();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(cleanName),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: results.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 70, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('No $cleanName dishes found',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Text('Try another category',
                      style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: results.length,
              itemBuilder: (context, index) {
                final rd = results[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Restaurant header
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.deepOrange.shade50,
                              Colors.white,
                            ],
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(14),
                            topRight: Radius.circular(14),
                          ),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                rd.restaurant.image,
                                height: 40,
                                width: 40,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    rd.restaurant.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    rd.restaurant.desc,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Dishes
                      ...rd.dishes.map((dish) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                    color: Colors.grey[200]!, width: 0.5),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const VegBadgeView(),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        dish.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        dish.price,
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 13,
                                        ),
                                      ),
                                      if (dish.desc.isNotEmpty)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 4),
                                          child: Text(
                                            dish.desc,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () {
                                    final price =
                                        CartProvider.parsePrice(dish.price);
                                    Provider.of<CartProvider>(context,
                                            listen: false)
                                        .addItem(dish.title, price,
                                            rd.restaurant.name);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            '${dish.title} added to cart!'),
                                        duration: const Duration(seconds: 1),
                                        backgroundColor: Colors.green[700],
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 6, horizontal: 20),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'ADD',
                                      style: TextStyle(
                                        color: darkOrange,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _RestaurantDishes {
  final SpotlightBestTopFood restaurant;
  final List<RestaurantDetail> dishes;

  _RestaurantDishes({required this.restaurant, required this.dishes});
}
