import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// ================================================================
// CAMPUSMART COLORS
// ================================================================

const Color diuBlue = Color(0xFF034EA2);
const Color diuGreen = Color(0xFF39B54A);
const Color diuGray = Color(0xFF636466);
const Color campusBg = Color(0xFFF6F8FB);

class ProductDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailsScreen({super.key, required this.product});

  // ==============================================================
  // ADD PRODUCT TO CART
  // ==============================================================

  Future<void> addToCart(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage(context, 'Please login first.', error: true);
      return;
    }

    final productId = product['productId']?.toString();

    if (productId == null || productId.isEmpty) {
      _showMessage(context, 'Product ID not found.', error: true);
      return;
    }

    try {
      final cartRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .doc(productId);

      final existing = await cartRef.get();

      if (existing.exists) {
        final data = existing.data();

        final currentQuantity = (data?['quantity'] ?? 1) as num;

        await cartRef.update({
          'quantity': currentQuantity.toInt() + 1,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await cartRef.set({
          'productId': productId,
          'name': product['name'] ?? 'Unnamed Product',
          'price': product['price'] ?? 0,
          'imageUrl': product['imageUrl'] ?? '',
          'sellerId': product['sellerId'] ?? '',
          'sellerName': product['sellerName'] ?? 'CampusMart Seller',
          'category': product['category'] ?? 'Other',
          'quantity': 1,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      if (!context.mounted) return;

      _showMessage(context, 'Product added to cart! 🛒');
    } catch (e) {
      debugPrint('ADD TO CART ERROR: $e');

      if (!context.mounted) return;

      _showMessage(context, 'Cart Error: $e', error: true);
    }
  }

  // ==============================================================
  // SNACKBAR
  // ==============================================================

  void _showMessage(
    BuildContext context,
    String message, {
    bool error = false,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: error ? Colors.red : diuGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ==============================================================
  // PRICE
  // ==============================================================

  double _getPrice(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }

  // ==============================================================
  // BUILD
  // ==============================================================

  @override
  Widget build(BuildContext context) {
    final String name = product['name']?.toString() ?? 'Unnamed Product';

    final String category = product['category']?.toString() ?? 'Other';

    final String imageUrl = product['imageUrl']?.toString() ?? '';

    final String sellerName =
        product['sellerName']?.toString() ?? 'CampusMart Seller';

    final String sellerId = product['sellerId']?.toString() ?? '';

    final String description =
        product['description']?.toString() ?? 'No description available.';

    final double price = _getPrice(product['price']);

    final double rating = _getPrice(product['rating']);

    final int stock = (product['stock'] ?? 0) is num
        ? (product['stock'] as num).toInt()
        : int.tryParse(product['stock'].toString()) ?? 0;

    return Scaffold(
      backgroundColor: campusBg,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: diuGray,
            size: 20,
          ),
        ),

        title: const Text(
          'Product Details',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            onPressed: () {
              // Favorite feature will be connected later.
              _showMessage(context, 'Favorite feature coming soon.');
            },
            icon: const Icon(Icons.favorite_border_rounded, color: diuGray),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========================================================
            // PRODUCT IMAGE
            // ========================================================

            Container(
              width: double.infinity,
              height: 310,
              color: Colors.white,

              child: imageUrl.isEmpty
                  ? const Center(
                      child: Icon(
                        Icons.image_outlined,
                        color: diuGray,
                        size: 75,
                      ),
                    )
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.contain,

                      errorBuilder: (_, __, ___) {
                        return const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: diuGray,
                            size: 75,
                          ),
                        );
                      },
                    ),
            ),

            // ========================================================
            // PRODUCT INFORMATION
            // ========================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
              color: Colors.white,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CATEGORY
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),

                    decoration: BoxDecoration(
                      color: diuBlue.withOpacity(.08),
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Text(
                      category,
                      style: const TextStyle(
                        color: diuBlue,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // NAME
                  Text(
                    name,
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 9),

                  // RATING + STOCK
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFFB800),
                        size: 19,
                      ),

                      const SizedBox(width: 4),

                      Text(
                        rating > 0 ? rating.toStringAsFixed(1) : 'New',

                        style: const TextStyle(
                          color: Color(0xFF374151),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(width: 14),

                      Container(
                        width: 4,
                        height: 4,

                        decoration: const BoxDecoration(
                          color: diuGray,
                          shape: BoxShape.circle,
                        ),
                      ),

                      const SizedBox(width: 14),

                      Text(
                        stock > 0 ? '$stock available' : 'Out of stock',

                        style: TextStyle(
                          color: stock > 0 ? diuGreen : Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // PRICE
                  Text(
                    '৳${price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: diuBlue,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ========================================================
            // SELLER
            // ========================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              color: Colors.white,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Seller',
                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Container(
                        width: 43,
                        height: 43,

                        decoration: BoxDecoration(
                          color: diuGreen.withOpacity(.10),
                          borderRadius: BorderRadius.circular(12),
                        ),

                        child: const Icon(
                          Icons.person_outline_rounded,
                          color: diuGreen,
                          size: 24,
                        ),
                      ),

                      const SizedBox(width: 11),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sellerName,

                              maxLines: 1,

                              overflow: TextOverflow.ellipsis,

                              style: const TextStyle(
                                color: Color(0xFF111827),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 3),

                            Text(
                              sellerId.isEmpty
                                  ? 'DIU CampusMart Seller'
                                  : 'Verified CampusMart Seller',

                              style: const TextStyle(
                                color: diuGray,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),

                      OutlinedButton(
                        onPressed: () {
                          _showMessage(context, 'Chat feature coming soon.');
                        },

                        style: OutlinedButton.styleFrom(
                          foregroundColor: diuBlue,

                          side: const BorderSide(color: diuBlue),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),

                        child: const Text(
                          'Chat',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ========================================================
            // DESCRIPTION
            // ========================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              color: Colors.white,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Description',
                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 9),

                  Text(
                    description,
                    style: const TextStyle(
                      color: diuGray,
                      fontSize: 12,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ============================================================
      // BOTTOM ADD TO CART
      // ============================================================
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),

          decoration: const BoxDecoration(
            color: Colors.white,

            boxShadow: [
              BoxShadow(
                color: Color(0x18000000),
                blurRadius: 10,
                offset: Offset(0, -3),
              ),
            ],
          ),

          child: Row(
            children: [
              // PRICE
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Price',
                      style: TextStyle(color: diuGray, fontSize: 10),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      '৳${price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: diuBlue,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // ADD TO CART
              Expanded(
                flex: 2,

                child: SizedBox(
                  height: 48,

                  child: ElevatedButton.icon(
                    onPressed: stock > 0 ? () => addToCart(context) : null,

                    icon: const Icon(Icons.shopping_cart_outlined, size: 19),

                    label: Text(
                      stock > 0 ? 'Add to Cart' : 'Out of Stock',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: diuGreen,

                      disabledBackgroundColor: Colors.grey.shade400,

                      foregroundColor: Colors.white,

                      elevation: 0,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
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
