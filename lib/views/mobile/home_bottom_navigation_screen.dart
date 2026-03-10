import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swiggy_ui/models/cart_provider.dart';
import 'package:swiggy_ui/views/mobile/search/search_screen.dart';
import 'package:swiggy_ui/views/mobile/foodora/foodora_screen.dart';
import 'package:swiggy_ui/views/mobile/chatbot/chatbot_screen.dart';

import '../../utils/app_colors.dart';
import 'account/account_screen.dart';
import 'cart/cart_screen.dart';

class HomeBottomNavigationScreen extends StatefulWidget {
  const HomeBottomNavigationScreen({Key? key}) : super(key: key);

  @override
  _HomeBottomNavigationScreenState createState() =>
      _HomeBottomNavigationScreenState();
}

class _HomeBottomNavigationScreenState
    extends State<HomeBottomNavigationScreen> {
  final List<Widget> _children = [
    const FoodoraScreen(),
    const SearchScreen(),
    const CartScreen(),
    AccountScreen(),
  ];

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final labelTextStyle =
        Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 8.0);
    return Scaffold(
      backgroundColor: Colors.cyan[100],
      body: _children[selectedIndex],
      floatingActionButton: _buildChatbotFAB(context),
      bottomNavigationBar: SizedBox(
        height: 50.0,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: darkOrange,
          unselectedItemColor: Colors.grey,
          currentIndex: selectedIndex,
          selectedLabelStyle: labelTextStyle,
          unselectedLabelStyle: labelTextStyle,
          onTap: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'FOODORA',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'SEARCH',
            ),
            BottomNavigationBarItem(
              icon: Consumer<CartProvider>(
                builder: (context, cart, child) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.add_shopping_cart),
                      if (cart.itemCount > 0)
                        Positioned(
                          right: -6,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '${cart.itemCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              label: 'CART',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'ACCOUNT',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatbotFAB(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChatbotScreen(),
            ),
          );
        },
        backgroundColor: Colors.deepOrange[700],
        icon: const Text('🤖', style: TextStyle(fontSize: 20)),
        label: const Text(
          'AI Assistant',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        elevation: 8,
      ),
    );
  }
}
