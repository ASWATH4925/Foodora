import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swiggy_ui/models/cart_provider.dart';
import 'package:swiggy_ui/models/order_provider.dart';
import 'package:swiggy_ui/utils/app_colors.dart';
import 'package:swiggy_ui/utils/ui_helper.dart';
import 'package:swiggy_ui/widgets/custom_divider_view.dart';
import 'package:swiggy_ui/widgets/dotted_seperator_view.dart';
import 'package:swiggy_ui/views/mobile/login_screen.dart';
import 'package:swiggy_ui/views/mobile/address/address_screen.dart';
import 'package:swiggy_ui/views/mobile/account/favourites_screen.dart';

class AccountScreen extends StatelessWidget {
  final List<String> titles = [
    'My Account',
    'SUPER Expired',
    'Foodora Money',
    'Help',
  ];
  final List<String> body = [
    'Address, Payments, Favourites, Referrals & Offers',
    'You had a great savings run. Get SUPER again',
    'Balance & Transactions',
    'FAQ & Links',
  ];
  final List<IconData> icons = [
    Icons.person_outline,
    Icons.star_border,
    Icons.account_balance_wallet_outlined,
    Icons.help_outline,
  ];

  AccountScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _AppBar(),
              ListView.builder(
                shrinkWrap: true,
                itemCount: titles.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) => _ListItem(
                  title: titles[index],
                  body: body[index],
                  icon: icons[index],
                  isLastItem: (titles.length - 1) == index,
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 15.0),
                height: 50.0,
                color: Colors.grey[200],
                child: Text(
                  'PAST ORDERS',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(color: Colors.grey[700], fontSize: 12.0),
                ),
              ),
              const _PastOrderListView(),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final subtitleStyle = Theme.of(context).textTheme.bodyLarge;

    return Container(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'ASWATH',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
              InkWell(
                child: Text(
                  'EDIT',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall!
                      .copyWith(fontSize: 17.0, color: darkOrange),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const _EditProfileScreen(),
                    ),
                  );
                },
              )
            ],
          ),
          UIHelper.verticalSpaceSmall(),
          Row(
            children: <Widget>[
              Text('8807571154', style: subtitleStyle),
              UIHelper.horizontalSpaceSmall(),
              ClipOval(
                child: Container(
                  height: 3.0,
                  width: 3.0,
                  color: Colors.grey[700],
                ),
              ),
              UIHelper.horizontalSpaceSmall(),
              Text('aswath@icloud.com', style: subtitleStyle)
            ],
          ),
          UIHelper.verticalSpaceLarge(),
          const CustomDividerView(
            dividerHeight: 1.8,
            color: Colors.black,
          )
        ],
      ),
    );
  }
}

class _ListItem extends StatelessWidget {
  const _ListItem({
    Key? key,
    required this.title,
    required this.body,
    required this.icon,
    this.isLastItem = false,
  }) : super(key: key);

  final String title;
  final String body;
  final IconData icon;
  final bool isLastItem;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => _AccountDetailScreen(title: title, body: body, icon: icon),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(icon, color: Colors.deepOrange, size: 28),
                UIHelper.horizontalSpaceSmall(),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(fontSize: 15.0),
                      ),
                      UIHelper.verticalSpaceExtraSmall(),
                      Text(
                        body,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(fontSize: 13.0, color: Colors.black),
                      ),
                    ],
                  ),
                ),
                UIHelper.horizontalSpaceSmall(),
                const Icon(Icons.keyboard_arrow_right)
              ],
            ),
            UIHelper.verticalSpaceLarge(),
            isLastItem
                ? const SizedBox()
                : const CustomDividerView(
                    dividerHeight: 0.8,
                    color: Colors.black26,
                  ),
          ],
        ),
      ),
    );
  }
}

class _PastOrderListView extends StatelessWidget {
  const _PastOrderListView();

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, _) {
        final orders = orderProvider.orders;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListView.builder(
              shrinkWrap: true,
              itemCount: orders.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) => _PastOrdersListItemView(
                order: orders[index],
              ),
            ),
            UIHelper.verticalSpaceSmall(),
            const CustomDividerView(),
            InkWell(
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: Row(
                children: <Widget>[
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 10.0),
                    height: 50.0,
                    child: Text(
                      'LOGOUT',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall!
                          .copyWith(fontSize: 16.0),
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.power_settings_new),
                  UIHelper.horizontalSpaceSmall(),
                ],
              ),
            ),
            Container(
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.only(top: 20.0),
              height: 130.0,
              color: Colors.grey[200],
              child: Text(
                'App Version v3.2.0',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: Colors.grey[700], fontSize: 13.0),
              ),
            )
          ],
        );
      },
    );
  }
}

