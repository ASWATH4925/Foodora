import 'package:flutter/material.dart';
import 'package:swiggy_ui/utils/app_colors.dart';
import 'package:swiggy_ui/utils/ui_helper.dart';
import 'package:swiggy_ui/views/mobile/foodora/genie/genie_screen.dart';
import 'package:swiggy_ui/widgets/responsive.dart';

import 'all_restaurants/all_restaurants_screen.dart';
import 'genie/genie_grocery_card_view.dart';
import 'meat/meat_screen.dart';

class FoodGroceriesAvailabilityView extends StatelessWidget {
  const FoodGroceriesAvailabilityView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isTabletDesktop = Responsive.isTabletDesktop(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      child: Column(
        children: <Widget>[
          if (!isTabletDesktop) _buildFlashyBanner(context),
          if (!isTabletDesktop) UIHelper.verticalSpaceLarge(),
          Stack(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: InkWell(
                  child: Container(
                    height: 150.0,
                    color: foodoraOrange,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.topLeft,
                          child: FractionallySizedBox(
                            widthFactor: 0.7,
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Restaurants',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineLarge!
                                        .copyWith(color: Colors.white),
                                  ),
                                  UIHelper.verticalSpaceExtraSmall(),
                                  Text(
                                    'No-contact delivery available',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(color: Colors.white),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          height: 45.0,
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          color: darkOrange,
                          child: Row(
                            children: <Widget>[
                              Text(
                                'View all',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                        color: Colors.white, fontSize: 18.0),
                              ),
                              UIHelper.horizontalSpaceSmall(),
                              const Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 18.0,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  onTap: isTabletDesktop
                      ? () {}
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AllRestaurantsScreen(),
                            ),
                          );
                        },
                ),
              ),
              Positioned(
                top: -10.0,
                right: -10.0,
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/food1.jpg',
                    width: 130.0,
                    height: 130.0,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          UIHelper.verticalSpaceMedium(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              GenieGroceryCardView(
                title: 'Genie',
                subtitle: 'Anything you need,\ndelivered',
                image: 'assets/images/food1.jpg',
                onTap: isTabletDesktop
                    ? () {}
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GenieScreen(),
                          ),
                        );
                      },
              ),
              GenieGroceryCardView(
                title: 'Grocery',
                subtitle: 'Esentials delivered\nin 2 Hrs',
                image: 'assets/images/food4.jpg',
                onTap: isTabletDesktop
                    ? () {}
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GenieScreen(),
                          ),
                        );
                      },
              ),
              GenieGroceryCardView(
                title: 'Meat',
                subtitle: 'Fesh meat\ndelivered safe',
                image: 'assets/images/food6.jpg',
                onTap: isTabletDesktop
                    ? () {}
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MeatScreen(),
                          ),
                        );
                      },
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildFlashyBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepOrange.shade700,
            Colors.orange.shade500,
            Colors.amber.shade400,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.deepOrange.withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Animated-looking icon row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('🚀', style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '✨ LIVE NOW',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Main headline - flashy gradient text effect
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Colors.white, Colors.yellowAccent, Colors.white],
            ).createShader(bounds),
            child: Text(
              'We Are Now Delivering\nFood, Groceries &\nAll Essentials!',
              style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                    letterSpacing: 0.5,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          // Service timing cards
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                _buildServiceRow('🍽️ Food & Genie', 'Mon-Sat  6AM - 9PM'),
                const SizedBox(height: 8),
                _buildServiceRow('🥬 Groceries & Meat', 'Mon-Sat  6AM - 6PM'),
                const SizedBox(height: 8),
                _buildServiceRow('🥛 Dairy', 'Daily  6AM - 12PM'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Bottom tagline
          Center(
            child: Text(
              '— Your one-stop delivery partner —',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontStyle: FontStyle.italic,
                fontSize: 13,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceRow(String emoji, String time) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            time,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
