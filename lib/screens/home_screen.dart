import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'marketplace_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'become_seller_screen.dart';
import 'product_details_screen.dart';
import 'student_listing_screen.dart';
import 'main_navigation_screen.dart';

const Color diuBlue = Color(0xFF034EA2);
const Color diuGreen = Color(0xFF39B54A);
const Color diuGray = Color(0xFF636466);
const Color backgroundColor = Color(0xFFF6F8FB);

class HomeScreen extends StatefulWidget {
  final String userName;
  const HomeScreen({super.key, this.userName = 'Student'});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final TextEditingController searchController;
  String searchQuery = '';
  String? selectedCategory;

  final List<String> categories = [
    'Plants',
    'Books',
    'Tech',
    'Phones',
    'Computers',
    'Laptops',
    'Tablets',
    'Accessories',
    'Electronics',
    'Gaming',
    'Clothing',
    'Fashion',
    'Shoes',
    'Bags',
    'Crafts',
    'Stationery',
    'Beauty',
    'Food',
    'Home & Living',
    'Sports',
    'Services',
    'Others',
  ];

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void openMarketplace() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MarketplaceScreen()),
    );
  }

  bool matchesSearch(Map<String, dynamic> product) {
    if (searchQuery.trim().isEmpty) return true;
    final query = searchQuery.trim().toLowerCase();
    final name = (product['name'] ?? '').toString().toLowerCase();
    final seller = (product['sellerName'] ?? '').toString().toLowerCase();
    final category = (product['category'] ?? '').toString().toLowerCase();
    final description = (product['description'] ?? '').toString().toLowerCase();
    final storeName = (product['storeName'] ?? '').toString().toLowerCase();
    return name.contains(query) ||
        seller.contains(query) ||
        category.contains(query) ||
        description.contains(query) ||
        storeName.contains(query);
  }

  bool matchesCategory(Map<String, dynamic> product) {
    if (selectedCategory == null) return true;
    final productCategory = (product['category'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
    return productCategory == selectedCategory!.trim().toLowerCase();
  }

  IconData categoryIcon(String category) {
    switch (category) {
      case 'Plants':
        return Icons.local_florist_rounded;
      case 'Books':
        return Icons.menu_book_rounded;
      case 'Tech':
        return Icons.devices_rounded;
      case 'Phones':
        return Icons.smartphone_rounded;
      case 'Computers':
        return Icons.computer_rounded;
      case 'Laptops':
        return Icons.laptop_mac_rounded;
      case 'Tablets':
        return Icons.tablet_mac_rounded;
      case 'Accessories':
        return Icons.extension_rounded;
      case 'Electronics':
        return Icons.electrical_services_rounded;
      case 'Gaming':
        return Icons.sports_esports_rounded;
      case 'Clothing':
        return Icons.checkroom_rounded;
      case 'Fashion':
        return Icons.checkroom_rounded;
      case 'Shoes':
        return Icons.shopping_bag_rounded;
      case 'Bags':
        return Icons.shopping_bag_outlined;
      case 'Crafts':
        return Icons.palette_rounded;
      case 'Stationery':
        return Icons.edit_note_rounded;
      case 'Beauty':
        return Icons.face_retouching_natural_rounded;
      case 'Food':
        return Icons.restaurant_rounded;
      case 'Home & Living':
        return Icons.home_rounded;
      case 'Sports':
        return Icons.sports_soccer_rounded;
      case 'Services':
        return Icons.handyman_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 18,
        title: Row(
          children: [
            // ---- লোগো (অ্যাসেট + ফলব্যাক) ----
            SizedBox(
              width: 42,
              height: 42,
              child: Image.asset(
                'assets/images/campusmart_logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      color: diuBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'CM',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'CampusMart ',
                      style: TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: 'DIU',
                      style: TextStyle(
                        color: diuBlue,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded, color: diuGray),
          ),
          IconButton(
            onPressed: () {
              final navState = context
                  .findAncestorStateOfType<MainNavigationScreenState>();
              if (navState != null) {
                navState.selectTab(3);
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
            icon: const Icon(Icons.shopping_cart_outlined, color: diuBlue),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isDesktop = constraints.maxWidth > 800;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 40 : 18,
                vertical: 20,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${widget.userName}! 👋',
                        style: const TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Discover something amazing around your campus.',
                        style: TextStyle(color: diuGray, fontSize: 14),
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: searchController,
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search products, sellers...',
                          hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: diuGray,
                          ),
                          suffixIcon: searchQuery.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    searchController.clear();
                                    setState(() {
                                      searchQuery = '';
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    color: diuGray,
                                  ),
                                )
                              : Container(
                                  margin: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: diuBlue,
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  child: const Icon(
                                    Icons.tune_rounded,
                                    color: Colors.white,
                                    size: 19,
                                  ),
                                ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      Container(
                        width: double.infinity,
                        height: 175,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [diuBlue, Color(0xFF1769C2)],
                          ),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              right: -20,
                              top: -30,
                              child: Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 35,
                              bottom: -50,
                              child: Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  color: diuGreen.withOpacity(0.20),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'DIU Student Marketplace 🚀',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 7),
                                  const Text(
                                    'Buy from students.\nSell your products. Connect on campus.',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                  const Spacer(),
                                  SizedBox(
                                    height: 38,
                                    child: ElevatedButton(
                                      onPressed: openMarketplace,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: diuBlue,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'Explore Market',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Categories',
                        style: TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 108,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              final bool selected = selectedCategory == null;
                              return _categoryItem(
                                title: 'All',
                                icon: Icons.grid_view_rounded,
                                selected: selected,
                                onTap: () {
                                  setState(() {
                                    selectedCategory = null;
                                  });
                                },
                              );
                            }
                            final category = categories[index - 1];
                            final bool selected = selectedCategory == category;
                            return _categoryItem(
                              title: category,
                              icon: categoryIcon(category),
                              selected: selected,
                              onTap: () {
                                setState(() {
                                  selectedCategory = category;
                                });
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            searchQuery.trim().isNotEmpty
                                ? 'Search Results'
                                : selectedCategory != null
                                ? selectedCategory!
                                : 'Popular Products',
                            style: const TextStyle(
                              color: Color(0xFF111827),
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: openMarketplace,
                            child: const Text(
                              'View All',
                              style: TextStyle(
                                color: diuBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('products')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox(
                              height: 250,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: diuBlue,
                                ),
                              ),
                            );
                          }
                          if (snapshot.hasError) {
                            return _messageBox(
                              'Could not load products',
                              '${snapshot.error}',
                            );
                          }
                          final docs = snapshot.data?.docs ?? [];
                          final filtered = docs.where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return matchesSearch(data) && matchesCategory(data);
                          }).toList();
                          if (filtered.isEmpty) {
                            String message;
                            if (searchQuery.trim().isNotEmpty) {
                              message = 'No products found for "$searchQuery"';
                            } else if (selectedCategory != null) {
                              message = 'No products in $selectedCategory';
                            } else {
                              message = 'No products available yet';
                            }
                            return _messageBox(
                              message,
                              'Try another search or category.',
                            );
                          }
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filtered.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: isDesktop ? 4 : 2,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                  childAspectRatio: isDesktop ? 0.78 : 0.68,
                                ),
                            itemBuilder: (context, index) {
                              final doc = filtered[index];
                              final product = Map<String, dynamic>.from(
                                doc.data() as Map<String, dynamic>,
                              );
                              product['productId'] = doc.id;
                              return ProductCard(product: product);
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 28),
                      // ----- Have something to sell? -----
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF7ED),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.storefront_rounded,
                                color: diuGreen,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Have something to sell?',
                                    style: TextStyle(
                                      color: Color(0xFF111827),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Become a seller and reach DIU students.',
                                    style: TextStyle(
                                      color: diuGray,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const BecomeSellerScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: diuGreen,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Start Selling'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // ----- Student Marketplace -----
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF3E0),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.recycling_rounded,
                                color: Color(0xFFF57C00),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Student Marketplace',
                                    style: TextStyle(
                                      color: Color(0xFF111827),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Buy & sell new or used items from fellow students',
                                    style: TextStyle(
                                      color: diuGray,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const StudentListingScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF57C00),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Explore'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _categoryItem({
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 78,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: selected ? diuBlue : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected ? diuBlue : const Color(0xFFE5E7EB),
                ),
                boxShadow: [
                  if (selected)
                    BoxShadow(
                      color: diuBlue.withOpacity(0.20),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                ],
              ),
              child: Icon(
                icon,
                color: selected ? Colors.white : diuBlue,
                size: 27,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected ? diuBlue : diuGray,
                fontSize: 12,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _messageBox(String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          const Icon(Icons.shopping_bag_outlined, color: diuGray, size: 50),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: diuGray, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PRODUCT CARD
// ============================================================

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final name = product['name']?.toString() ?? 'Unnamed Product';
    final seller = product['sellerName']?.toString() ?? 'CampusMart Seller';
    final imageUrl = product['imageUrl']?.toString() ?? '';
    final price = product['price'] ?? 0;
    final rating = product['rating'] ?? 0;
    final stock = product['stock'] ?? 0;

    return InkWell(
      borderRadius: BorderRadius.circular(17),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Stack(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: imageUrl.trim().isEmpty
                          ? Container(
                              color: const Color(0xFFF0F2F5),
                              child: const Icon(
                                Icons.image_outlined,
                                color: diuGray,
                                size: 55,
                              ),
                            )
                          : Image.network(
                              imageUrl,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: const Color(0xFFF0F2F5),
                                  child: const Icon(
                                    Icons.broken_image_outlined,
                                    color: diuGray,
                                    size: 45,
                                  ),
                                );
                              },
                            ),
                    ),
                    Positioned(
                      top: 9,
                      right: 9,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.92),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite_border_rounded,
                          size: 18,
                          color: diuGray,
                        ),
                      ),
                    ),
                    if (stock == 0)
                      Positioned(
                        left: 9,
                        top: 9,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Out of Stock',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(11),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        seller,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: diuGray, fontSize: 10),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFF5B301),
                            size: 16,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            rating.toString(),
                            style: const TextStyle(
                              color: diuGray,
                              fontSize: 11,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '৳$price',
                            style: const TextStyle(
                              color: diuBlue,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
