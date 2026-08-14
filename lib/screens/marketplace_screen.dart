import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'tuition_screen.dart';
import 'services_screen.dart';
import 'product_details_screen.dart';
import 'store_screen.dart';
import 'student_listing_screen.dart';
import 'offer_service_screen.dart';
import 'offer_tuition_screen.dart';
import 'add_student_product_screen.dart';

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

  Stream<QuerySnapshot<Map<String, dynamic>>> getProductsStream() {
    return FirebaseFirestore.instance
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getStoresStream() {
    return FirebaseFirestore.instance
        .collection('stores')
        .where('isActive', isEqualTo: true)
        .snapshots();
  }

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

  List<QueryDocumentSnapshot<Map<String, dynamic>>> filterProducts(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final search = searchController.text.trim().toLowerCase();
    return docs.where((doc) {
      final data = doc.data();
      final name = data['name']?.toString().toLowerCase() ?? '';
      final seller = data['sellerName']?.toString().toLowerCase() ?? '';
      final category = data['category']?.toString().toLowerCase() ?? '';
      final description = data['description']?.toString().toLowerCase() ?? '';

      if (selectedCategory != 'All' &&
          category != selectedCategory.toLowerCase()) {
        return false;
      }

      if (search.isNotEmpty) {
        return name.contains(search) ||
            seller.contains(search) ||
            category.contains(search) ||
            description.contains(search);
      }

      return true;
    }).toList();
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> filterStores(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final search = searchController.text.trim().toLowerCase();
    if (search.isEmpty) {
      return docs;
    }
    return docs.where((doc) {
      final data = doc.data();
      final storeName = data['storeName']?.toString().toLowerCase() ?? '';
      final ownerName = data['ownerName']?.toString().toLowerCase() ?? '';
      final description = data['description']?.toString().toLowerCase() ?? '';
      return storeName.contains(search) ||
          ownerName.contains(search) ||
          description.contains(search);
    }).toList();
  }

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

  Widget storeCard(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final store = doc.data();
    final storeId = doc.id;
    final storeName = store['storeName']?.toString() ?? 'Unnamed Store';
    final ownerName = store['ownerName']?.toString() ?? 'DIU Student';
    final description = store['description']?.toString() ?? '';
    final logoUrl = store['logoUrl']?.toString() ?? '';
    final followerCount = store['followerCount'] ?? 0;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StoreScreen(
              sellerId: store['ownerId']?.toString() ?? '',
              storeId: storeId,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            StoreAvatar(
              logoUrl: logoUrl,
              ownerId: store['ownerId']?.toString() ?? '',
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    storeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    ownerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: diuGray, fontSize: 10),
                  ),
                  if (description.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: diuGray, fontSize: 10),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.people_outline,
                        color: diuGray,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$followerCount followers',
                        style: const TextStyle(color: diuGray, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: diuGray),
          ],
        ),
      ),
    );
  }

  Widget _studentsTab() {
    return const StudentListingBody();
  }

  Widget _servicesTab() {
    return const ServicesBody();
  }

  Widget _tuitionTab() {
    return const TuitionBody();
  }

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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: TextField(
              controller: searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: selectedTab == 3
                    ? 'Search stores...'
                    : selectedTab == 4
                    ? 'Search student listings...'
                    : 'Search products, sellers...',
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 5, 16, 8),
            child: Row(
              children: [
                _marketTab(
                  index: 0,
                  icon: Icons.shopping_bag_outlined,
                  title: 'Products',
                ),
                const SizedBox(width: 7),
                _marketTab(
                  index: 3,
                  icon: Icons.storefront_outlined,
                  title: 'Stores',
                ),
                const SizedBox(width: 7),
                _marketTab(
                  index: 1,
                  icon: Icons.handyman_outlined,
                  title: 'Services',
                ),
                const SizedBox(width: 7),
                _marketTab(
                  index: 2,
                  icon: Icons.school_outlined,
                  title: 'Tuition',
                ),
                const SizedBox(width: 7),
                _marketTab(
                  index: 4,
                  icon: Icons.recycling_rounded,
                  title: 'Students',
                ),
              ],
            ),
          ),
          Expanded(
            child: selectedTab == 0
                ? _productsTab()
                : selectedTab == 1
                ? _servicesTab()
                : selectedTab == 2
                ? _tuitionTab()
                : selectedTab == 3
                ? _storesTab()
                : _studentsTab(),
          ),
        ],
      ),
      floatingActionButton:
          (selectedTab == 1 || selectedTab == 2 || selectedTab == 4)
          ? FloatingActionButton(
              onPressed: () {
                if (selectedTab == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OfferServiceScreen(),
                    ),
                  );
                } else if (selectedTab == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OfferTuitionScreen(),
                    ),
                  );
                } else if (selectedTab == 4) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddStudentProductScreen(),
                    ),
                  );
                }
              },
              backgroundColor: diuGreen,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

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
            searchController.clear();
            selectedCategory = 'All';
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
              Icon(icon, size: 16, color: selected ? Colors.white : diuBlue),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF111827),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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

  Widget _storesTab() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: getStoresStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: diuBlue));
        }
        if (snapshot.hasError) {
          return _errorState(snapshot.error.toString());
        }
        final docs = snapshot.data?.docs ?? [];
        final filtered = filterStores(docs);

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.storefront_outlined, color: diuGray, size: 55),
                const SizedBox(height: 12),
                Text(
                  searchController.text.trim().isEmpty
                      ? 'No stores available'
                      : 'No stores found',
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Try another store name.',
                  style: TextStyle(color: diuGray, fontSize: 11),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 25),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            return storeCard(context, filtered[index]);
          },
        );
      },
    );
  }

  Widget _emptyProducts() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, color: diuGray, size: 55),
          SizedBox(height: 12),
          Text(
            'No products found',
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Try another search or category.',
            style: TextStyle(color: diuGray, fontSize: 11),
          ),
        ],
      ),
    );
  }

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

class StoreAvatar extends StatelessWidget {
  final String logoUrl;
  final String ownerId;

  const StoreAvatar({super.key, required this.logoUrl, required this.ownerId});

  @override
  Widget build(BuildContext context) {
    if (logoUrl.trim().isNotEmpty) {
      return _networkAvatar(logoUrl);
    }
    if (ownerId.trim().isEmpty) {
      return _defaultAvatar();
    }
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance.collection('users').doc(ownerId).get(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        final photoUrl =
            data?['photoURL']?.toString() ??
            data?['profileImage']?.toString() ??
            '';
        if (photoUrl.trim().isNotEmpty) {
          return _networkAvatar(photoUrl);
        }
        return _defaultAvatar();
      },
    );
  }

  Widget _networkAvatar(String url) {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FB),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFD7E5F5)),
      ),
      child: ClipOval(
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _defaultAvatar();
          },
        ),
      ),
    );
  }

  Widget _defaultAvatar() {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FB),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.storefront_rounded, color: diuBlue, size: 30),
    );
  }
}
