import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swiggy_ui/models/cart_provider.dart';
import 'package:swiggy_ui/models/favourite_provider.dart';
import 'package:swiggy_ui/models/restaurant_detail.dart';
import 'package:swiggy_ui/models/spotlight_best_top_food.dart';
import 'package:swiggy_ui/utils/ui_helper.dart';
import 'package:swiggy_ui/widgets/custom_divider_view.dart';
import 'package:swiggy_ui/widgets/veg_badge_view.dart';

class RestaurantDetailScreen extends StatelessWidget {
  final SpotlightBestTopFood? restaurant;

  const RestaurantDetailScreen({Key? key, this.restaurant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final name = restaurant?.name ?? 'Namma Veedu Vasanta Bhavan';
    final desc = restaurant?.desc ?? 'South Indian';
    final ratingTimePrice = restaurant?.ratingTimePrice ?? '4.1 35 mins - Rs 150 for two';
    final coupon = restaurant?.coupon ?? '30% off up to Rs75 | Use code FOODORAIT';

    // Parse rating/time/price
    final parts = ratingTimePrice.split(' ');
    final rating = parts.isNotEmpty ? parts[0] : '4.1';
    final timeIdx = ratingTimePrice.indexOf('mins');
    String deliveryTime = '30 mins';
    if (timeIdx > 0) {
      final before = ratingTimePrice.substring(0, timeIdx).trim();
      final timeParts = before.split(' ');
      deliveryTime = '${timeParts.last} mins';
    }
    final priceMatch = RegExp(r'Rs\s*\d+').firstMatch(ratingTimePrice);
    final priceForTwo = priceMatch != null ? priceMatch.group(0)! : 'Rs 150';

    return Scaffold(
      backgroundColor: Colors.teal[100],
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0.0,
        actions: <Widget>[
          Consumer<FavouriteProvider>(
            builder: (context, favProvider, _) {
              final isFav = favProvider.isFavourite(name);
              return IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : Colors.black,
                ),
                onPressed: () {
                  favProvider.toggleFavourite(name);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isFav
                            ? '$name removed from favourites'
                            : '$name added to favourites ❤️',
                      ),
                      duration: const Duration(seconds: 1),
                      backgroundColor:
                          isFav ? Colors.grey[700] : Colors.green[700],
                    ),
                  );
                },
              );
            },
          ),
          const Icon(Icons.search),
          UIHelper.horizontalSpaceSmall(),
        ],
      ),
      body: _OrderNowView(
        restaurantName: name,
        cuisine: desc,
        rating: rating,
        deliveryTime: deliveryTime,
        priceForTwo: priceForTwo,
        coupon: coupon,
      ),
    );
  }
}

class _OrderNowView extends StatelessWidget {
  final String restaurantName;
  final String cuisine;
  final String rating;
  final String deliveryTime;
  final String priceForTwo;
  final String coupon;

  const _OrderNowView({
    required this.restaurantName,
    required this.cuisine,
    required this.rating,
    required this.deliveryTime,
    required this.priceForTwo,
    required this.coupon,
  });

