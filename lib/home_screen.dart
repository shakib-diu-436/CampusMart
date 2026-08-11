import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'marketplace_screen.dart';
import 'profile_screen.dart';
import 'cart_screen.dart';
import 'product_details_screen.dart';
import 'become_seller_screen.dart';

const Color diuBlue = Color(0xFF034EA2);
const Color diuGreen = Color(0xFF39B54A);
const Color diuGray = Color(0xFF636466);
const Color backgroundColor = Color(0xFFF6F8FB);
const Color lightGreen = Color(0xFFEAF7ED);

class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({super.key, this.userName = 'Student'});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedCategory = 0;

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      // =========================================================
      // APP BAR
      // =========================================================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 18,

        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: diuBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.shopping_bag_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),

            const SizedBox(width: 10),

            RichText(
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
          ],
        ),

        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded, color: diuGray),
          ),

          IconButton(
            onPressed: () {
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

      // =========================================================
      // BODY
      // =========================================================
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
                      // =================================================
                      // GREETING
                      // =================================================

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

                      // =================================================
                      // SEARCH
                      // =================================================
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Search products, sellers...',

                          hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),

                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: diuGray,
                          ),

                          suffixIcon: Container(
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

                      // =================================================
                      // PROMO BANNER
                      // =================================================
                      Container(
                        width: double.infinity,
                        height: 175,

                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [diuBlue, Color(0xFF1769C2)],

                            begin: Alignment.centerLeft,

                            end: Alignment.centerRight,
                          ),

                          borderRadius: BorderRadius.circular(22),

                          boxShadow: [
                            BoxShadow(
                              color: diuBlue.withOpacity(0.18),

                              blurRadius: 18,

                              offset: const Offset(0, 8),
                            ),
                          ],
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
                                    'Buy from students.\n'
                                    'Sell your products. Connect on campus.',

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
                                      onPressed: () {},

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

                      // =================================================
                      // CATEGORIES
                      // =================================================
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
                        height: 105,

                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,

                          itemCount: categories.length,

                          itemBuilder: (context, index) {
                            final bool selected = selectedCategory == index;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedCategory = index;
                                });
                              },

                              child: Container(
                                width: 78,

                                margin: const EdgeInsets.only(right: 12),

                                child: Column(
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),

                                      width: 62,
                                      height: 62,

                                      decoration: BoxDecoration(
                                        color: selected
                                            ? diuBlue
                                            : Colors.white,

                                        borderRadius: BorderRadius.circular(18),

                                        border: Border.all(
                                          color: selected
                                              ? diuBlue
                                              : const Color(0xFFE5E7EB),
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
                                        categoryIcon(categories[index]),

                                        color: selected
                                            ? Colors.white
                                            : diuBlue,

                                        size: 27,
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    Text(
                                      categories[index],

                                      textAlign: TextAlign.center,

                                      style: TextStyle(
                                        color: selected ? diuBlue : diuGray,

                                        fontSize: 12,

                                        fontWeight: selected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 18),

                      // =================================================
                      // POPULAR PRODUCTS HEADER
                      // =================================================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          const Text(
                            'Popular Products',

                            style: TextStyle(
                              color: Color(0xFF111827),
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          TextButton(
                            onPressed: () {},

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

                      // =================================================
                      // REAL FIRESTORE PRODUCTS
                      // =================================================
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('products')
                            .snapshots(),

                        builder: (context, snapshot) {
                          // =================================================
                          // LOADING
                          // =================================================

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

                          // =================================================
                          // ERROR
                          // =================================================

                          if (snapshot.hasError) {
                            return Container(
                              width: double.infinity,

                              padding: const EdgeInsets.all(25),

                              decoration: BoxDecoration(
                                color: Colors.white,

                                borderRadius: BorderRadius.circular(18),
                              ),

                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 45,
                                  ),

                                  const SizedBox(height: 10),

                                  const Text(
                                    'Could not load products',

                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    '${snapshot.error}',

                                    textAlign: TextAlign.center,

                                    style: const TextStyle(
                                      color: diuGray,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          // =================================================
                          // DATA
                          // =================================================

                          final List<QueryDocumentSnapshot> productDocs =
                              snapshot.data?.docs
                                  .cast<QueryDocumentSnapshot>() ??
                              [];

                          // =================================================
                          // CATEGORY FILTER
                          // =================================================

                          List<QueryDocumentSnapshot> filteredProducts =
                              productDocs;

                          if (selectedCategory != 0 &&
                              selectedCategory < categories.length) {
                            final String selectedCategoryName =
                                categories[selectedCategory];

                            filteredProducts = productDocs.where((doc) {
                              final data = doc.data() as Map<String, dynamic>;

                              return data['category'] == selectedCategoryName;
                            }).toList();
                          }

                          // =================================================
                          // EMPTY
                          // =================================================

                          if (filteredProducts.isEmpty) {
                            return Container(
                              width: double.infinity,

                              padding: const EdgeInsets.all(30),

                              decoration: BoxDecoration(
                                color: Colors.white,

                                borderRadius: BorderRadius.circular(18),

                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                ),
                              ),

                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.shopping_bag_outlined,
                                    color: diuGray,
                                    size: 50,
                                  ),

                                  const SizedBox(height: 12),

                                  Text(
                                    selectedCategory == 0
                                        ? 'No products available yet'
                                        : 'No products in ${categories[selectedCategory]}',

                                    style: const TextStyle(
                                      color: Color(0xFF111827),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 5),

                                  const Text(
                                    'Be the first student to list a product.',

                                    textAlign: TextAlign.center,

                                    style: TextStyle(
                                      color: diuGray,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          // =================================================
                          // PRODUCT GRID
                          // =================================================

                          return GridView.builder(
                            shrinkWrap: true,

                            physics: const NeverScrollableScrollPhysics(),

                            itemCount: filteredProducts.length,

                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: isDesktop ? 4 : 2,

                                  crossAxisSpacing: 14,

                                  mainAxisSpacing: 14,

                                  childAspectRatio: isDesktop ? 0.78 : 0.68,
                                ),

                            itemBuilder: (context, index) {
                              final QueryDocumentSnapshot doc =
                                  filteredProducts[index];

                              final Map<String, dynamic> product =
                                  doc.data() as Map<String, dynamic>;

                              // Add document ID
                              // for Product Details
                              product['productId'] = doc.id;

                              return ProductCard(product: product);
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 28),

                      // =================================================
                      // SELL CTA
                      // =================================================
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
                                color: lightGreen,

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
                              onPressed: () async {
                                await Navigator.push(
                                  context,

                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const BecomeSellerScreen(),
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

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),

      // =========================================================
      // BOTTOM NAVIGATION
      // =========================================================
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,

        backgroundColor: Colors.white,

        indicatorColor: const Color(0xFFEAF2FB),

        elevation: 8,

        onDestinationSelected: (index) {
          if (index == 0) {
            // Already on Home
            return;
          }

          if (index == 1) {
            // Market
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MarketplaceScreen()),
            );
            return;
          }

          if (index == 2) {
            // Sell
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BecomeSellerScreen()),
            );
            return;
          }

          if (index == 3) {
            // Cart
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            );
            return;
          }

          if (index == 4) {
            // Profile
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
            return;
          }
        },

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

  // =============================================================
  // CATEGORY ICON
  // =============================================================

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

      case 'Others':
        return Icons.category_rounded;

      default:
        return Icons.category_rounded;
    }
  }
}

// =================================================================
// PRODUCT CARD
// =================================================================

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final String name = product['name'] ?? 'Unnamed Product';

    final String seller =
        product['sellerName'] ?? product['seller'] ?? 'CampusMart Seller';

    final String imageUrl = product['imageUrl'] ?? '';

    final dynamic price = product['price'] ?? 0;

    final dynamic rating = product['rating'] ?? 0;

    final dynamic stock = product['stock'] ?? 0;

    return InkWell(
      borderRadius: BorderRadius.circular(17),

      onTap: () {
        Navigator.push(
          context,

          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(product: product),
          ),
        );
      },

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(17),

          border: Border.all(color: const Color(0xFFE5E7EB)),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),

              blurRadius: 8,

              offset: const Offset(0, 3),
            ),
          ],
        ),

        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // =====================================================
              // IMAGE
              // =====================================================

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

                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    }

                                    return const Center(
                                      child: CircularProgressIndicator(
                                        color: diuBlue,
                                        strokeWidth: 2,
                                      ),
                                    );
                                  },

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

                    // =================================================
                    // FAVORITE
                    // =================================================
                    Positioned(
                      top: 9,
                      right: 9,

                      child: Container(
                        width: 32,
                        height: 32,

                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),

                          shape: BoxShape.circle,
                        ),

                        child: const Icon(
                          Icons.favorite_border_rounded,

                          size: 18,

                          color: diuGray,
                        ),
                      ),
                    ),

                    // =================================================
                    // OUT OF STOCK
                    // =================================================
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

              // =====================================================
              // PRODUCT INFO
              // =====================================================
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

                              fontWeight: FontWeight.w600,
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
