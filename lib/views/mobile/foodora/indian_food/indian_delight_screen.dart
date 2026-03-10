import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swiggy_ui/models/cart_provider.dart';
import 'package:swiggy_ui/models/restaurant_detail.dart';
import 'package:swiggy_ui/models/spotlight_best_top_food.dart';
import 'package:swiggy_ui/utils/app_colors.dart';
import 'package:swiggy_ui/utils/ui_helper.dart';
import 'package:swiggy_ui/widgets/veg_badge_view.dart';

class IndianDelightScreen extends StatelessWidget {
  final String categoryName;

  const IndianDelightScreen({Key? key, required this.categoryName})
      : super(key: key);

  /// Extract search keywords from category name.
  List<String> _keywordsFor(String category) {
    final lower = category.toLowerCase();
    final map = {
      'south indian': ['dosa', 'idly', 'idli', 'sambar', 'uttapam', 'pongal', 'vada', 'vadai', 'south indian'],
      'indian chai': ['chai', 'tea', 'coffee', 'filter coffee', 'masala chai', 'ginger tea'],
      'north indian': ['paneer', 'naan', 'roti', 'butter chicken', 'dal', 'chole', 'pulao', 'paratha', 'thali', 'north indian'],
      'indian biryani': ['biryani'],
      'biryani': ['biryani'],
      'indian dosa': ['dosa', 'roast', 'masala dosa', 'rava dosa', 'set dosa'],
      'dosa': ['dosa', 'roast', 'masala dosa', 'rava dosa', 'set dosa'],
      'indian idly': ['idly', 'idli', 'mini idly', 'sambar idly', 'podi idly'],
      'idly': ['idly', 'idli', 'mini idly', 'sambar idly', 'podi idly'],
    };
    return map[lower] ?? [lower];
  }

  @override
  Widget build(BuildContext context) {
    final keywords = _keywordsFor(categoryName);

    // Gather all restaurants
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

    // Search for matching dishes
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

    return Scaffold(
      backgroundColor: Colors.orange[50],
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Banner
                  Container(
                    height: MediaQuery.of(context).size.height / 5.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepOrange.shade700,
                          Colors.orange.shade400,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 30),
                          Text(
                            '🇮🇳',
                            style: const TextStyle(fontSize: 36),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            categoryName.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  UIHelper.verticalSpaceMedium(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '${categoryName.toUpperCase()} DELIGHTS',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(fontSize: 19.0),
                        ),
                        UIHelper.verticalSpaceSmall(),
                        Text(
                          'Showing only $categoryName dishes from restaurants near you',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        UIHelper.verticalSpaceSmall(),
                        Text(
                          '${results.fold<int>(0, (sum, rd) => sum + rd.dishes.length)} dishes from ${results.length} restaurants',
                          style: TextStyle(
                            color: Colors.deepOrange[400],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        UIHelper.verticalSpaceSmall(),
                        const Divider(),
                      ],
                    ),
                  ),
                  // Results
                  if (results.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(Icons.search_off,
                              size: 60, color: Colors.grey[300]),
                          const SizedBox(height: 12),
                          Text(
                            'No $categoryName dishes found',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  else
                    ...results.map((rd) => _buildRestaurantSection(context, rd)),
                  UIHelper.verticalSpaceLarge(),
                ],
              ),
            ),
          ),
          Positioned(
            top: 10.0,
            left: 2.4,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  size: 28.0,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantSection(
      BuildContext context, _RestaurantDishes rd) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                colors: [Colors.orange.shade50, Colors.white],
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
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[700],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Text(
                        rd.restaurant.ratingTimePrice.split(' ').first,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.star,
                          color: Colors.white, size: 12),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                              padding: const EdgeInsets.only(top: 4),
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
                            content:
                                Text('${dish.title} added to cart!'),
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
  }
}

class _RestaurantDishes {
  final SpotlightBestTopFood restaurant;
  final List<RestaurantDetail> dishes;

  _RestaurantDishes({required this.restaurant, required this.dishes});
}
