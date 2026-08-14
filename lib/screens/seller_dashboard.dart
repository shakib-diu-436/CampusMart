import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'my_products_screen.dart';
import 'add_product_screen.dart';
import 'store_screen.dart';
import 'seller_orders_screen.dart';

const Color diuBlue = Color(0xFF034EA2);
const Color diuGreen = Color(0xFF39B54A);
const Color diuGray = Color(0xFF636466);
const Color backgroundColor = Color(0xFFF6F8FB);

class SellerDashboard extends StatefulWidget {
  const SellerDashboard({super.key});

  @override
  State<SellerDashboard> createState() => _SellerDashboardState();
}

class _SellerDashboardState extends State<SellerDashboard> {
  final user = FirebaseAuth.instance.currentUser;

  String storeName = 'My Store';
  String storeId = '';
  String storeDescription = '';
  String logoUrl = '';
  bool loadingStore = true;

  @override
  void initState() {
    super.initState();
    loadStore();
  }

  Future<void> loadStore() async {
    if (user == null) {
      setState(() {
        loadingStore = false;
      });
      return;
    }

    try {
      final firestore = FirebaseFirestore.instance;

      // First check users document
      final userDoc = await firestore.collection('users').doc(user!.uid).get();

      final userData = userDoc.data();

      final savedStoreId = userData?['storeId']?.toString() ?? '';
      final savedStoreName = userData?['storeName']?.toString() ?? '';

      if (savedStoreId.isNotEmpty) {
        final storeDoc = await firestore
            .collection('stores')
            .doc(savedStoreId)
            .get();

        if (storeDoc.exists) {
          final data = storeDoc.data()!;

          if (!mounted) return;

          setState(() {
            storeId = savedStoreId;
            storeName = data['storeName']?.toString().trim().isNotEmpty == true
                ? data['storeName'].toString()
                : savedStoreName.isNotEmpty
                ? savedStoreName
                : 'My Store';

            storeDescription = data['description']?.toString() ?? '';

            logoUrl = data['logoUrl']?.toString() ?? '';

            loadingStore = false;
          });

          return;
        }
      }

      // Fallback: search store by ownerId
      final storeQuery = await firestore
          .collection('stores')
          .where('ownerId', isEqualTo: user!.uid)
          .limit(1)
          .get();

      if (storeQuery.docs.isNotEmpty) {
        final doc = storeQuery.docs.first;
        final data = doc.data();

        if (!mounted) return;

        setState(() {
          storeId = doc.id;
          storeName = data['storeName']?.toString().trim().isNotEmpty == true
              ? data['storeName'].toString()
              : 'My Store';

          storeDescription = data['description']?.toString() ?? '';

          logoUrl = data['logoUrl']?.toString() ?? '';

          loadingStore = false;
        });
      } else {
        if (!mounted) return;

        setState(() {
          storeName = 'My Store';
          loadingStore = false;
        });
      }
    } catch (e) {
      debugPrint('Load Store Error: $e');

      if (!mounted) return;

      setState(() {
        loadingStore = false;
      });
    }
  }

  // ============================================================
  // OPEN MY STORE
  // ============================================================