  @override
  Widget build(BuildContext context) {
    final categories = RestaurantDetail.getMenuCategoriesFor(restaurantName);
    final menus = RestaurantDetail.getMenusFor(restaurantName);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  restaurantName,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(fontWeight: FontWeight.bold, fontSize: 16.0),
                ),
                UIHelper.verticalSpaceSmall(),
                Text(cuisine,
                    style: Theme.of(context).textTheme.bodyLarge),
                UIHelper.verticalSpaceMedium(),
                const CustomDividerView(dividerHeight: 1.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _buildVerticalStack(context, rating, 'Rating'),
                    _buildVerticalStack(context, deliveryTime, 'Delivery Time'),
                    _buildVerticalStack(context, priceForTwo, 'For Two'),
                  ],
                ),
                const CustomDividerView(dividerHeight: 1.0),
                UIHelper.verticalSpaceMedium(),
                _buildOfferTile(context, coupon),
                UIHelper.verticalSpaceSmall(),
              ],
            ),
          ),
          const CustomDividerView(dividerHeight: 15.0),
          // Recommended section using first menu category
          if (menus.isNotEmpty && menus[0].isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                'Recommended',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .copyWith(fontSize: 18.0),
              ),
            ),
            _RecommendedFoodView(
              foods: menus[0].take(4).toList(),
              restaurantName: restaurantName,
            ),
            const CustomDividerView(dividerHeight: 15.0),
          ],
          // Menu categories
          for (int i = 0; i < menus.length && i < categories.length; i++) ...[
            _FoodListView(
              title: categories[i],
              foods: menus[i],
              restaurantName: restaurantName,
            ),
            if (i < menus.length - 1)
              const CustomDividerView(dividerHeight: 15.0),
          ],
          UIHelper.verticalSpaceLarge(),
        ],
      ),
    );
  }

  Padding _buildOfferTile(BuildContext context, String desc) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          children: <Widget>[
            Icon(Icons.local_offer, color: Colors.red[600], size: 15.0),
            UIHelper.horizontalSpaceSmall(),
            Flexible(
              child: Text(
                desc,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(fontSize: 13.0),
              ),
            )
          ],
        ),
      );

  Expanded _buildVerticalStack(
          BuildContext context, String title, String subtitle) =>
      Expanded(
        child: SizedBox(
          height: 60.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .copyWith(fontSize: 15.0),
              ),
              UIHelper.verticalSpaceExtraSmall(),
              Text(subtitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(fontSize: 13.0))
            ],
          ),
        ),
      );
}

class _RecommendedFoodView extends StatelessWidget {
  final List<RestaurantDetail> foods;
  final String restaurantName;

  const _RecommendedFoodView({
    required this.foods,
    required this.restaurantName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(
          foods.length,
          (index) => Container(
            margin: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: foods[index].image.isNotEmpty
                      ? Image.asset(
                          foods[index].image,
                          fit: BoxFit.fill,
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.restaurant, size: 40),
                        ),
                ),
                UIHelper.verticalSpaceExtraSmall(),
                SizedBox(
                  height: 80.0,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const VegBadgeView(),
                          UIHelper.horizontalSpaceExtraSmall(),
                          Flexible(
                            child: Text(
                              foods[index].title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      UIHelper.verticalSpaceMedium(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(foods[index].price,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(fontSize: 14.0)),
                          AddBtnView(
                            foodName: foods[index].title,
                            foodPrice: foods[index].price,
                            restaurantName: restaurantName,
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddBtnView extends StatelessWidget {
  final String foodName;
  final String foodPrice;
  final String restaurantName;

  const AddBtnView({
    Key? key,
    required this.foodName,
    required this.foodPrice,
    required this.restaurantName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final price = CartProvider.parsePrice(foodPrice);
        Provider.of<CartProvider>(context, listen: false).addItem(
          foodName,
          price,
          restaurantName,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$foodName added to cart!'),
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.green[700],
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 25.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          color: Colors.white,
        ),
        child: Text(
          'ADD',
          style: Theme.of(context)
              .textTheme
              .titleSmall!
              .copyWith(color: Colors.green),
        ),
      ),
    );
  }
}

class _FoodListView extends StatelessWidget {
  const _FoodListView({
    Key? key,
    required this.title,
    required this.foods,
    required this.restaurantName,
  }) : super(key: key);

  final String title;
  final List<RestaurantDetail> foods;
  final String restaurantName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          UIHelper.verticalSpaceMedium(),
          Text(
            title,
            style:
                Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 18.0),
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: foods.length,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  UIHelper.verticalSpaceSmall(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const VegBadgeView(),
                      UIHelper.horizontalSpaceMedium(),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(
                              foods[index].title,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            UIHelper.verticalSpaceSmall(),
                            Text(
                              foods[index].price,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(fontSize: 14.0),
                            ),
                            if (foods[index].desc.isNotEmpty) ...[
                              UIHelper.verticalSpaceMedium(),
                              Text(
                                foods[index].desc,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                      fontSize: 12.0,
                                      color: Colors.grey[500],
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      AddBtnView(
                        foodName: foods[index].title,
                        foodPrice: foods[index].price,
                        restaurantName: restaurantName,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
