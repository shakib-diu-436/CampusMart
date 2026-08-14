import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/order_provider.dart';
import '../services/user_service.dart';
import 'chat_screen.dart';

const Color diuBlue = Color(0xFF034EA2);
const Color diuGreen = Color(0xFF39B54A);
const Color diuGray = Color(0xFF636466);
const Color campusBg = Color(0xFFF6F8FB);

class StudentProductDetailsScreen extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> productData;
  const StudentProductDetailsScreen({
    super.key,
    required this.productId,
    required this.productData,
  });

  @override
  State<StudentProductDetailsScreen> createState() =>
      _StudentProductDetailsScreenState();
}

class _StudentProductDetailsScreenState
    extends State<StudentProductDetailsScreen> {
  bool isBuying = false;

  Future<void> _buyNow() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login first.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final sellerId = widget.productData['studentId']?.toString() ?? '';
    if (sellerId == user.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You cannot buy your own item.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    setState(() => isBuying = true);
    try {
      final buyerName = await UserService().getCurrentUserName();
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      await orderProvider.placeOrder(
        buyerId: user.uid,
        buyerName: buyerName,
        sellerId: sellerId,
        items: [
          {
            'productId': widget.productId,
            'name': widget.productData['title'] ?? 'Untitled',
            'price': widget.productData['price'] ?? 0,
            'imageUrl': widget.productData['imageUrl'] ?? '',
            'quantity': 1,
            'sellerId': sellerId,
            'sellerName': widget.productData['studentName'] ?? 'DIU Student',
          },
        ],
        subtotal: (widget.productData['price'] ?? 0).toDouble(),
        deliveryFee: 0,
        total: (widget.productData['price'] ?? 0).toDouble(),
        customerName: user.displayName ?? 'Student',
        phone: '',
        address: '',
        note: '',
        paymentMethod: 'cash_on_delivery',
      );
      if (!mounted) return;
      setState(() => isBuying = false);
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: diuGreen.withOpacity(.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: diuGreen,
                  size: 42,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Order Placed!',
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'The seller will contact you soon.',
                textAlign: TextAlign.center,
                style: TextStyle(color: diuGray, fontSize: 12, height: 1.5),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: diuBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => isBuying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not place order: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openChat() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login first.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final sellerId = widget.productData['studentId']?.toString() ?? '';
    if (sellerId == user.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You cannot chat with yourself.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          otherUserId: sellerId,
          otherUserName:
              widget.productData['studentName']?.toString() ?? 'Seller',
          productTitle: widget.productData['title']?.toString() ?? 'Item',
          productId: widget.productId,
          type: 'student', // <-- student type
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.productData['title']?.toString() ?? 'Untitled';
    final studentName =
        widget.productData['studentName']?.toString() ?? 'DIU Student';
    final description =
        widget.productData['description']?.toString() ??
        'No description available.';
    final price = widget.productData['price'] ?? 0;
    final imageUrl = widget.productData['imageUrl']?.toString() ?? '';
    final condition = widget.productData['condition']?.toString() ?? 'Used';
    final category = widget.productData['category']?.toString() ?? 'Others';
    final isAvailable = widget.productData['isAvailable'] == true;

    return Scaffold(
      backgroundColor: campusBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: diuGray),
        ),
        title: const Text(
          'Item Details',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.favorite_border_rounded, color: diuGray),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 280,
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: condition == 'New'
                              ? diuGreen.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          condition,
                          style: TextStyle(
                            color: condition == 'New'
                                ? diuGreen
                                : Colors.orange,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    '৳${price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: diuBlue,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Divider(),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        width: 43,
                        height: 43,
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(.10),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          color: Colors.orange,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              studentName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF111827),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 3),
                            const Text(
                              'DIU Student Seller',
                              style: TextStyle(color: diuGray, fontSize: 10),
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
                      'Price',
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
                    onPressed: isAvailable && !isBuying ? _buyNow : null,
                    icon: isBuying
                        ? const SizedBox(
                            width: 19,
                            height: 19,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.shopping_cart_outlined, size: 19),
                    label: Text(
                      isBuying
                          ? 'Processing...'
                          : isAvailable
                          ? 'Buy Now'
                          : 'Not Available',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
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
