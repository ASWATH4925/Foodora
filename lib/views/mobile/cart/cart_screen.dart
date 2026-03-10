import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swiggy_ui/models/cart_provider.dart';
import 'package:swiggy_ui/models/address_provider.dart';
import 'package:swiggy_ui/models/order_provider.dart';
import 'package:swiggy_ui/utils/app_colors.dart';
import 'package:swiggy_ui/utils/ui_helper.dart';
import 'package:swiggy_ui/widgets/custom_divider_view.dart';
import 'package:swiggy_ui/widgets/veg_badge_view.dart';
import 'package:swiggy_ui/views/mobile/address/address_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _couponApplied = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      body: SafeArea(
        child: Consumer<CartProvider>(
          builder: (context, cart, _) {
            if (cart.itemCount == 0) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart_outlined,
                        size: 80, color: Colors.grey[400]),
                    UIHelper.verticalSpaceMedium(),
                    Text(
                      'Your cart is empty',
                      style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                            color: Colors.grey[600],
                            fontSize: 20,
                          ),
                    ),
                    UIHelper.verticalSpaceSmall(),
                    Text(
                      'Add items from a restaurant to get started',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Colors.grey[500],
                          ),
                    ),
                  ],
                ),
              );
            }

            final discount = _couponApplied ? cart.totalAmount * 0.30 : 0.0;
            final discountedTotal = cart.totalAmount - discount;
            final deliveryFee = cart.deliveryFee;
            final tax = discountedTotal * 0.05;
            final grandTotal = discountedTotal + deliveryFee + tax;

            return SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.only(top: 15.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _OrderView(cart: cart),
                    const CustomDividerView(dividerHeight: 15.0),
                    _CouponView(
                      isApplied: _couponApplied,
                      discountAmount: discount,
                      onApply: () {
                        setState(() => _couponApplied = true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '🎉 Coupon applied! You save ₹${discount.toStringAsFixed(0)}'),
                            backgroundColor: Colors.green[700],
                          ),
                        );
                      },
                      onRemove: () {
                        setState(() => _couponApplied = false);
                      },
                    ),
                    const CustomDividerView(dividerHeight: 15.0),
                    _BillDetailView(
                      itemTotal: cart.totalAmount,
                      discount: discount,
                      deliveryFee: deliveryFee,
                      tax: tax,
                      grandTotal: grandTotal,
                    ),
                    _DecoratedView(),
                    _AddressPaymentView(
                      grandTotal: grandTotal,
                      onOrder: () => _placeOrder(context, cart, grandTotal),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _placeOrder(BuildContext context, CartProvider cart, double grandTotal) {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    // Create order items
    final orderItems = cart.items.values.map((item) {
      return OrderItem(
        name: item.name,
        price: item.price,
        quantity: item.quantity,
      );
    }).toList();

    // Add order to history
    orderProvider.addOrder(cart.restaurantName, orderItems, grandTotal);

    // Show delivery animation
    _showDeliveryAnimation(context);

    // Clear cart
    cart.clearCart();
    setState(() => _couponApplied = false);
  }

  void _showDeliveryAnimation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (context) {
        // Auto-dismiss after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        });

        return const _DeliveryAnimationDialog();
      },
    );
  }
}

class _DeliveryAnimationDialog extends StatefulWidget {
  const _DeliveryAnimationDialog();

  @override
  State<_DeliveryAnimationDialog> createState() =>
      _DeliveryAnimationDialogState();
}

