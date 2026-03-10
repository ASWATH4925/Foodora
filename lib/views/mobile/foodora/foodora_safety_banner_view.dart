import 'dart:async';
import 'package:flutter/material.dart';
import 'package:swiggy_ui/utils/app_colors.dart';
import 'package:swiggy_ui/utils/ui_helper.dart';
import 'package:swiggy_ui/widgets/responsive.dart';

class FoodoraSafetyBannerView extends StatefulWidget {
  const FoodoraSafetyBannerView({Key? key}) : super(key: key);

  @override
  State<FoodoraSafetyBannerView> createState() =>
      _FoodoraSafetyBannerViewState();
}

class _FoodoraSafetyBannerViewState extends State<FoodoraSafetyBannerView> {
  late final PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  final List<_SafetyCard> _cards = const [
    _SafetyCard(
      title: 'No-contact Delivery',
      description:
          'Have your order dropped off at your door or gate for added safety',
      image: 'assets/images/food3.jpg',
      icon: Icons.delivery_dining,
    ),
    _SafetyCard(
      title: 'Tamper-proof Packaging',
      description:
          'All restaurant partners use sealed and tamper-proof packaging',
      image: 'assets/images/food5.jpg',
      icon: Icons.verified_user,
    ),
    _SafetyCard(
      title: 'Daily Temperature Checks',
      description:
          'Temperature checks for all delivery partners and restaurant staff',
      image: 'assets/images/food1.jpg',
      icon: Icons.thermostat,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.88);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) return;
      setState(() {
        _currentPage = (_currentPage + 1) % _cards.length;
      });
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15.0),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.arrow_downward,
                color: foodoraOrange,
              ),
              UIHelper.horizontalSpaceExtraSmall(),
              Flexible(
                child: Text(
                  "FOODORA's KEY MEASURES TO ENSURE SAFETY",
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: foodoraOrange,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              UIHelper.horizontalSpaceExtraSmall(),
              Icon(
                Icons.arrow_downward,
                color: foodoraOrange,
              ),
            ],
          ),
          UIHelper.verticalSpaceMedium(),
          SizedBox(
            height: 220.0,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _cards.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                return AnimatedScale(
                  scale: _currentPage == index ? 1.0 : 0.92,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  child: AnimatedOpacity(
                    opacity: _currentPage == index ? 1.0 : 0.6,
                    duration: const Duration(milliseconds: 400),
                    child: _buildCard(context, _cards[index]),
                  ),
                );
              },
            ),
          ),
          UIHelper.verticalSpaceSmall(),
          // Dot indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _cards.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: _currentPage == index ? 24 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? foodoraOrange
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, _SafetyCard card) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange[50]!, Colors.orange[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: foodoraOrange!, width: 2.0),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: foodoraOrange!.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(card.icon, color: foodoraOrange, size: 28),
                ),
                UIHelper.verticalSpaceSmall(),
                Text(
                  card.title,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall!
                      .copyWith(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                UIHelper.verticalSpaceExtraSmall(),
                Text(
                  card.description,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(fontSize: 13, color: Colors.grey[700]),
                ),
                UIHelper.verticalSpaceSmall(),
                Text(
                  'Know More →',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(color: darkOrange, fontSize: 13),
                ),
              ],
            ),
          ),
          UIHelper.horizontalSpaceSmall(),
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.asset(
              card.image,
              height: 90.0,
              width: 90.0,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}

class _SafetyCard {
  final String title;
  final String description;
  final String image;
  final IconData icon;

  const _SafetyCard({
    required this.title,
    required this.description,
    required this.image,
    required this.icon,
  });
}
