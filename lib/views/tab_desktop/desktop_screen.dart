import 'package:flutter/material.dart';
import 'package:swiggy_ui/views/mobile/account/account_screen.dart';
import 'package:swiggy_ui/views/mobile/cart/cart_screen.dart';
import 'package:swiggy_ui/views/mobile/foodora/offers/offer_screen.dart';
import 'package:swiggy_ui/views/mobile/search/search_screen.dart';

import 'cart_view.dart';
import 'home_view.dart';
import 'menu_view.dart';

class DesktopScreen extends StatefulWidget {
  const DesktopScreen({Key? key}) : super(key: key);

  @override
  _DesktopScreenState createState() => _DesktopScreenState();
}

class _DesktopScreenState extends State<DesktopScreen> {
  int _selectedIndex = 0;

  final List<Widget> _views = [
    const HomeView(),
    const SearchScreen(),
    const CartScreen(),
    const OffersScreen(),
    AccountScreen(),
    Scaffold(body: Center(child: Text("More Cool Features Coming Soon...", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[100],
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MenuView(
            selectedIndex: _selectedIndex,
            onMenuTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          Expanded(
            flex: 4,
            child: _views[_selectedIndex],
          ),
          const CartView(),
        ],
      ),
    );
  }
}