class _DeliveryAnimationDialogState extends State<_DeliveryAnimationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _slideAnimation = Tween<double>(begin: -1.5, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.2), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.5), weight: 20),
    ]).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Order confirmed text
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.scale(
                  scale: 0.5 + (value * 0.5),
                  child: child,
                ),
              );
            },
            child: Column(
              children: [
                const Text(
                  '🎉',
                  style: TextStyle(fontSize: 50, decoration: TextDecoration.none),
                ),
                const SizedBox(height: 10),
                Text(
                  'ORDER CONFIRMED!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    decoration: TextDecoration.none,
                    shadows: [
                      Shadow(
                        color: Colors.orange.withValues(alpha: 0.8),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          // Scooter animation
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 120,
            child: AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return Stack(
                  children: [
                    // Road
                    Positioned(
                      bottom: 15,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 3,
                        color: Colors.grey[600],
                      ),
                    ),
                    // Dashes on road
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                          20,
                          (i) => Container(
                            width: 8,
                            height: 2,
                            color: Colors.yellow[600],
                          ),
                        ),
                      ),
                    ),
                    // Scooter
                    Positioned(
                      left: MediaQuery.of(context).size.width *
                          _slideAnimation.value,
                      bottom: 20,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '📦',
                              style: TextStyle(
                                  fontSize: 20,
                                  decoration: TextDecoration.none),
                            ),
                            Text(
                              '🛵',
                              style: TextStyle(
                                  fontSize: 45,
                                  decoration: TextDecoration.none),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 1200),
            builder: (context, value, child) {
              return Opacity(opacity: value, child: child);
            },
            child: Text(
              'Your food is on its way! 🍽️',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 16,
                fontStyle: FontStyle.italic,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderView extends StatelessWidget {
  final CartProvider cart;

  const _OrderView({required this.cart});

  @override
  Widget build(BuildContext context) {
    final items = cart.items.values.toList();

    return Container(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.restaurant, size: 30, color: Colors.deepOrange),
              UIHelper.horizontalSpaceSmall(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(cart.restaurantName,
                      style: Theme.of(context).textTheme.titleSmall),
                ],
              )
            ],
          ),
          UIHelper.verticalSpaceLarge(),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: <Widget>[
                    const VegBadgeView(),
                    UIHelper.horizontalSpaceSmall(),
                    Flexible(
                      child: Text(
                        item.name,
                        style: Theme.of(context).textTheme.bodyLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    UIHelper.horizontalSpaceSmall(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      height: 35.0,
                      width: 100.0,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          InkWell(
                            child: const Icon(Icons.remove, color: Colors.green),
                            onTap: () => cart.decrementItem(item.id),
                          ),
                          const Spacer(),
                          Text('${item.quantity}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(fontSize: 16.0)),
                          const Spacer(),
                          InkWell(
                            child: const Icon(Icons.add, color: Colors.green),
                            onTap: () => cart.incrementItem(item.id),
                          )
                        ],
                      ),
                    ),
                    UIHelper.horizontalSpaceSmall(),
                    Text(
                      '₹${(item.price * item.quantity).toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              )),
          UIHelper.verticalSpaceMedium(),
          CustomDividerView(dividerHeight: 1.0, color: Colors.grey[400]),
          UIHelper.verticalSpaceMedium(),
          Row(
            children: <Widget>[
              Icon(Icons.library_books, color: Colors.grey[700]),
              UIHelper.horizontalSpaceSmall(),
              const Expanded(
                child: Text(
                    'Any restaurant request? We will try our best to convey it'),
              )
            ],
          ),
          UIHelper.verticalSpaceMedium(),
        ],
      ),
    );
  }
}

class _CouponView extends StatelessWidget {
  final bool isApplied;
  final double discountAmount;
  final VoidCallback onApply;
  final VoidCallback onRemove;

  const _CouponView({
    required this.isApplied,
    required this.discountAmount,
    required this.onApply,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          if (isApplied)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_offer, size: 20.0, color: Colors.green[700]),
                  UIHelper.horizontalSpaceMedium(),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SAVE30 Applied!',
                          style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                color: Colors.green[800],
                                fontSize: 14,
                              ),
                        ),
                        Text(
                          'You save ₹${discountAmount.toStringAsFixed(0)}',
                          style: TextStyle(
                              color: Colors.green[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: onRemove,
                    child: Text('REMOVE',
                        style: TextStyle(color: Colors.red[400], fontSize: 12)),
                  ),
                ],
              ),
            )
          else
            InkWell(
              onTap: onApply,
              child: Row(
                children: <Widget>[
                  Icon(Icons.local_offer,
                      size: 20.0, color: Colors.grey[700]),
                  UIHelper.horizontalSpaceMedium(),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'APPLY COUPON',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(fontSize: 16.0),
                        ),
                        Text(
                          'Get 30% off on your order!',
                          style: TextStyle(
                              color: Colors.green[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.deepOrange),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      'APPLY',
                      style: TextStyle(
                        color: Colors.deepOrange[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _BillDetailView extends StatelessWidget {
  final double itemTotal;
  final double discount;
  final double deliveryFee;
  final double tax;
  final double grandTotal;

  const _BillDetailView({
    required this.itemTotal,
    required this.discount,
    required this.deliveryFee,
    required this.tax,
    required this.grandTotal,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle =
        Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 16.0);

    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Bill Details',
            style: Theme.of(context)
                .textTheme
                .headlineSmall!
                .copyWith(fontSize: 17.0),
          ),
          UIHelper.verticalSpaceSmall(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Item total', style: textStyle),
              Text('₹${itemTotal.toStringAsFixed(2)}', style: textStyle),
            ],
          ),
          if (discount > 0) ...[
            UIHelper.verticalSpaceSmall(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Coupon (30% off)',
                    style: textStyle.copyWith(color: Colors.green[700])),
                Text('-₹${discount.toStringAsFixed(2)}',
                    style: textStyle.copyWith(color: Colors.green[700])),
              ],
            ),
          ],
          UIHelper.verticalSpaceMedium(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text('Delivery Fee', style: textStyle),
                        UIHelper.horizontalSpaceSmall(),
                        const Icon(Icons.info_outline, size: 14.0)
                      ],
                    ),
                  ],
                ),
              ),
              Text('₹${deliveryFee.toStringAsFixed(2)}', style: textStyle),
            ],
          ),
          UIHelper.verticalSpaceLarge(),
          _buildDivider(),
          Container(
            alignment: Alignment.center,
            height: 60.0,
            child: Row(
              children: <Widget>[
                Text('Taxes and Charges', style: textStyle),
                UIHelper.horizontalSpaceSmall(),
                const Icon(Icons.info_outline, size: 14.0),
                const Spacer(),
                Text('₹${tax.toStringAsFixed(2)}', style: textStyle),
              ],
            ),
          ),
          _buildDivider(),
          Container(
            alignment: Alignment.center,
            height: 60.0,
            child: Row(
              children: <Widget>[
                Text('To Pay', style: Theme.of(context).textTheme.titleSmall),
                const Spacer(),
                Text('₹${grandTotal.toStringAsFixed(2)}',
                    style: textStyle.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  CustomDividerView _buildDivider() => CustomDividerView(
        dividerHeight: 1.0,
        color: Colors.grey[400],
      );
}

class _DecoratedView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(height: 50.0, color: Colors.grey[200]);
  }
}

class _AddressPaymentView extends StatelessWidget {
  final double grandTotal;
  final VoidCallback onOrder;

  const _AddressPaymentView({
    required this.grandTotal,
    required this.onOrder,
  });

  @override
  Widget build(BuildContext context) {
    final addressProvider = Provider.of<AddressProvider>(context);
    final selectedAddr = addressProvider.selectedAddress;

    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    height: 60.0,
                    width: 60.0,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1.0),
                    ),
                    child: const Icon(Icons.add_location, size: 30.0),
                  ),
                  const Positioned(
                    top: 0.0,
                    right: 0.0,
                    child: Icon(Icons.check_circle, color: Colors.green),
                  )
                ],
              ),
              UIHelper.horizontalSpaceMedium(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Deliver to ${selectedAddr?.label ?? "Other"}',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall!
                          .copyWith(fontSize: 16.0),
                    ),
                    Text(
                      selectedAddr?.fullAddress ?? 'Keelkattalai',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(color: Colors.grey),
                    ),
                    UIHelper.verticalSpaceSmall(),
                    Text('43 MINS',
                        style: Theme.of(context).textTheme.titleSmall),
                  ],
                ),
              ),
              InkWell(
                child: Text(
                  'ADD ADDRESS',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(color: darkOrange),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddressScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10.0),
                color: Colors.grey[200],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '₹${grandTotal.toStringAsFixed(0)}',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall!
                          .copyWith(fontSize: 16.0),
                    ),
                    UIHelper.verticalSpaceExtraSmall(),
                    Text(
                      'VIEW DETAIL BILL',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall!
                          .copyWith(color: Colors.blue, fontSize: 13.0),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: onOrder,
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10.0),
                  color: Colors.green,
                  height: 58.0,
                  child: Text(
                    'PLACE ORDER',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(color: Colors.white),
                  ),
                ),
              ),
            )
          ],
        )
      ],
    );
  }
}
