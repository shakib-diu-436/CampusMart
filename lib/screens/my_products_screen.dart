import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'edit_product_screen.dart';

const Color diuBlue = Color(0xFF034EA2);
const Color diuGreen = Color(0xFF39B54A);
const Color diuGray = Color(0xFF636466);

class MyProductsScreen extends StatelessWidget {
  const MyProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please login first.')));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),

        title: const Text(
          'My Products',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('sellerId', isEqualTo: user.uid)
            .snapshots(),

        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: diuGreen),
            );
          }

          // Error
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 55,
                      color: Colors.red,
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      'Could not load products',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: diuGray, fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          }

          final products = snapshot.data?.docs ?? [];

          // Empty
          if (products.isEmpty) {
            return _emptyState(context);
          }

          return RefreshIndicator(
            color: diuGreen,

            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 500));
            },

            child: ListView.builder(
              padding: const EdgeInsets.all(18),
              itemCount: products.length,

              itemBuilder: (context, index) {
                final product = products[index];

                final data = product.data() as Map<String, dynamic>;

                return _productCard(context, product.id, data);
              },
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // PRODUCT CARD
  // ============================================================

  Widget _productCard(
    BuildContext context,
    String productId,
    Map<String, dynamic> data,
  ) {
    final String name = data['name'] ?? 'Unnamed Product';

    final String category = data['category'] ?? 'Other';

    final String imageUrl = data['imageUrl'] ?? '';

    final dynamic price = data['price'] ?? 0;

    final dynamic stock = data['stock'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: const Color(0xFFE5E7EB)),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Padding(
        padding: const EdgeInsets.all(12),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(12),

              child: SizedBox(
                width: 105,
                height: 105,

                child: imageUrl.isEmpty
                    ? Container(
                        color: const Color(0xFFF0F2F5),
                        child: const Icon(
                          Icons.image_outlined,
                          color: diuGray,
                          size: 40,
                        ),
                      )
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,

                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFFF0F2F5),
                            child: const Icon(
                              Icons.broken_image_outlined,
                              color: diuGray,
                              size: 38,
                            ),
                          );
                        },
                      ),
              ),
            ),

            const SizedBox(width: 14),

            // INFORMATION
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    name,

                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,

                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),

                  const SizedBox(height: 5),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),

                    decoration: BoxDecoration(
                      color: diuBlue.withOpacity(0.08),

                      borderRadius: BorderRadius.circular(6),
                    ),

                    child: Text(
                      category,
                      style: const TextStyle(
                        color: diuBlue,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '৳$price',
                    style: const TextStyle(
                      color: diuGreen,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Stock: $stock',
                    style: TextStyle(
                      color: stock > 0 ? diuGray : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // MENU
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: diuGray),

              onSelected: (value) {
                if (value == 'edit') {
                  _editProduct(context, productId, data);
                }

                if (value == 'delete') {
                  _deleteProduct(context, productId, name);
                }
              },

              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, color: diuBlue),
                      SizedBox(width: 10),
                      Text('Edit'),
                    ],
                  ),
                ),

                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.red),
                      SizedBox(width: 10),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              width: 100,
              height: 100,

              decoration: BoxDecoration(
                color: diuGreen.withOpacity(0.10),
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.inventory_2_outlined,
                color: diuGreen,
                size: 50,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'No products yet',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Start selling by adding your first product.',
              textAlign: TextAlign.center,
              style: TextStyle(color: diuGray, fontSize: 14),
            ),

            const SizedBox(height: 22),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },

              icon: const Icon(Icons.add),

              label: const Text('Add Your First Product'),

              style: ElevatedButton.styleFrom(
                backgroundColor: diuGreen,
                foregroundColor: Colors.white,
                elevation: 0,

                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 13,
                ),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DELETE PRODUCT
  // ============================================================

  Future<void> _deleteProduct(
    BuildContext context,
    String productId,
    String productName,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Product?'),

          content: Text('Are you sure you want to delete "$productName"?'),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },

              child: const Text('Cancel'),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },

              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .delete();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product deleted successfully.'),
          backgroundColor: diuGreen,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not delete product.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // EDIT PRODUCT
  // ============================================================

  void _editProduct(
    BuildContext context,
    String productId,
    Map<String, dynamic> data,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditProductScreen(productId: productId, product: data),
      ),
    );
  }
}
