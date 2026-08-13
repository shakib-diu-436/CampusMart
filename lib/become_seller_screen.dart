import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'seller_dashboard.dart';

const Color diuBlue = Color(0xFF034EA2);
const Color diuGreen = Color(0xFF39B54A);
const Color diuGray = Color(0xFF636466);
const Color backgroundColor = Color(0xFFF6F8FB);

class BecomeSellerScreen extends StatefulWidget {
  const BecomeSellerScreen({super.key});

  @override
  State<BecomeSellerScreen> createState() => _BecomeSellerScreenState();
}

class _BecomeSellerScreenState extends State<BecomeSellerScreen> {
  bool isLoading = false;
  bool checkingStore = true;
  bool hasStore = false;

  final storeNameController = TextEditingController();

  final descriptionController = TextEditingController();

  final logoUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    checkExistingStore();
  }

  // ============================================================
  // CHECK EXISTING STORE
  // ============================================================

  Future<void> checkExistingStore() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          checkingStore = false;
        });
      }
      return;
    }

    try {
      // First check users/{uid}
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final userData = userDoc.data();

      final storeId = userData?['storeId'];

      if (storeId != null && storeId.toString().trim().isNotEmpty) {
        if (mounted) {
          setState(() {
            hasStore = true;
            checkingStore = false;
          });
        }
        return;
      }

      // Fallback: check stores collection
      final storeQuery = await FirebaseFirestore.instance
          .collection('stores')
          .where('ownerId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (mounted) {
        setState(() {
          hasStore = storeQuery.docs.isNotEmpty;
          checkingStore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          checkingStore = false;
        });
      }
    }
  }

  @override
  void dispose() {
    storeNameController.dispose();
    descriptionController.dispose();
    logoUrlController.dispose();
    super.dispose();
  }

  // ============================================================
  // CREATE STORE
  // ============================================================

  Future<void> createStore() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showMessage('Please login first.', Colors.red);
      return;
    }

    final storeName = storeNameController.text.trim();

    final description = descriptionController.text.trim();

    final logoUrl = logoUrlController.text.trim();

    // Validation
    if (storeName.isEmpty) {
      showMessage('Please enter your store name.', Colors.orange);
      return;
    }

    if (storeName.length < 3) {
      showMessage('Store name must be at least 3 characters.', Colors.orange);
      return;
    }

    if (description.isEmpty) {
      showMessage('Please enter a short store description.', Colors.orange);
      return;
    }

    if (description.length < 10) {
      showMessage(
        'Store description must be at least 10 characters.',
        Colors.orange,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final firestore = FirebaseFirestore.instance;

      // --------------------------------------------------------
      // CHECK AGAIN BEFORE CREATING
      // --------------------------------------------------------

      final existingStoreQuery = await firestore
          .collection('stores')
          .where('ownerId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (existingStoreQuery.docs.isNotEmpty) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
          hasStore = true;
        });

        showMessage('You already have a store.', Colors.orange);

        return;
      }

      // --------------------------------------------------------
      // CREATE STORE
      // --------------------------------------------------------

      final storeRef = firestore.collection('stores').doc();

      await storeRef.set({
        'storeId': storeRef.id,
        'storeName': storeName,
        'description': description,
        'logoUrl': logoUrl.isEmpty ? '' : logoUrl,
        'ownerId': user.uid,
        'ownerName': user.displayName ?? 'DIU Student',
        'ownerEmail': user.email ?? '',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // --------------------------------------------------------
      // UPDATE USER
      // --------------------------------------------------------

      await firestore.collection('users').doc(user.uid).set({
        'isSeller': true,
        'storeId': storeRef.id,
        'storeName': storeName,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      setState(() {
        isLoading = false;
        hasStore = true;
      });

      showMessage('Store created successfully! 🎉', diuGreen);

      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SellerDashboard()),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showMessage('Could not create your store. Please try again.', Colors.red);
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,

      prefixIcon: Icon(icon, color: diuBlue),

      filled: true,
      fillColor: Colors.white,

      labelStyle: const TextStyle(color: diuGray),

      hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: diuBlue, width: 1.5),
      ),

      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    // ----------------------------------------------------------
    // CHECKING STORE
    // ----------------------------------------------------------

    if (checkingStore) {
      return const Scaffold(
        backgroundColor: backgroundColor,

        body: Center(child: CircularProgressIndicator(color: diuBlue)),
      );
    }

    // ----------------------------------------------------------
    // USER ALREADY HAS STORE
    // ----------------------------------------------------------

    if (hasStore) {
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
            'My Store',
            style: TextStyle(
              color: Color(0xFF111827),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),

              child: Column(
                mainAxisSize: MainAxisSize.min,

                children: [
                  Container(
                    width: 88,
                    height: 88,

                    decoration: BoxDecoration(
                      color: diuBlue.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),

                    child: const Icon(
                      Icons.storefront_rounded,
                      color: diuBlue,
                      size: 48,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'You already have a store',

                    textAlign: TextAlign.center,

                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Manage your store, products and orders from your Seller Dashboard.',

                    textAlign: TextAlign.center,

                    style: TextStyle(color: diuGray, fontSize: 14, height: 1.5),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,

                    height: 55,

                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SellerDashboard(),
                          ),
                        );
                      },

                      icon: const Icon(Icons.dashboard_rounded),

                      label: const Text(
                        'Open Seller Dashboard',

                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: diuBlue,

                        foregroundColor: Colors.white,

                        elevation: 0,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // ----------------------------------------------------------
    // NO STORE → CREATE STORE SCREEN
    // ----------------------------------------------------------

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
          'Create Your Store',

          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // ==================================================
                  // HERO
                  // ==================================================

                  Container(
                    width: double.infinity,

                    padding: const EdgeInsets.all(24),

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
                          width: 75,
                          height: 75,

                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),

                            shape: BoxShape.circle,
                          ),

                          child: const Icon(
                            Icons.storefront_rounded,
                            color: Colors.white,
                            size: 42,
                          ),
                        ),

                        const SizedBox(height: 16),

                        const Text(
                          'Create Your Student Store',

                          textAlign: TextAlign.center,

                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'Create your own brand and showcase your products to the DIU student community.',

                          textAlign: TextAlign.center,

                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ==================================================
                  // STORE INFORMATION
                  // ==================================================
                  const Text(
                    'Store Information',

                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Create a brand identity for your CampusMart store.',

                    style: TextStyle(color: diuGray, fontSize: 13),
                  ),

                  const SizedBox(height: 18),

                  // STORE NAME
                  TextField(
                    controller: storeNameController,

                    textCapitalization: TextCapitalization.words,

                    decoration: inputDecoration(
                      label: 'Store Name *',

                      hint: 'e.g. CampusCraft',

                      icon: Icons.storefront_outlined,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // DESCRIPTION
                  TextField(
                    controller: descriptionController,

                    maxLines: 4,

                    textCapitalization: TextCapitalization.sentences,

                    decoration: inputDecoration(
                      label: 'Store Description *',

                      hint: 'Tell students what your store sells...',

                      icon: Icons.description_outlined,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // LOGO URL
                  TextField(
                    controller: logoUrlController,

                    keyboardType: TextInputType.url,

                    decoration: inputDecoration(
                      label: 'Store Logo URL (Optional)',

                      hint: 'https://example.com/logo.png',

                      icon: Icons.image_outlined,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'You can add a logo image URL now. Logo upload can be added later.',

                    style: TextStyle(color: diuGray, fontSize: 11),
                  ),

                  const SizedBox(height: 25),

                  // ==================================================
                  // STORE BENEFITS
                  // ==================================================
                  Container(
                    width: double.infinity,

                    padding: const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.circular(16),

                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: const [
                        Text(
                          'Your store will include',

                          style: TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 12),

                        StoreFeature(
                          icon: Icons.storefront,
                          text: 'Your own store name and brand identity',
                        ),

                        StoreFeature(
                          icon: Icons.inventory_2_outlined,
                          text: 'All your store products in one place',
                        ),

                        StoreFeature(
                          icon: Icons.people_outline,
                          text: 'Reach DIU student customers',
                        ),

                        StoreFeature(
                          icon: Icons.dashboard_outlined,
                          text: 'Manage your products from Seller Dashboard',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ==================================================
                  // CREATE BUTTON
                  // ==================================================
                  SizedBox(
                    width: double.infinity,

                    height: 55,

                    child: ElevatedButton(
                      onPressed: isLoading ? null : createStore,

                      style: ElevatedButton.styleFrom(
                        backgroundColor: diuGreen,

                        foregroundColor: Colors.white,

                        disabledBackgroundColor: diuGreen.withOpacity(0.5),

                        elevation: 0,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),

                      child: isLoading
                          ? const SizedBox(
                              width: 23,
                              height: 23,

                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,

                              children: [
                                Icon(Icons.add_business_rounded),

                                SizedBox(width: 9),

                                Text(
                                  'Create Store',

                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Center(
                    child: Text(
                      'You can continue using CampusMart as a buyer.',

                      textAlign: TextAlign.center,

                      style: TextStyle(color: diuGray, fontSize: 12),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ================================================================
// STORE FEATURE
// ================================================================

class StoreFeature extends StatelessWidget {
  final IconData icon;
  final String text;

  const StoreFeature({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),

      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,

            decoration: BoxDecoration(
              color: diuBlue.withOpacity(0.08),

              borderRadius: BorderRadius.circular(9),
            ),

            child: Icon(icon, color: diuBlue, size: 19),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              text,

              style: const TextStyle(color: diuGray, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
