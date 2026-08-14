import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

const Color diuBlue = Color(0xFF034EA2);
const Color diuGreen = Color(0xFF39B54A);
const Color diuGray = Color(0xFF636466);
const Color campusBg = Color(0xFFF6F8FB);

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double subtotal;
  final double deliveryFee;
  final double total;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController nameController = TextEditingController();

  final TextEditingController phoneController = TextEditingController();

  final TextEditingController addressController = TextEditingController();

  final TextEditingController noteController = TextEditingController();

  bool isPlacingOrder = false;
  bool isLoadingProfile = true;

  String selectedPayment = 'bkash';

  @override
  void initState() {
    super.initState();
    _loadSavedProfileInfo();
  }

  Future<void> _loadSavedProfileInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => isLoadingProfile = false);
      return;
    }

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data() ?? {};
      final savedName = data['name']?.toString() ?? user.displayName ?? '';
      final savedPhone = data['phone']?.toString() ?? '';
      final savedAddress =
          data['defaultAddress']?.toString() ??
          data['address']?.toString() ??
          '';

      if (!mounted) return;
      setState(() {
        nameController.text = savedName;
        phoneController.text = savedPhone;
        addressController.text = savedAddress;
        isLoadingProfile = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoadingProfile = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    noteController.dispose();

    super.dispose();
  }

  // ============================================================
  // PRICE
  // ============================================================

  double getPrice(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }

  // ============================================================
  // CREATE ORDER
  // ============================================================

  Future<void> placeOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage('Please login first.', Colors.red);
      return;
    }

    if (widget.cartItems.isEmpty) {
      _showMessage('Your cart is empty.', Colors.red);
      return;
    }

    setState(() {
      isPlacingOrder = true;
    });

    try {
      // ==========================================================
      // CREATE SELLER IDS
      // ==========================================================

      final sellerIds = widget.cartItems
          .map((item) => item['sellerId']?.toString())
          .where((id) => id != null && id.isNotEmpty)
          .toSet()
          .toList();

      // ==========================================================
      // CREATE SELLER STATUS MAP
      // ==========================================================

      final Map<String, String> sellerStatuses = {
        for (final sellerId in sellerIds) ?sellerId: 'pending',
      };

      // ==========================================================
      // CREATE ORDER DATA
      // ==========================================================

      final orderData = {
        // ========================================================
        // BUYER
        // ========================================================

        'userId': user.uid,

        'customerName': nameController.text.trim(),

        'phone': phoneController.text.trim(),

        'address': addressController.text.trim(),

        'note': noteController.text.trim(),

        // ========================================================
        // PRODUCTS
        // ========================================================
        'items': widget.cartItems,

        // ========================================================
        // SELLERS
        // ========================================================
        'sellerIds': sellerIds,

        // Each seller gets an independent status.
        //
        // Example:
        //
        // sellerStatuses: {
        //   "sellerA": "pending",
        //   "sellerB": "pending",
        // }
        'sellerStatuses': sellerStatuses,

        // ========================================================
        // PRICE
        // ========================================================
        'subtotal': widget.subtotal,

        'deliveryFee': widget.deliveryFee,

        'total': widget.total,

        // ========================================================
        // PAYMENT
        // ========================================================
        'paymentMethod': selectedPayment,

        // Payment gateway will be
        // connected later.
        'paymentStatus': 'pending',

        // ========================================================
        // ORDER STATUS
        // ========================================================
        'orderStatus': 'pending',

        // ========================================================
        // TIMESTAMPS
        // ========================================================
        'createdAt': FieldValue.serverTimestamp(),

        'updatedAt': FieldValue.serverTimestamp(),
      };

      // ==========================================================
      // SAVE ORDER
      // ==========================================================

      final orderRef = await FirebaseFirestore.instance
          .collection('orders')
          .add(orderData);

      // ==========================================================
      // CLEAR CART
      // ==========================================================

      final cartRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart');

      final cartSnapshot = await cartRef.get();

      final batch = FirebaseFirestore.instance.batch();

      for (final doc in cartSnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      if (!mounted) return;

      setState(() {
        isPlacingOrder = false;
      });

      // ==========================================================
      // SUCCESS
      // ==========================================================

      await showDialog(
        context: context,
        barrierDismissible: false,

        builder: (context) {
          return AlertDialog(
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
                  'Your order has been successfully created.',

                  textAlign: TextAlign.center,

                  style: TextStyle(color: diuGray, fontSize: 12, height: 1.5),
                ),

                const SizedBox(height: 10),

                Text(
                  'Order ID: ${orderRef.id}',

                  textAlign: TextAlign.center,

                  style: const TextStyle(
                    color: diuBlue,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },

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
          );
        },
      );

      if (!mounted) return;

      // Go back to Cart/Home
      // after order.

      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isPlacingOrder = false;
      });

      _showMessage('Could not place order: $e', Colors.red);
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),

          backgroundColor: color,

          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
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
          'Checkout',

          style: TextStyle(
            color: Color(0xFF111827),

            fontSize: 18,

            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ==========================================================
      // BODY
      // ==========================================================
      body: isLoadingProfile
          ? const Center(child: CircularProgressIndicator(color: diuBlue))
          : Form(
              key: _formKey,

              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // ====================================================
                    // DELIVERY INFORMATION
                    // ====================================================

                    _sectionTitle(
                      'Delivery Information',
                      Icons.location_on_outlined,
                    ),

                    const SizedBox(height: 12),

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
                          _textField(
                            controller: nameController,

                            label: 'Full Name',

                            hint: 'Enter your full name',

                            icon: Icons.person_outline_rounded,

                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your name';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 14),

                          _textField(
                            controller: phoneController,

                            label: 'Phone Number',

                            hint: '01XXXXXXXXX',

                            icon: Icons.phone_outlined,

                            keyboardType: TextInputType.phone,

                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your phone number';
                              }

                              if (value.trim().length < 11) {
                                return 'Enter a valid phone number';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 14),

                          _textField(
                            controller: addressController,

                            label: 'Delivery Address',

                            hint: 'Enter your delivery location',

                            icon: Icons.location_on_outlined,

                            maxLines: 3,

                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your delivery address';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 14),

                          _textField(
                            controller: noteController,

                            label: 'Additional Note (Optional)',

                            hint: 'Any special instruction?',

                            icon: Icons.notes_outlined,

                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ====================================================
                    // PAYMENT
                    // ====================================================
                    _sectionTitle('Payment Method', Icons.payment_outlined),

                    const SizedBox(height: 12),

                    Container(
                      width: double.infinity,

                      padding: const EdgeInsets.all(14),

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius: BorderRadius.circular(16),

                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),

                      child: InkWell(
                        onTap: () {
                          setState(() {
                            selectedPayment = 'bkash';
                          });
                        },

                        borderRadius: BorderRadius.circular(12),

                        child: Container(
                          padding: const EdgeInsets.all(12),

                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE9F0),

                            borderRadius: BorderRadius.circular(12),

                            border: Border.all(
                              color: const Color(0xFFE2136E),

                              width: 1.5,
                            ),
                          ),

                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,

                                decoration: BoxDecoration(
                                  color: const Color(0xFFE2136E),

                                  borderRadius: BorderRadius.circular(12),
                                ),

                                child: const Center(
                                  child: Text(
                                    'bKash',

                                    style: TextStyle(
                                      color: Colors.white,

                                      fontSize: 12,

                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Text(
                                      'bKash',

                                      style: TextStyle(
                                        color: Color(0xFF111827),

                                        fontSize: 14,

                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    SizedBox(height: 4),

                                    Text(
                                      'Payment gateway will be connected later',

                                      style: TextStyle(
                                        color: diuGray,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const Icon(
                                Icons.check_circle_rounded,

                                color: Color(0xFFE2136E),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ====================================================
                    // ORDER SUMMARY
                    // ====================================================
                    _sectionTitle('Order Summary', Icons.receipt_long_outlined),

                    const SizedBox(height: 12),

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
                          ...widget.cartItems.map((item) {
                            final name = item['name']?.toString() ?? 'Product';

                            final price = getPrice(item['price']);

                            final quantityValue = item['quantity'] ?? 1;

                            final quantity = quantityValue is num
                                ? quantityValue.toInt()
                                : int.tryParse(quantityValue.toString()) ?? 1;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),

                              child: Row(
                                children: [
                                  Container(
                                    width: 42,

                                    height: 42,

                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),

                                      borderRadius: BorderRadius.circular(9),
                                    ),

                                    child: const Icon(
                                      Icons.shopping_bag_outlined,

                                      color: diuBlue,

                                      size: 20,
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,

                                      children: [
                                        Text(
                                          name,

                                          maxLines: 1,

                                          overflow: TextOverflow.ellipsis,

                                          style: const TextStyle(
                                            color: Color(0xFF111827),

                                            fontSize: 12,

                                            fontWeight: FontWeight.w600,
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
                                      color: Color(0xFF111827),

                                      fontSize: 12,

                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),

                          const Divider(height: 18),

                          _summaryRow(
                            'Subtotal',
                            '৳${widget.subtotal.toStringAsFixed(0)}',
                          ),

                          const SizedBox(height: 8),

                          _summaryRow(
                            'Delivery Fee',
                            '৳${widget.deliveryFee.toStringAsFixed(0)}',
                          ),

                          const Divider(height: 24),

                          _summaryRow(
                            'Total',
                            '৳${widget.total.toStringAsFixed(0)}',
                            bold: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

      // ============================================================
      // PLACE ORDER BUTTON
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

          child: SizedBox(
            width: double.infinity,

            height: 52,

            child: ElevatedButton.icon(
              onPressed: isPlacingOrder ? null : placeOrder,

              icon: isPlacingOrder
                  ? const SizedBox(
                      width: 19,
                      height: 19,

                      child: CircularProgressIndicator(
                        color: Colors.white,

                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.check_circle_outline_rounded, size: 20),

              label: Text(
                isPlacingOrder
                    ? 'Creating Order...'
                    : 'Place Order • ৳${widget.total.toStringAsFixed(0)}',

                style: const TextStyle(
                  fontSize: 13,

                  fontWeight: FontWeight.bold,
                ),
              ),

              style: ElevatedButton.styleFrom(
                backgroundColor: diuGreen,

                disabledBackgroundColor: Colors.grey,

                foregroundColor: Colors.white,

                elevation: 0,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // SECTION TITLE
  // ==============================================================

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: diuBlue, size: 20),

        const SizedBox(width: 8),

        Text(
          title,

          style: const TextStyle(
            color: Color(0xFF111827),

            fontSize: 16,

            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ==============================================================
  // TEXT FIELD
  // ==============================================================

  Widget _textField({
    required TextEditingController controller,

    required String label,

    required String hint,

    required IconData icon,

    String? Function(String?)? validator,

    TextInputType? keyboardType,

    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          label,

          style: const TextStyle(
            color: Color(0xFF374151),

            fontSize: 11,

            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 6),

        TextFormField(
          controller: controller,

          validator: validator,

          keyboardType: keyboardType,

          maxLines: maxLines,

          style: const TextStyle(color: Color(0xFF111827), fontSize: 13),

          decoration: InputDecoration(
            hintText: hint,

            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),

            prefixIcon: Icon(icon, color: const Color(0xFF8BA3C1), size: 20),

            filled: true,

            fillColor: const Color(0xFFF9FAFB),

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,

              vertical: 14,
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),

              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),

              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),

              borderSide: const BorderSide(color: diuBlue, width: 1.3),
            ),

            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),

              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  // ==============================================================
  // SUMMARY ROW
  // ==============================================================

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
}
