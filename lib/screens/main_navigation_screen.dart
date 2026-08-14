import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'home_screen.dart';
import 'marketplace_screen.dart';
import 'become_seller_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';

const Color diuBlue = Color(0xFF034EA2);
const Color diuGreen = Color(0xFF39B54A);
const Color diuGray = Color(0xFF636466);

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      _buildNavigator(0, const HomeScreen()),
      _buildNavigator(1, const MarketplaceScreen()),
      _buildNavigator(2, const BecomeSellerScreen()),
      _buildNavigator(3, const CartScreen()),
      _buildNavigator(4, const ProfileScreen()),
    ];
  }

  Widget _buildNavigator(int index, Widget screen) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) return;

        final navigator = _navigatorKeys[index].currentState;
        if (navigator != null && navigator.canPop()) {
          // If there is a nested route, pop it
          navigator.pop();
          return;
        }

        // At root of the current tab
        if (index != 0) {
          // Switch to Home tab
          setState(() {
            _selectedIndex = 0;
          });
          return;
        }

        // On Home tab, ask for confirmation before exiting
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: const Text(
              'Exit CampusMart?',
              style: TextStyle(
                color: Color(0xFF111827),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'Are you sure you want to exit the app?',
              style: TextStyle(color: diuGray, fontSize: 13, height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel', style: TextStyle(color: diuGray)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
                child: const Text('Exit'),
              ),
            ],
          ),
        );

        if (shouldExit == true) {
          // Exit the app (works on Android and iOS)
          SystemNavigator.pop();
        }
      },
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (settings) {
          // Default route: return the screen
          return MaterialPageRoute(builder: (_) => screen);
        },
      ),
    );
  }

  void _onTabTapped(int index) {
    // If already on the same tab, pop to root of that tab
    if (_selectedIndex == index) {
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFEAF2FB),
        elevation: 8,
        onDestinationSelected: _onTabTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: diuBlue),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront_rounded, color: diuBlue),
            label: 'Market',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_box_outlined),
            selectedIcon: Icon(Icons.add_box_rounded, color: diuGreen),
            label: 'Sell',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart_rounded, color: diuBlue),
            label: 'Cart',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: diuBlue),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
