import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'become_seller_screen.dart';

const Color diuBlue = Color(0xFF034EA2);
const Color diuGreen = Color(0xFF39B54A);
const Color diuGray = Color(0xFF636466);

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int currentIndex = 0;

  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();

    screens = [
      const HomeScreen(),
      const MarketPlaceholderScreen(),
      const BecomeSellerScreen(),
      const CartScreen(),
      const ProfileScreen(),
    ];
  }

  void changeTab(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: screens),

      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,

        backgroundColor: Colors.white,

        indicatorColor: const Color(0xFFEAF2FB),

        elevation: 8,

        onDestinationSelected: changeTab,

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: diuGray),

            selectedIcon: Icon(Icons.home_rounded, color: diuBlue),

            label: 'Home',
          ),

          NavigationDestination(
            icon: Icon(Icons.storefront_outlined, color: diuGray),

            selectedIcon: Icon(Icons.storefront_rounded, color: diuBlue),

            label: 'Market',
          ),

          NavigationDestination(
            icon: Icon(Icons.add_box_outlined, color: diuGray),

            selectedIcon: Icon(Icons.add_box_rounded, color: diuGreen),

            label: 'Sell',
          ),

          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined, color: diuGray),

            selectedIcon: Icon(Icons.shopping_cart_rounded, color: diuBlue),

            label: 'Cart',
          ),

          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded, color: diuGray),

            selectedIcon: Icon(Icons.person_rounded, color: diuBlue),

            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ================================================================
// TEMPORARY MARKET SCREEN
// ================================================================

class MarketPlaceholderScreen extends StatelessWidget {
  const MarketPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),

      appBar: AppBar(
        backgroundColor: Colors.white,

        elevation: 0,

        title: const Text(
          'Market',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Icon(Icons.storefront_outlined, color: diuBlue, size: 55),

            SizedBox(height: 12),

            Text(
              'Market',
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 5),

            Text(
              'Market screen will be connected next.',
              style: TextStyle(color: diuGray, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
