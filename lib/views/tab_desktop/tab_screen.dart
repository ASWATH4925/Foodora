import 'package:flutter/material.dart';
import 'package:swiggy_ui/views/mobile/account/account_screen.dart';
import 'package:swiggy_ui/views/mobile/cart/cart_screen.dart';
import 'package:swiggy_ui/views/mobile/foodora/offers/offer_screen.dart';
import 'package:swiggy_ui/views/mobile/search/search_screen.dart';

import 'home_view.dart';
import 'menu_view.dart';

class TabScreen extends StatefulWidget {
  const TabScreen({Key? key}) : super(key: key);

  @override
  _TabScreenState createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  int _selectedIndex = 0;

  final List<Widget> _views = [
    const HomeView(expandFlex: 5),
    const SearchScreen(),
    const CartScreen(),
    const OffersScreen(),
    AccountScreen(),
    const Scaffold(
      body: Center(
        child: Text(
          "More Cool Features Coming Soon...",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[100],
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MenuView(
            isTab: true,
            expandFlex: 1,
            selectedIndex: _selectedIndex,
            onMenuTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          Expanded(
            flex: 5,
            child: _views[_selectedIndex],
          ),
        ],
      ),
    );
  }
}
