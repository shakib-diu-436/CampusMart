import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'product_details_screen.dart';
import 'edit_store_screen.dart';

const Color diuBlue = Color(0xFF034EA2);
const Color diuGreen = Color(0xFF39B54A);
const Color diuGray = Color(0xFF636466);
const Color backgroundColor = Color(0xFFF6F8FB);

class StoreScreen extends StatelessWidget {
  final String sellerId;
  final String storeId;

  const StoreScreen({super.key, required this.sellerId, this.storeId = ''});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: diuGray),
        ),
        title: const Text(
          'My Store',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.bold,
          ),
        ),
        // ✅ Edit button added
        actions: [
          IconButton(
            onPressed: () {
              if (storeId.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditStoreScreen(storeId: storeId),
                  ),
                ).then((_) {
                  // Refresh the store screen when returning from edit
                  // (We can't directly refresh, but we'll just pop and come back)
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Store ID not found.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            icon: const Icon(Icons.edit_outlined, color: diuBlue),
          ),
        ],
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('stores')
            .where('ownerId', isEqualTo: sellerId)
            .limit(1)
            .get(),
        builder: (context, storeSnapshot) {
          if (storeSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: diuBlue),
            );
          }
          if (storeSnapshot.hasError) {
            return const Center(
              child: Text(
                'Could not load store.',
                style: TextStyle(color: diuGray),
              ),
            );
          }
          if (!storeSnapshot.hasData || storeSnapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Store not found.', style: TextStyle(color: diuGray)),
            );
          }

          final storeDoc = storeSnapshot.data!.docs.first;
          final store = storeDoc.data() as Map<String, dynamic>;
          final name = store['storeName']?.toString() ?? 'My Store';
          final description = store['description']?.toString() ?? '';
          final logoUrl = store['logoUrl']?.toString() ?? '';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Store header
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
                  child: Column(
                    children: [
                      Container(
                        width: 85,
                        height: 85,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.15),
                          shape: BoxShape.circle,
                        ),
                        child: logoUrl.isEmpty
                            ? const Icon(
                                Icons.storefront_rounded,
                                color: Colors.white,
                                size: 45,
                              )
                            : ClipOval(
                                child: Image.network(
                                  logoUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) {
                                    return const Icon(
                                      Icons.storefront_rounded,
                                      color: Colors.white,
                                      size: 45,
                                    );
                                  },
                                ),
                              ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 7),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'DIU Seller',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Text(
                          description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  'My Products',
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
                      .where('sellerId', isEqualTo: sellerId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(30),
                          child: CircularProgressIndicator(color: diuBlue),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(30),
                          child: Text(
                            'Could not load products.',
                            style: TextStyle(color: diuGray),
                          ),
                        ),
                      );
                    }
                    final products = snapshot.data?.docs ?? [];
                    if (products.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Color(0xFFE5E7EB)),
                        ),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              color: diuGray,
                              size: 45,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'No products yet',
                              style: TextStyle(
                                color: Color(0xFF111827),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Your products will appear here.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: diuGray, fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    }
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: products.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: .68,
                          ),
                      itemBuilder: (context, index) {
                        final doc = products[index];
                        final product = Map<String, dynamic>.from(
                          doc.data() as Map<String, dynamic>,
                        );
                        product['productId'] = doc.id;
                        return ProductCard(product: product);
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ProductCard widget (same as before – I'm including it for completeness)
class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final name = product['name']?.toString() ?? 'Unnamed Product';
    final imageUrl = product['imageUrl']?.toString() ?? '';
    final price = product['price'] ?? 0;
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
                child: imageUrl.isEmpty
                    ? Container(
                        color: const Color(0xFFF0F2F5),
                        child: const Center(
                          child: Icon(
                            Icons.image_outlined,
                            color: diuGray,
                            size: 50,
                          ),
                        ),
                      )
                    : Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Container(
                            color: const Color(0xFFF0F2F5),
                            child: const Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: diuGray,
                                size: 45,
                              ),
                            ),
                          );
                        },
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
                      const Spacer(),
                      Text(
                        '৳ $price',
                        style: const TextStyle(
                          color: diuGreen,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stock == 0 ? 'Out of Stock' : 'Stock: $stock',
                        style: TextStyle(
                          color: stock == 0 ? Colors.red : diuGray,
                          fontSize: 10,
                        ),
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
