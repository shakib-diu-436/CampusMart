import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

const Color diuBlue = Color(0xFF034EA2);
const Color diuGreen = Color(0xFF39B54A);
const Color diuGray = Color(0xFF636466);
const Color campusBg = Color(0xFFF6F8FB);

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  // ============================================================
  // ORDER STATUS COLOR
  // ============================================================

  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return diuBlue;

      case 'processing':
        return Colors.orange;

      case 'delivered':
        return diuGreen;

      case 'cancelled':
        return Colors.red;

      case 'pending':
      default:
        return Colors.grey;
    }
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) {
      return 'Date unavailable';
    }

    final date = timestamp.toDate();

    final day = date.day.toString().padLeft(2, '0');

    final month = date.month.toString().padLeft(2, '0');

    final year = date.year.toString();

    final hour = date.hour.toString().padLeft(2, '0');

    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year • $hour:$minute';
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

          title: const Text(
            'My Orders',
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        body: const Center(
          child: Text('Please login first.', style: TextStyle(color: diuGray)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: campusBg,

      // ==========================================================
      // APP BAR
      // ==========================================================
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
          'My Orders',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ==========================================================
      // ORDERS
      // ==========================================================
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          // ========================================================
          // ERROR
          // ========================================================

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),

                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.red,
                      size: 45,
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'Could not load orders.',
                      style: TextStyle(
                        color: Color(0xFF111827),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,

                      style: const TextStyle(color: diuGray, fontSize: 10),
                    ),
                  ],
                ),
              ),
            );
          }

          // ========================================================
          // LOADING
          // ========================================================

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: diuBlue),
            );
          }

          final orders = snapshot.data?.docs ?? [];

          // ========================================================
          // EMPTY
          // ========================================================

          if (orders.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(30),

                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    Container(
                      width: 85,
                      height: 85,

                      decoration: BoxDecoration(
                        color: diuBlue.withOpacity(.08),

                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        color: diuBlue,
                        size: 42,
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'No Orders Yet',
                      style: TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 7),

                    const Text(
                      'Your purchased products will appear here.',
                      textAlign: TextAlign.center,

                      style: TextStyle(
                        color: diuGray,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // ========================================================
          // ORDER LIST
          // ========================================================

          return RefreshIndicator(
            color: diuBlue,

            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 500));
            },

            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),

              itemCount: orders.length,

              separatorBuilder: (_, __) => const SizedBox(height: 12),

              itemBuilder: (context, index) {
                final order = orders[index];

                final data = order.data();

                return _OrderCard(
                  orderId: order.id,

                  data: data,

                  statusColor: statusColor(
                    data['orderStatus']?.toString() ?? 'pending',
                  ),

                  date: formatDate(data['createdAt'] as Timestamp?),

                  onTap: () {
                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (_) =>
                            OrderDetailsScreen(orderId: order.id, data: data),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ==================================================================
// ORDER CARD
// ==================================================================

class _OrderCard extends StatelessWidget {
  final String orderId;
  final Map<String, dynamic> data;
  final Color statusColor;
  final String date;
  final VoidCallback onTap;

  const _OrderCard({
    required this.orderId,
    required this.data,
    required this.statusColor,
    required this.date,
    required this.onTap,
  });

  double get total {
    final value = data['total'];

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String get status {
    return data['orderStatus']?.toString() ?? 'pending';
  }

  String get paymentStatus {
    return data['paymentStatus']?.toString() ?? 'pending';
  }

  int get itemCount {
    final items = data['items'];

    if (items is List) {
      int count = 0;

      for (final item in items) {
        if (item is Map) {
          final quantity = item['quantity'];

          if (quantity is num) {
            count += quantity.toInt();
          } else {
            count += int.tryParse(quantity?.toString() ?? '1') ?? 1;
          }
        }
      }

      return count;
    }

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,

      borderRadius: BorderRadius.circular(17),

      child: Container(
        width: double.infinity,

        padding: const EdgeInsets.all(15),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(17),

          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),

        child: Column(
          children: [
            // ======================================================
            // TOP ROW
            // ======================================================

            Row(
              children: [
                Container(
                  width: 45,

                  height: 45,

                  decoration: BoxDecoration(
                    color: diuBlue.withOpacity(.08),

                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: const Icon(
                    Icons.receipt_long_outlined,
                    color: diuBlue,
                    size: 23,
                  ),
                ),

                const SizedBox(width: 11),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Text(
                        'Order',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 10,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        '#${orderId.length > 10 ? orderId.substring(0, 10) : orderId}',

                        style: const TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),

                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(.09),

                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Text(
                    status.toUpperCase(),

                    style: TextStyle(
                      color: statusColor,

                      fontSize: 9,

                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            const Divider(height: 1),

            const SizedBox(height: 12),

            // ======================================================
            // ORDER INFO
            // ======================================================
            Row(
              children: [
                Expanded(
                  child: _infoItem(
                    Icons.inventory_2_outlined,

                    '$itemCount item${itemCount == 1 ? '' : 's'}',
                  ),
                ),

                Expanded(child: _infoItem(Icons.calendar_today_outlined, date)),
              ],
            ),

            const SizedBox(height: 12),

            // ======================================================
            // BOTTOM
            // ======================================================
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(color: diuGray, fontSize: 10),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        '৳${total.toStringAsFixed(0)}',

                        style: const TextStyle(
                          color: diuBlue,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),

                  decoration: BoxDecoration(
                    color: paymentStatus == 'paid'
                        ? diuGreen.withOpacity(.08)
                        : Colors.orange.withOpacity(.08),

                    borderRadius: BorderRadius.circular(7),
                  ),

                  child: Text(
                    paymentStatus == 'paid' ? 'PAID' : 'PAYMENT PENDING',

                    style: TextStyle(
                      color: paymentStatus == 'paid' ? diuGreen : Colors.orange,

                      fontSize: 8,

                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFF9CA3AF),
                  size: 14,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF8BA3C1), size: 15),

        const SizedBox(width: 6),

        Expanded(
          child: Text(
            text,

            maxLines: 1,

            overflow: TextOverflow.ellipsis,

            style: const TextStyle(color: diuGray, fontSize: 9),
          ),
        ),
      ],
    );
  }
}

// ==================================================================
// ORDER DETAILS SCREEN
// ==================================================================

class OrderDetailsScreen extends StatelessWidget {
  final String orderId;
  final Map<String, dynamic> data;

  const OrderDetailsScreen({
    super.key,
    required this.orderId,
    required this.data,
  });

  double get total {
    final value = data['total'];

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  double get subtotal {
    final value = data['subtotal'];

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  double get deliveryFee {
    final value = data['deliveryFee'];

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String get orderStatus {
    return data['orderStatus']?.toString() ?? 'pending';
  }

  String get paymentStatus {
    return data['paymentStatus']?.toString() ?? 'pending';
  }

  Color get statusColor {
    switch (orderStatus.toLowerCase()) {
      case 'confirmed':
        return diuBlue;

      case 'processing':
        return Colors.orange;

      case 'delivered':
        return diuGreen;

      case 'cancelled':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  String formatDate(dynamic value) {
    if (value is! Timestamp) {
      return 'Date unavailable';
    }

    final date = value.toDate();

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final items = data['items'] is List
        ? List.from(data['items'])
        : <dynamic>[];

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
          'Order Details',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ======================================================
            // ORDER HEADER
            // ======================================================

            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(16),

                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),

              child: Row(
                children: [
                  Container(
                    width: 48,

                    height: 48,

                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(.09),

                      borderRadius: BorderRadius.circular(13),
                    ),

                    child: Icon(
                      Icons.local_shipping_outlined,
                      color: statusColor,
                      size: 25,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        const Text(
                          'Order ID',
                          style: TextStyle(color: diuGray, fontSize: 10),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          '#$orderId',

                          maxLines: 1,

                          overflow: TextOverflow.ellipsis,

                          style: const TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),

                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(.09),

                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Text(
                      orderStatus.toUpperCase(),

                      style: TextStyle(
                        color: statusColor,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ======================================================
            // ITEMS
            // ======================================================
            const Text(
              'Products',
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 9),

            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(14),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(16),

                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),

              child: Column(
                children: items.map((item) {
                  final map = Map<String, dynamic>.from(item);

                  final name = map['name']?.toString() ?? 'Product';

                  final priceValue = map['price'];

                  final price = priceValue is num
                      ? priceValue.toDouble()
                      : double.tryParse(priceValue?.toString() ?? '') ?? 0;

                  final quantityValue = map['quantity'] ?? 1;

                  final quantity = quantityValue is num
                      ? quantityValue.toInt()
                      : int.tryParse(quantityValue.toString()) ?? 1;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),

                    child: Row(
                      children: [
                        Container(
                          width: 46,

                          height: 46,

                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),

                            borderRadius: BorderRadius.circular(10),
                          ),

                          child: const Icon(
                            Icons.shopping_bag_outlined,
                            color: diuBlue,
                            size: 22,
                          ),
                        ),

                        const SizedBox(width: 11),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text(
                                name,

                                maxLines: 1,

                                overflow: TextOverflow.ellipsis,

                                style: const TextStyle(
                                  color: Color(0xFF111827),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 3),

                              Text(
                                '৳${price.toStringAsFixed(0)} × $quantity',

                                style: const TextStyle(
                                  color: diuGray,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Text(
                          '৳${(price * quantity).toStringAsFixed(0)}',

                          style: const TextStyle(
                            color: diuBlue,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // ======================================================
            // DELIVERY
            // ======================================================
            const Text(
              'Delivery Information',
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 9),

            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(14),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(16),

                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  _detailRow('Name', data['customerName']?.toString() ?? ''),

                  _detailRow('Phone', data['phone']?.toString() ?? ''),

                  _detailRow('Address', data['address']?.toString() ?? ''),

                  if ((data['note']?.toString() ?? '').isNotEmpty)
                    _detailRow('Note', data['note']?.toString() ?? ''),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ======================================================
            // PAYMENT
            // ======================================================
            const Text(
              'Payment',
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 9),

            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(14),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(16),

                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),

              child: Row(
                children: [
                  Container(
                    width: 44,

                    height: 44,

                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE9F0),

                      borderRadius: BorderRadius.circular(11),
                    ),

                    child: const Icon(
                      Icons.payment_outlined,
                      color: Color(0xFFE2136E),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          data['paymentMethod']?.toString().toUpperCase() ??
                              'BKASH',

                          style: const TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          paymentStatus == 'paid'
                              ? 'Payment completed'
                              : 'Payment pending',

                          style: TextStyle(
                            color: paymentStatus == 'paid'
                                ? diuGreen
                                : Colors.orange,

                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ======================================================
            // TOTAL
            // ======================================================
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(16),

                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),

              child: Column(
                children: [
                  _priceRow('Subtotal', subtotal),

                  const SizedBox(height: 8),

                  _priceRow('Delivery Fee', deliveryFee),

                  const Divider(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        '৳${total.toStringAsFixed(0)}',

                        style: const TextStyle(
                          color: diuBlue,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Align(
                    alignment: Alignment.centerLeft,

                    child: Text(
                      'Order placed on ${formatDate(data['createdAt'])}',

                      style: const TextStyle(color: diuGray, fontSize: 9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          SizedBox(
            width: 65,

            child: Text(
              title,

              style: const TextStyle(color: diuGray, fontSize: 10),
            ),
          ),

          Expanded(
            child: Text(
              value,

              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String title, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [
        Text(title, style: const TextStyle(color: diuGray, fontSize: 12)),

        Text(
          '৳${value.toStringAsFixed(0)}',

          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
