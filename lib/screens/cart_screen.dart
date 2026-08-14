import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'checkout_screen.dart';
import 'main_navigation_screen.dart';

const Color diuBlue = Color(0xFF034EA2);
const Color diuGreen = Color(0xFF39B54A);
const Color diuGray = Color(0xFF636466);
const Color campusBg = Color(0xFFF6F8FB);

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  // ============================================================
  // CART REFERENCE
  // ============================================================

  CollectionReference<Map<String, dynamic>> getCartRef() {
    final user = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('cart');
  }

  // ============================================================
  // PRICE CONVERTER
  // ============================================================

  double getPrice(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  // ============================================================
  // QUANTITY UPDATE
  // ============================================================

  Future<void> updateQuantity(String productId, int quantity) async {
    final cartItem = getCartRef().doc(productId);
    if (quantity <= 0) {
      await cartItem.delete();
      return;
    }
    await cartItem.update({
      'quantity': quantity,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // REMOVE ITEM
  // ============================================================

  Future<void> removeItem(String productId) async {
    await getCartRef().doc(productId).delete();
  }

  // ============================================================
  // PREPARE CHECKOUT ITEMS
  // ============================================================

  Future<List<Map<String, dynamic>>> prepareCheckoutItems(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    final cartItems = <Map<String, dynamic>>[];
    for (final doc in docs) {
      final cartData = doc.data();
      final productId = doc.id;
      final productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();
      final productData = productSnapshot.data();
      final item = <String, dynamic>{...cartData};
      item['productId'] = productId;
      if (productData != null) {
        item['sellerId'] = productData['sellerId'];
        item['sellerName'] = productData['sellerName'];
        if (!item.containsKey('imageUrl') ||
            item['imageUrl']?.toString().isEmpty == true) {
          item['imageUrl'] = productData['imageUrl'];
        }
        if (!item.containsKey('category')) {
          item['category'] = productData['category'];
        }
      }
      cartItems.add(item);
    }
    return cartItems;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: campusBg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: diuGray,
              size: 20,
            ),
          ),
          title: const Text(
            'My Cart',
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: const Center(
          child: Text(
            'Please login to view your cart.',
            style: TextStyle(color: diuGray),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: campusBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: diuGray,
            size: 20,
          ),
        ),
        title: const Text(
          'My Cart',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: getCartRef().snapshots(),
            builder: (context, snapshot) {
              final count = snapshot.data?.docs.length ?? 0;
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: diuBlue.withOpacity(.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$count items',
                      style: const TextStyle(
                        color: diuBlue,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: getCartRef().snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: diuBlue),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 35,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Could not load cart',
                      style: TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: diuGray, fontSize: 11),
                    ),
                  ],
                ),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return _buildEmptyCart(context);
          }

          double subtotal = 0;
          int totalItems = 0;
          for (final doc in docs) {
            final data = doc.data();
            final price = getPrice(data['price']);
            final quantityValue = data['quantity'] ?? 1;
            final quantity = quantityValue is num
                ? quantityValue.toInt()
                : int.tryParse(quantityValue.toString()) ?? 1;
            subtotal += price * quantity;
            totalItems += quantity;
          }

          const double deliveryFee = 60;
          final double total = subtotal + deliveryFee;

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                  itemCount: docs.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    return _buildCartItem(context, doc.id, doc.data());
                  },
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(18, 17, 18, 18),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x16000000),
                      blurRadius: 15,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Items',
                            style: TextStyle(color: diuGray, fontSize: 13),
                          ),
                          Text(
                            '$totalItems items',
                            style: const TextStyle(
                              color: Color(0xFF111827),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 9),
                      _summaryRow(
                        'Subtotal',
                        '৳${subtotal.toStringAsFixed(0)}',
                      ),
                      const SizedBox(height: 8),
                      _summaryRow(
                        'Delivery Fee',
                        '৳${deliveryFee.toStringAsFixed(0)}',
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(height: 1),
                      ),
                      _summaryRow(
                        'Total',
                        '৳${total.toStringAsFixed(0)}',
                        bold: true,
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              final cartItems = await prepareCheckoutItems(
                                docs,
                              );
                              if (!context.mounted) return;
                              final missingSeller = cartItems.any(
                                (item) =>
                                    item['sellerId'] == null ||
                                    item['sellerId'].toString().isEmpty,
                              );
                              if (missingSeller) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Seller information not found for one or more products.',
                                    ),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                return;
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CheckoutScreen(
                                    cartItems: cartItems,
                                    subtotal: subtotal,
                                    deliveryFee: deliveryFee,
                                    total: total,
                                  ),
                                ),
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Could not prepare checkout: $e',
                                  ),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.arrow_forward_rounded,
                            size: 20,
                          ),
                          label: Text(
                            'Proceed to Checkout • ৳${total.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: diuGreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    String productId,
    Map<String, dynamic> data,
  ) {
    final String name = data['name']?.toString() ?? 'Unnamed Product';
    final String seller = data['sellerName']?.toString() ?? 'CampusMart Seller';
    final String imageUrl = data['imageUrl']?.toString() ?? '';
    final double price = getPrice(data['price']);
    final quantityValue = data['quantity'] ?? 1;
    final int quantity = quantityValue is num
        ? quantityValue.toInt()
        : int.tryParse(quantityValue.toString()) ?? 1;
    final double itemTotal = price * quantity;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 90,
              height: 90,
              color: const Color(0xFFF1F5F9),
              child: imageUrl.isEmpty
                  ? const Icon(Icons.image_outlined, color: diuGray, size: 38)
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.broken_image_outlined,
                          color: diuGray,
                          size: 38,
                        );
                      },
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
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
                const SizedBox(height: 7),
                Text(
                  '৳${price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: diuBlue,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _quantityButton(
                      icon: Icons.remove_rounded,
                      onTap: () {
                        updateQuantity(productId, quantity - 1);
                      },
                    ),
                    Container(
                      width: 38,
                      height: 30,
                      alignment: Alignment.center,
                      color: const Color(0xFFF5F7FA),
                      child: Text(
                        '$quantity',
                        style: const TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _quantityButton(
                      icon: Icons.add_rounded,
                      onTap: () {
                        updateQuantity(productId, quantity + 1);
                      },
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '৳${itemTotal.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              await removeItem(productId);
            },
            tooltip: 'Remove from cart',
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.red,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _quantityButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: diuBlue.withOpacity(.08),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(icon, color: diuBlue, size: 15),
      ),
    );
  }

  Widget _summaryRow(String title, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: bold ? const Color(0xFF111827) : diuGray,
            fontSize: bold ? 15 : 13,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: bold ? diuBlue : const Color(0xFF111827),
            fontSize: bold ? 19 : 13,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
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
                color: diuBlue.withOpacity(.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                color: diuBlue,
                size: 50,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Your cart is empty',
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Looks like you haven’t added anything yet.\n'
              'Explore the marketplace and find something you like.',
              textAlign: TextAlign.center,
              style: TextStyle(color: diuGray, fontSize: 12, height: 1.5),
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: () {
                final navState = context
                    .findAncestorStateOfType<MainNavigationScreenState>();
                if (navState != null) {
                  navState.selectTab(0);
                  return;
                }

                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                  return;
                }
              },
              icon: const Icon(Icons.storefront_rounded, size: 18),
              label: const Text('Continue Shopping'),
              style: ElevatedButton.styleFrom(
                backgroundColor: diuBlue,
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
}