class _PastOrdersListItemView extends StatelessWidget {
  const _PastOrdersListItemView({
    Key? key,
    required this.order,
  }) : super(key: key);

  final PastOrder order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        order.restaurantName,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      UIHelper.verticalSpaceExtraSmall(),
                      Text(
                        'Keelkattalai',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(fontSize: 12.0),
                      ),
                      UIHelper.verticalSpaceSmall(),
                      Row(
                        children: <Widget>[
                          Text('₹${order.totalAmount.toStringAsFixed(0)}'),
                          UIHelper.horizontalSpaceExtraSmall(),
                          Icon(Icons.keyboard_arrow_right,
                              color: Colors.grey[600])
                        ],
                      )
                    ],
                  ),
                ),
                Text('Delivered',
                    style: Theme.of(context).textTheme.titleSmall),
                UIHelper.horizontalSpaceSmall(),
                ClipOval(
                  child: Container(
                    padding: const EdgeInsets.all(2.2),
                    color: Colors.green,
                    child: const Icon(Icons.check,
                        color: Colors.white, size: 14.0),
                  ),
                )
              ],
            ),
          ),
          UIHelper.verticalSpaceSmall(),
          const DottedSeperatorView(),
          UIHelper.verticalSpaceMedium(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(order.itemsSummary),
              UIHelper.verticalSpaceExtraSmall(),
              Text(order.formattedDate),
              UIHelper.verticalSpaceSmall(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(width: 1.5, color: darkOrange!),
                          ),
                          child: Text(
                            'REORDER',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(color: darkOrange),
                          ),
                          onPressed: () {
                            final cart = Provider.of<CartProvider>(context,
                                listen: false);
                            for (final item in order.items) {
                              cart.addItem(
                                item.name,
                                item.price,
                                order.restaurantName,
                              );
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    '${order.items.length} item(s) added to cart!'),
                                backgroundColor: Colors.green[700],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  UIHelper.horizontalSpaceMedium(),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              width: 1.5,
                              color: order.isRated
                                  ? Colors.green
                                  : Colors.black,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (order.isRated)
                                Icon(Icons.star,
                                    color: Colors.amber, size: 16),
                              Text(
                                order.isRated
                                    ? ' ${order.rating.toStringAsFixed(1)}'
                                    : 'RATE FOOD',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(
                                      color: order.isRated
                                          ? Colors.green
                                          : Colors.black,
                                    ),
                              ),
                            ],
                          ),
                          onPressed: () {
                            _showRatingDialog(context, order);
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
              UIHelper.verticalSpaceMedium(),
              const CustomDividerView(
                  dividerHeight: 1.5, color: Colors.black)
            ],
          )
        ],
      ),
    );
  }

  void _showRatingDialog(BuildContext context, PastOrder order) {
    double selectedRating = order.rating > 0 ? order.rating : 4.0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.deepOrange.shade400,
                            Colors.orange.shade300,
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Text('🍽️',
                          style: TextStyle(fontSize: 32)),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Rate your food from',
                      style:
                          TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    Text(
                      order.restaurantName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      order.itemsSummary,
                      style: TextStyle(
                          color: Colors.grey[500], fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    // Star rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              selectedRating = (i + 1).toDouble();
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4),
                            child: Icon(
                              i < selectedRating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 40,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getRatingText(selectedRating),
                      style: TextStyle(
                        color: _getRatingColor(selectedRating),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Provider.of<OrderProvider>(context,
                                  listen: false)
                              .rateOrder(order.id, selectedRating);
                          Navigator.pop(context);
                          _showRatingSuccess(context, selectedRating);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'SUBMIT RATING',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _getRatingText(double rating) {
    if (rating >= 5) return '🤩 Amazing!';
    if (rating >= 4) return '😋 Great!';
    if (rating >= 3) return '😊 Good';
    if (rating >= 2) return '😐 Okay';
    return '😞 Poor';
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4) return Colors.green;
    if (rating >= 3) return Colors.orange;
    return Colors.red;
  }

  void _showRatingSuccess(BuildContext context, double rating) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(seconds: 2), () {
          if (Navigator.canPop(context)) Navigator.pop(context);
        });

        return Dialog(
          backgroundColor: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.deepOrange.shade600,
                    Colors.orange.shade400,
                    Colors.amber.shade300,
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepOrange.withValues(alpha: 0.5),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '🎉',
                    style: TextStyle(
                        fontSize: 50, decoration: TextDecoration.none),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Thank You!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You rated ${rating.toStringAsFixed(0)} ⭐',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your feedback helps us improve!',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                      decoration: TextDecoration.none,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Detail pages for account items ──

class _AccountDetailScreen extends StatelessWidget {
  final String title;
  final String body;
  final IconData icon;

  const _AccountDetailScreen({
    required this.title,
    required this.body,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (title) {
      case 'My Account':
        return _buildMyAccount(context);
      case 'SUPER Expired':
        return _buildSuperExpired(context);
      case 'Foodora Money':
        return _buildFoodoraMoney(context);
      case 'Help':
        return _buildHelp(context);
      default:
        return Center(child: Text(body));
    }
  }

  Widget _buildMyAccount(BuildContext context) {
    return Column(
      children: [
        _buildSection(context, 'Saved Addresses', Icons.location_on, () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddressScreen()));
        }),
        _buildSection(context, 'Payment Methods', Icons.payment, null,
            subtitle: 'No saved payment methods'),
        _buildSection(context, 'Favourite Restaurants', Icons.favorite, () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const FavouritesScreen()));
        },
            subtitle: 'Your favourite restaurants will appear here'),
        _buildSection(context, 'Referrals', Icons.card_giftcard, null,
            subtitle: 'Refer friends and earn rewards'),
        _buildSection(context, 'Offers & Rewards', Icons.local_offer, null,
            subtitle: 'Check out available offers'),
      ],
    );
  }

  Widget _buildSuperExpired(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepOrange.shade400, Colors.amber.shade300],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Text('👑', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 12),
              const Text(
                'Foodora SUPER',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Your SUPER membership has expired',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9))),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.deepOrange,
                ),
                child: const Text('RENEW SUPER'),
              ),
            ],
          ),
        ),
        _buildSection(context, 'Free deliveries on all orders', Icons.delivery_dining, null),
        _buildSection(context, 'Extra discounts on restaurants', Icons.discount, null),
        _buildSection(context, 'No surge fee', Icons.flash_off, null),
      ],
    );
  }

  Widget _buildFoodoraMoney(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.grey.withValues(alpha: 0.15), blurRadius: 10),
            ],
          ),
          child: Column(
            children: [
              Icon(Icons.account_balance_wallet,
                  size: 48, color: Colors.deepOrange[400]),
              const SizedBox(height: 12),
              const Text('Current Balance',
                  style: TextStyle(color: Colors.grey, fontSize: 14)),
              const Text('₹0.00',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        _buildSection(context, 'Transaction History', Icons.history, null,
            subtitle: 'No transactions yet'),
        _buildSection(context, 'Add Money', Icons.add_circle_outline, null),
      ],
    );
  }

  Widget _buildHelp(BuildContext context) {
    return Column(
      children: [
        _buildSection(context, 'FAQs', Icons.quiz_outlined, null,
            subtitle: 'Frequently asked questions'),
        _buildSection(context, 'Report an issue', Icons.report_problem_outlined, null,
            subtitle: 'Having trouble with an order?'),
        _buildSection(context, 'Contact us', Icons.phone, null,
            subtitle: 'Call us at 1800-XXX-XXXX'),
        _buildSection(context, 'Terms & Conditions', Icons.description_outlined, null),
        _buildSection(context, 'Privacy Policy', Icons.privacy_tip_outlined, null),
        _buildSection(context, 'About', Icons.info_outline, null,
            subtitle: 'Foodora v3.2.0'),
      ],
    );
  }

  Widget _buildSection(
      BuildContext context, String label, IconData ico, VoidCallback? onTap,
      {String? subtitle}) {
    return InkWell(
      onTap: onTap ?? () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label coming soon!')),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(ico, color: Colors.deepOrange, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
                  if (subtitle != null)
                    Text(subtitle,
                        style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _EditProfileScreen extends StatelessWidget {
  const _EditProfileScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.deepOrange[100],
              child: const Text('A', style: TextStyle(fontSize: 36, color: Colors.deepOrange)),
            ),
            const SizedBox(height: 24),
            TextFormField(
              initialValue: 'ASWATH',
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: '8807571154',
              decoration: const InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: 'aswath@icloud.com',
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('SAVE CHANGES'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