  Future<void> openMyStore() async {
    if (user == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StoreScreen(sellerId: user!.uid, storeId: storeId),
      ),
    );
  }

  // ============================================================
  // OPEN ORDERS
  // ============================================================

  Future<void> openOrders() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SellerOrdersScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new, color: diuGray),
        ),

        title: const Text(
          'Seller Dashboard',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded, color: diuGray),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // =====================================================
                  // SELLER HEADER
                  // =====================================================

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),

                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [diuBlue, Color(0xFF1769C2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                    ),

                    child: Row(
                      children: [
                        // STORE LOGO
                        Container(
                          width: 65,
                          height: 65,

                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),

                          child: logoUrl.trim().isEmpty
                              ? const Icon(
                                  Icons.storefront_rounded,
                                  color: Colors.white,
                                  size: 34,
                                )
                              : ClipOval(
                                  child: Image.network(
                                    logoUrl,
                                    fit: BoxFit.cover,

                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.storefront_rounded,
                                        color: Colors.white,
                                        size: 34,
                                      );
                                    },
                                  ),
                                ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              const Text(
                                'My Store',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),

                              const SizedBox(height: 3),

                              loadingStore
                                  ? const SizedBox(
                                      height: 25,
                                      width: 25,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      storeName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                              const SizedBox(height: 5),

                              const Row(
                                children: [
                                  Icon(
                                    Icons.verified_rounded,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'DIU Verified Account',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // =====================================================
                  // OVERVIEW
                  // =====================================================
                  const Text(
                    'Overview',
                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 14),

                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('products')
                        .where('sellerId', isEqualTo: user?.uid)
                        .snapshots(),

                    builder: (context, snapshot) {
                      int productCount = 0;

                      if (snapshot.hasData) {
                        productCount = snapshot.data!.docs.length;
                      }

                      return Row(
                        children: [
                          Expanded(
                            child: statCard(
                              icon: Icons.inventory_2_outlined,
                              title: 'Products',
                              value: productCount.toString(),
                              color: diuBlue,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('orders')
                                  .where('sellerIds', arrayContains: user?.uid)
                                  .snapshots(),

                              builder: (context, snapshot) {
                                final count = snapshot.hasData
                                    ? snapshot.data!.docs.length
                                    : 0;

                                return statCard(
                                  icon: Icons.shopping_bag_outlined,
                                  title: 'Orders',
                                  value: count.toString(),
                                  color: diuGreen,
                                );
                              },
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: statCard(
                              icon: Icons.star_outline_rounded,
                              title: 'Rating',
                              value: '—',
                              color: const Color(0xFFF59E0B),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // =====================================================
                  // QUICK ACTIONS
                  // =====================================================
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: actionCard(
                          context,

                          icon: Icons.add_box_rounded,

                          title: 'Add Product',

                          subtitle: 'List a new product',

                          color: diuGreen,

                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AddProductScreen(),
                              ),
                            );

                            setState(() {});
                          },
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: actionCard(
                          context,

                          icon: Icons.inventory_2_rounded,

                          title: 'My Products',

                          subtitle: 'Manage your listings',

                          color: diuBlue,

                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MyProductsScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      // ORDERS
                      Expanded(
                        child: actionCard(
                          context,

                          icon: Icons.receipt_long_rounded,

                          title: 'Orders',

                          subtitle: 'View customer orders',

                          color: const Color(0xFFF59E0B),

                          onTap: openOrders,
                        ),
                      ),

                      const SizedBox(width: 14),

                      // MY STORE
                      Expanded(
                        child: actionCard(
                          context,

                          icon: Icons.storefront_rounded,

                          title: 'My Store',

                          subtitle: 'View your storefront',

                          color: diuBlue,

                          onTap: openMyStore,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // =====================================================
                  // SELLER INFORMATION
                  // =====================================================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.verified_user_outlined,
                              color: diuGreen,
                              size: 23,
                            ),

                            SizedBox(width: 9),

                            Text(
                              'Seller Status',
                              style: TextStyle(
                                color: Color(0xFF111827),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(13),

                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF7ED),
                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: const Row(
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: diuGreen,
                                size: 20,
                              ),

                              SizedBox(width: 9),

                              Expanded(
                                child: Text(
                                  'You are an active CampusMart seller.',
                                  style: TextStyle(
                                    color: Color(0xFF166534),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        if (storeName.isNotEmpty)
                          Text(
                            storeName,
                            style: const TextStyle(
                              color: Color(0xFF111827),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                        const SizedBox(height: 4),

                        Text(
                          user?.email ?? 'DIU Account',
                          style: const TextStyle(color: diuGray, fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =============================================================
  // STAT CARD
  // =============================================================

  Widget statCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Container(
            width: 38,
            height: 38,

            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),

            child: Icon(icon, color: color, size: 21),
          ),

          const SizedBox(height: 12),

          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 2),

          Text(title, style: const TextStyle(color: diuGray, fontSize: 11)),
        ],
      ),
    );
  }

  // =============================================================
  // ACTION CARD
  // =============================================================

  Widget actionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(17),
      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),

        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,

              decoration: BoxDecoration(
                color: color.withOpacity(0.10),
                borderRadius: BorderRadius.circular(13),
              ),

              child: Icon(icon, color: color, size: 25),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    subtitle,
                    style: const TextStyle(color: diuGray, fontSize: 10),
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
}
