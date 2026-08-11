import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'tuition_screen.dart';
import 'services_screen.dart';
import 'product_details_screen.dart';

const Color diuBlue = Color(0xFF034EA2);
const Color diuGreen = Color(0xFF39B54A);
const Color diuGray = Color(0xFF636466);
const Color campusBg = Color(0xFFF6F8FB);

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final TextEditingController searchController = TextEditingController();

  int selectedTab = 0;

  String selectedCategory = 'All';

  final List<String> categories = [
    'All',
    'Tech',
    'Books',
    'Clothing',
    'Plants',
    'Crafts',
    'Sports',
    'Fashion',
    'Services',
    'Others',
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // PRODUCT STREAM
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> getProductsStream() {
    return FirebaseFirestore.instance
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ============================================================
  // CATEGORY ICON
  // ============================================================

  IconData categoryIcon(String category) {
    switch (category) {
      case 'Tech':
        return Icons.devices_rounded;

      case 'Books':
        return Icons.menu_book_rounded;

      case 'Clothing':
        return Icons.checkroom_rounded;

      case 'Plants':
        return Icons.local_florist_rounded;

      case 'Crafts':
        return Icons.palette_rounded;

      case 'Sports':
        return Icons.sports_soccer_rounded;

      case 'Fashion':
        return Icons.shopping_bag_rounded;

      case 'Services':
        return Icons.handyman_rounded;

      case 'Others':
        return Icons.category_rounded;

      default:
        return Icons.grid_view_rounded;
    }
  }

  // ============================================================
  // FILTER PRODUCTS
  // ============================================================

  List<QueryDocumentSnapshot<Map<String, dynamic>>> filterProducts(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final search = searchController.text.trim().toLowerCase();

    return docs.where((doc) {
      final data = doc.data();

      final name = data['name']?.toString().toLowerCase() ?? '';

      final seller = data['sellerName']?.toString().toLowerCase() ?? '';

      final category = data['category']?.toString() ?? '';

      // Category filter
      if (selectedCategory != 'All' && category != selectedCategory) {
        return false;
      }

      // Search filter
      if (search.isNotEmpty) {
        return name.contains(search) ||
            seller.contains(search) ||
            category.toLowerCase().contains(search);
      }

      return true;
    }).toList();
  }

  // ============================================================
  // PRODUCT CARD
  // ============================================================

  Widget productCard(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final product = doc.data();

    final name = product['name']?.toString() ?? 'Unnamed Product';

    final seller = product['sellerName']?.toString() ?? 'CampusMart Seller';

    final imageUrl = product['imageUrl']?.toString() ?? '';

    final category = product['category']?.toString() ?? 'Other';

    final price = product['price'] ?? 0;

    final stock = product['stock'] ?? 0;

    final productData = Map<String, dynamic>.from(product);

    productData['productId'] = doc.id;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: productData),
          ),
        );
      },

      borderRadius: BorderRadius.circular(18),

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(18),

          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),

        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ==================================================
              // IMAGE
              // ==================================================

              Expanded(
                flex: 5,

                child: Stack(
                  children: [
                    SizedBox(
                      width: double.infinity,

                      height: double.infinity,

                      child: imageUrl.isEmpty
                          ? Container(
                              color: const Color(0xFFF1F3F5),

                              child: const Icon(
                                Icons.image_outlined,

                                color: diuGray,

                                size: 50,
                              ),
                            )
                          : Image.network(
                              imageUrl,

                              width: double.infinity,

                              height: double.infinity,

                              fit: BoxFit.cover,

                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: const Color(0xFFF1F3F5),

                                  child: const Icon(
                                    Icons.broken_image_outlined,

                                    color: diuGray,

                                    size: 45,
                                  ),
                                );
                              },
                            ),
                    ),

                    // Category badge
                    Positioned(
                      top: 9,
                      left: 9,

                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.92),

                          borderRadius: BorderRadius.circular(8),
                        ),

                        child: Text(
                          category,

                          style: const TextStyle(
                            color: diuBlue,

                            fontSize: 9,

                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ==================================================
              // PRODUCT INFORMATION
              // ==================================================
              Expanded(
                flex: 4,

                child: Padding(
                  padding: const EdgeInsets.all(11),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        name,

                        maxLines: 2,

                        overflow: TextOverflow.ellipsis,

                        style: const TextStyle(
                          color: Color(0xFF111827),

                          fontSize: 13,

                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        seller,

                        maxLines: 1,

                        overflow: TextOverflow.ellipsis,

                        style: const TextStyle(color: diuGray, fontSize: 9),
                      ),

                      const Spacer(),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          Text(
                            '৳$price',

                            style: const TextStyle(
                              color: diuBlue,

                              fontSize: 15,

                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Text(
                            stock > 0 ? 'In Stock' : 'Out of Stock',

                            style: TextStyle(
                              color: stock > 0 ? diuGreen : Colors.red,

                              fontSize: 8,

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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: campusBg,

      appBar: AppBar(
        backgroundColor: Colors.white,

        elevation: 0,

        title: const Text(
          'Marketplace',

          style: TextStyle(
            color: Color(0xFF111827),

            fontSize: 19,

            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            // ====================================================
            // SEARCH
            // ====================================================

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),

              child: TextField(
                controller: searchController,

                onChanged: (_) {
                  setState(() {});
                },

                decoration: InputDecoration(
                  hintText: 'Search products, sellers...',

                  hintStyle: const TextStyle(
                    color: Color(0xFF9CA3AF),

                    fontSize: 12,
                  ),

                  prefixIcon: const Icon(Icons.search_rounded, color: diuBlue),

                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            searchController.clear();

                            setState(() {});
                          },

                          icon: const Icon(
                            Icons.close_rounded,

                            size: 19,

                            color: diuGray,
                          ),
                        )
                      : null,

                  filled: true,

                  fillColor: Colors.white,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),

                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),

                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),

                    borderSide: const BorderSide(color: diuBlue, width: 1.3),
                  ),
                ),
              ),
            ),

            // ====================================================
            // MARKET TYPE TABS
            // ====================================================
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 5, 16, 8),

              child: Row(
                children: [
                  _marketTab(
                    index: 0,
                    icon: Icons.shopping_bag_outlined,
                    title: 'Products',
                  ),

                  const SizedBox(width: 8),

                  _marketTab(
                    index: 1,
                    icon: Icons.handyman_outlined,
                    title: 'Services',
                  ),

                  const SizedBox(width: 8),

                  _marketTab(
                    index: 2,
                    icon: Icons.school_outlined,
                    title: 'Tuition',
                  ),
                ],
              ),
            ),

            // ====================================================
            // CONTENT
            // ====================================================
            Expanded(
              child: selectedTab == 0
                  ? _productsTab()
                  : selectedTab == 1
                  ? _servicesTab()
                  : _tuitionTab(),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MARKET TAB
  // ============================================================

  Widget _marketTab({
    required int index,
    required IconData icon,
    required String title,
  }) {
    final selected = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = index;
          });
        },

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),

          padding: const EdgeInsets.symmetric(vertical: 10),

          decoration: BoxDecoration(
            color: selected ? diuBlue : Colors.white,

            borderRadius: BorderRadius.circular(12),

            border: Border.all(
              color: selected ? diuBlue : const Color(0xFFE5E7EB),
            ),
          ),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              Icon(icon, size: 17, color: selected ? Colors.white : diuBlue),

              const SizedBox(width: 5),

              Text(
                title,

                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF111827),

                  fontSize: 10,

                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PRODUCTS
  // ============================================================

  Widget _productsTab() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: getProductsStream(),

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: diuBlue));
        }

        if (snapshot.hasError) {
          return _errorState(snapshot.error.toString());
        }

        final docs = snapshot.data?.docs ?? [];

        final filtered = filterProducts(docs);

        return Column(
          children: [
            // ==================================================
            // CATEGORIES
            // ==================================================

            SizedBox(
              height: 52,

              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 5, 16, 5),

                scrollDirection: Axis.horizontal,

                itemCount: categories.length,

                itemBuilder: (context, index) {
                  final category = categories[index];

                  final selected = selectedCategory == category;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = category;
                      });
                    },

                    child: Container(
                      margin: const EdgeInsets.only(right: 8),

                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,

                        vertical: 8,
                      ),

                      decoration: BoxDecoration(
                        color: selected ? diuBlue : Colors.white,

                        borderRadius: BorderRadius.circular(20),

                        border: Border.all(
                          color: selected ? diuBlue : const Color(0xFFE5E7EB),
                        ),
                      ),

                      child: Row(
                        children: [
                          Icon(
                            categoryIcon(category),

                            size: 15,

                            color: selected ? Colors.white : diuBlue,
                          ),

                          const SizedBox(width: 5),

                          Text(
                            category,

                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : const Color(0xFF111827),

                              fontSize: 10,

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

            // ==================================================
            // PRODUCT GRID
            // ==================================================
            Expanded(
              child: filtered.isEmpty
                  ? _emptyProducts()
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 25),

                      itemCount: filtered.length,

                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,

                            crossAxisSpacing: 12,

                            mainAxisSpacing: 12,

                            childAspectRatio: .68,
                          ),

                      itemBuilder: (context, index) {
                        return productCard(context, filtered[index]);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // SERVICES
  // ============================================================

  Widget _servicesTab() {
    return const ServicesScreen();
  }

  // ============================================================
  // TUITION
  // ============================================================

  Widget _tuitionTab() {
    return const TuitionScreen();
  }

  // ============================================================
  // COMING SOON
  // ============================================================

  Widget _comingSoonMarket({
    required IconData icon,
    required String title,
    required String description,
    required String buttonText,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              width: 90,

              height: 90,

              decoration: BoxDecoration(
                color: diuBlue.withOpacity(.08),

                shape: BoxShape.circle,
              ),

              child: Icon(icon, color: diuBlue, size: 43),
            ),

            const SizedBox(height: 18),

            Text(
              title,

              textAlign: TextAlign.center,

              style: const TextStyle(
                color: Color(0xFF111827),

                fontSize: 19,

                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              description,

              textAlign: TextAlign.center,

              style: const TextStyle(color: diuGray, fontSize: 12, height: 1.5),
            ),

            const SizedBox(height: 18),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),

              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FB),

                borderRadius: BorderRadius.circular(20),
              ),

              child: const Text(
                'Coming Next',

                style: TextStyle(
                  color: diuBlue,

                  fontSize: 11,

                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY PRODUCTS
  // ============================================================

  Widget _emptyProducts() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          const Icon(Icons.search_off_rounded, color: diuGray, size: 55),

          const SizedBox(height: 12),

          const Text(
            'No products found',

            style: TextStyle(
              color: Color(0xFF111827),

              fontSize: 17,

              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Try another search or category.',

            style: TextStyle(color: diuGray, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _errorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            const Icon(
              Icons.error_outline_rounded,

              color: Colors.red,

              size: 50,
            ),

            const SizedBox(height: 10),

            const Text(
              'Could not load marketplace',

              style: TextStyle(
                color: Color(0xFF111827),

                fontSize: 16,

                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              error,

              textAlign: TextAlign.center,

              style: const TextStyle(color: diuGray, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
