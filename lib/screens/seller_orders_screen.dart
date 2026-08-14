import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart'; // <-- IMPORTANT

const Color diuBlue = Color(0xFF034EA2);
const Color diuGreen = Color(0xFF39B54A);
const Color diuGray = Color(0xFF636466);
const Color campusBg = Color(0xFFF6F8FB);
const Color lightGreen = Color(0xFFEAF7ED);

class SellerOrdersScreen extends StatefulWidget {
  const SellerOrdersScreen({super.key});

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen> {
  User? get currentUser => FirebaseAuth.instance.currentUser;

  // Combined orders: store orders (sellerIds) + student orders (sellerId)
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  getCombinedOrders() {
    final user = currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    // Stream for store orders (with sellerIds array)
    final storeOrders = FirebaseFirestore.instance
        .collection('orders')
        .where('sellerIds', arrayContains: user.uid)
        .snapshots();

    // Stream for student orders (with sellerId field)
    final studentOrders = FirebaseFirestore.instance
        .collection('orders')
        .where('sellerId', isEqualTo: user.uid)
        .snapshots();

    // Combine both streams
    return Rx.combineLatest2<
      QuerySnapshot<Map<String, dynamic>>,
      QuerySnapshot<Map<String, dynamic>>,
      List<QueryDocumentSnapshot<Map<String, dynamic>>>
    >(storeOrders, studentOrders, (storeSnapshot, studentSnapshot) {
      final allDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
      allDocs.addAll(storeSnapshot.docs);
      allDocs.addAll(studentSnapshot.docs);
      // Remove duplicates (by document ID)
      final seen = <String>{};
      return allDocs.where((doc) => seen.add(doc.id)).toList();
    });
  }

  double getPrice(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  String formatDate(dynamic value) {
    if (value is Timestamp) {
      final date = value.toDate();
      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    }
    return 'Unknown date';
  }

  String getSellerStatus(Map<String, dynamic> order, String sellerId) {
    final statuses = order['sellerStatuses'];
    if (statuses is Map) {
      return statuses[sellerId]?.toString().toLowerCase() ?? 'pending';
    }
    return 'pending';
  }

  Future<void> updateSellerStatus(String orderId, String newStatus) async {
    final user = currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update(
        {
          'sellerStatuses.${user.uid}': newStatus,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order status updated to ${newStatus.toUpperCase()}.'),
          backgroundColor: diuGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not update order status: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String? nextStatus(String status) {
    switch (status) {
      case 'pending':
        return 'confirmed';
      case 'confirmed':
        return 'processing';
      case 'processing':
        return 'shipped';
      case 'shipped':
        return 'delivered';
      case 'delivered':
        return null;
      default:
        return 'confirmed';
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.blue;
      case 'processing':
        return Colors.orange;
      case 'shipped':
        return Colors.deepPurple;
      case 'delivered':
        return diuGreen;
      default:
        return Colors.orange;
    }
  }

  String statusLabel(String status) {
    switch (status) {
      case 'confirmed':
        return 'CONFIRMED';
      case 'processing':
        return 'PROCESSING';
      case 'shipped':
        return 'SHIPPED';
      case 'delivered':
        return 'DELIVERED';
      default:
        return 'PENDING';
    }
  }

  List<Map<String, dynamic>> getSellerItems(
    Map<String, dynamic> order,
    String sellerId,
  ) {
    final rawItems = order['items'];
    if (rawItems is! List) return [];
    return rawItems
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .where((item) {
          // For store orders, items have sellerId; for student orders, single sellerId
          return item['sellerId']?.toString() == sellerId;
        })
        .toList();
  }

  double getSellerTotal(List<Map<String, dynamic>> items) {
    double total = 0;
    for (final item in items) {
      final price = getPrice(item['price']);
      final quantityValue = item['quantity'] ?? 1;
      final quantity = quantityValue is num
          ? quantityValue.toInt()
          : int.tryParse(quantityValue.toString()) ?? 1;
      total += price * quantity;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final user = currentUser;
    if (user == null) {
      return Scaffold(
        backgroundColor: campusBg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Seller Orders',
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: const Center(child: Text('Please login first.')),
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
          'Seller Orders',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
        stream: getCombinedOrders(),
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
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.red,
                      size: 50,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Could not load seller orders',
                      style: TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 7),
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

          final docs = snapshot.data ?? [];
          if (docs.isEmpty) {
            return _buildEmpty();
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
            itemCount: docs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final order = doc.data();
              final sellerItems = getSellerItems(order, user.uid);
              if (sellerItems.isEmpty) return const SizedBox.shrink();
              return _buildOrderCard(
                context,
                doc.id,
                order,
                sellerItems,
                user.uid,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    String orderId,
    Map<String, dynamic> order,
    List<Map<String, dynamic>> items,
    String sellerId,
  ) {
    final status = getSellerStatus(order, sellerId);
    final total = getSellerTotal(items);
    final customerName =
        order['customerName']?.toString() ??
        order['buyerName']?.toString() ??
        'Customer';
    final phone = order['phone']?.toString() ?? '';
    final address = order['address']?.toString() ?? '';
    final createdAt = formatDate(order['createdAt']);
    final next = nextStatus(status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${orderId.substring(0, orderId.length > 8 ? 8 : orderId.length).toUpperCase()}',
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      createdAt,
                      style: const TextStyle(color: diuGray, fontSize: 10),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor(status).withOpacity(.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel(status),
                  style: TextStyle(
                    color: statusColor(status),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: campusBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _infoRow(
                  Icons.person_outline_rounded,
                  'Customer',
                  customerName,
                ),
                if (phone.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: _infoRow(Icons.phone_outlined, 'Phone', phone),
                  ),
                if (address.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: _infoRow(
                      Icons.location_on_outlined,
                      'Address',
                      address,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Your Products',
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map((item) => _buildProductItem(item)),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your Total',
                style: TextStyle(color: diuGray, fontSize: 13),
              ),
              Text(
                '৳${total.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: diuBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (next != null)
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () {
                  updateSellerStatus(orderId, next);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: diuBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
                child: Text(
                  _nextButtonText(next),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: lightGreen,
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Text(
                'Order Completed ✓',
                style: TextStyle(
                  color: diuGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductItem(Map<String, dynamic> item) {
    final name = item['name']?.toString() ?? 'Product';
    final price = getPrice(item['price']);
    final quantityValue = item['quantity'] ?? 1;
    final quantity = quantityValue is num
        ? quantityValue.toInt()
        : int.tryParse(quantityValue.toString()) ?? 1;
    final imageUrl = item['imageUrl']?.toString() ?? '';
    final total = price * quantity;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: Container(
              width: 55,
              height: 55,
              color: const Color(0xFFEFF2F5),
              child: imageUrl.isEmpty
                  ? const Icon(Icons.image_outlined, color: diuGray)
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.broken_image_outlined,
                          color: diuGray,
                        );
                      },
                    ),
            ),
          ),
          const SizedBox(width: 11),
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
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '৳${price.toStringAsFixed(0)} × $quantity',
                  style: const TextStyle(color: diuGray, fontSize: 10),
                ),
              ],
            ),
          ),
          Text(
            '৳${total.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: diuBlue, size: 17),
        const SizedBox(width: 8),
        Text(
          '$title: ',
          style: const TextStyle(
            color: diuGray,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  String _nextButtonText(String status) {
    switch (status) {
      case 'confirmed':
        return 'Confirm Order';
      case 'processing':
        return 'Start Processing';
      case 'shipped':
        return 'Mark as Shipped';
      case 'delivered':
        return 'Mark as Delivered';
      default:
        return 'Update Order';
    }
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 95,
              height: 95,
              decoration: BoxDecoration(
                color: diuGreen.withOpacity(.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                color: diuGreen,
                size: 45,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No Seller Orders',
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Orders containing your products\nwill appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: diuGray, fontSize: 12, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
