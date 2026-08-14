import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'chat_screen.dart';

const Color diuBlue = Color(0xFF034EA2);
const Color diuGreen = Color(0xFF39B54A);
const Color diuGray = Color(0xFF636466);
const Color campusBg = Color(0xFFF6F8FB);

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String storeName = '';
  bool isLoadingStore = true;

  @override
  void initState() {
    super.initState();
    _loadStoreName();
  }

  Future<void> _loadStoreName() async {
    final storeId = widget.product['storeId']?.toString();
    if (storeId == null || storeId.isEmpty) {
      setState(() {
        storeName =
            widget.product['sellerName']?.toString() ?? 'CampusMart Seller';
        isLoadingStore = false;
      });
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('stores')
          .doc(storeId)
          .get();
      if (doc.exists) {
        final data = doc.data();
        setState(() {
          storeName = data?['storeName']?.toString() ?? 'CampusMart Store';
          isLoadingStore = false;
        });
      } else {
        setState(() {
          storeName =
              widget.product['sellerName']?.toString() ?? 'CampusMart Seller';
          isLoadingStore = false;
        });
      }
    } catch (e) {
      setState(() {
        storeName =
            widget.product['sellerName']?.toString() ?? 'CampusMart Seller';
        isLoadingStore = false;
      });
    }
  }

  Future<void> addToCart(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showMessage(context, 'Please login first.', error: true);
      return;
    }
    final sellerId = widget.product['sellerId']?.toString() ?? '';
    if (sellerId == user.uid) {
      _showMessage(
        context,
        'You cannot add your own product to cart.',
        error: true,
      );
      return;
    }
    final productId = widget.product['productId']?.toString();
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
          'name': widget.product['name'] ?? 'Unnamed Product',
          'price': widget.product['price'] ?? 0,
          'imageUrl': widget.product['imageUrl'] ?? '',
          'sellerId': widget.product['sellerId'] ?? '',
          'sellerName': widget.product['sellerName'] ?? 'CampusMart Seller',
          'category': widget.product['category'] ?? 'Other',
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

  void _openChat() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showMessage(context, 'Please login first.', error: true);
      return;
    }
    final sellerId = widget.product['sellerId']?.toString() ?? '';
    if (sellerId.isEmpty) {
      _showMessage(context, 'Seller not found.', error: true);
      return;
    }
    if (sellerId == user.uid) {
      _showMessage(context, 'You cannot chat with yourself.', error: true);
      return;
    }
    final sellerName = storeName.isNotEmpty
        ? storeName
        : (widget.product['sellerName']?.toString() ?? 'Seller');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          otherUserId: sellerId,
          otherUserName: sellerName,
          productTitle: widget.product['name']?.toString() ?? 'Product',
          productId: widget.product['productId']?.toString() ?? '',
          type: 'store', // <-- store type
        ),
      ),
    );
  }

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

  double _getPrice(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final String name = widget.product['name']?.toString() ?? 'Unnamed Product';
    final String category = widget.product['category']?.toString() ?? 'Other';
    final String imageUrl = widget.product['imageUrl']?.toString() ?? '';
    final String sellerId = widget.product['sellerId']?.toString() ?? '';
    final String description =
        widget.product['description']?.toString() ??
        'No description available.';
    final double price = _getPrice(widget.product['price']);
    final double rating = _getPrice(widget.product['rating']);
    final int stock = (widget.product['stock'] ?? 0) is num
        ? (widget.product['stock'] as num).toInt()
        : int.tryParse(widget.product['stock'].toString()) ?? 0;
    final currentUser = FirebaseAuth.instance.currentUser;
    final bool isOwnProduct =
        currentUser != null && sellerId == currentUser.uid;

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
          'Product Details',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () =>
                _showMessage(context, 'Favorite feature coming soon.'),
            icon: const Icon(Icons.favorite_border_rounded, color: diuGray),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
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
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: diuGray,
                          size: 75,
                        ),
                      ),
                    ),
            ),
            // Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Text(
                    name,
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 9),
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
            // Seller / Store
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.containsKey('storeId') ? 'Store' : 'Seller',
                    style: const TextStyle(
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
                          Icons.storefront_rounded,
                          color: diuGreen,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            isLoadingStore
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    storeName,
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
                              'Verified CampusMart Seller',
                              style: const TextStyle(
                                color: diuGray,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: _openChat,
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
            // Description
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
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: stock > 0 && !isOwnProduct
                        ? () => addToCart(context)
                        : null,
                    icon: const Icon(Icons.shopping_cart_outlined, size: 19),
                    label: Text(
                      isOwnProduct
                          ? 'Own Product'
                          : stock > 0
                          ? 'Add to Cart'
                          : 'Out of Stock',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isOwnProduct ? Colors.grey : diuGreen,
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
