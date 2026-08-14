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
  bool isCheckingStore = true;

  final TextEditingController storeNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController logoUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkExistingStore();
  }

  Future<void> _checkExistingStore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        isCheckingStore = false;
      });
      return;
    }

    try {
      final existingStoreQuery = await FirebaseFirestore.instance
          .collection('stores')
          .where('ownerId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (existingStoreQuery.docs.isNotEmpty) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SellerDashboard()),
        );
        return;
      }
    } catch (e) {
      // If error occurs, show the form
    }

    if (mounted) {
      setState(() {
        isCheckingStore = false;
      });
    }
  }

  @override
  void dispose() {
    storeNameController.dispose();
    descriptionController.dispose();
    logoUrlController.dispose();
    super.dispose();
  }

  Future<void> createStore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      showMessage('Please login first.', Colors.red);
      return;
    }

    final storeName = storeNameController.text.trim();
    final description = descriptionController.text.trim();
    final logoUrl = logoUrlController.text.trim();

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

      // Double-check to avoid race condition
      final existingStoreQuery = await firestore
          .collection('stores')
          .where('ownerId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (existingStoreQuery.docs.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          isLoading = false;
        });
        showMessage('You already have a store.', Colors.orange);
        await Future.delayed(const Duration(milliseconds: 700));
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SellerDashboard()),
        );
        return;
      }

      final storeRef = firestore.collection('stores').doc();
      final ownerName = user.displayName?.trim().isNotEmpty == true
          ? user.displayName!.trim()
          : 'DIU Student';
      final ownerEmail = user.email ?? '';
      final ownerPhotoUrl = user.photoURL ?? '';

      await storeRef.set({
        'storeId': storeRef.id,
        'storeName': storeName,
        'description': description,
        'logoUrl': logoUrl,
        'ownerId': user.uid,
        'ownerName': ownerName,
        'ownerEmail': ownerEmail,
        'ownerPhotoUrl': ownerPhotoUrl,
        'followerCount': 0,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await firestore.collection('users').doc(user.uid).set({
        'isSeller': true,
        'storeId': storeRef.id,
        'storeName': storeName,
        'photoURL': ownerPhotoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      showMessage('Store created successfully! 🎉', diuGreen);
      await Future.delayed(const Duration(milliseconds: 900));
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
      debugPrint('Create Store Error: $e');
    }
  }

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

  @override
  Widget build(BuildContext context) {
    if (isCheckingStore) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: const Center(child: CircularProgressIndicator(color: diuBlue)),
      );
    }

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
                    'Add a direct image URL for your store logo. If empty, your profile picture will be used automatically.',
                    style: TextStyle(color: diuGray, fontSize: 11),
                  ),
                  const SizedBox(height: 25),
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
                        _StoreFeature(
                          icon: Icons.storefront,
                          text: 'Your own store name and brand identity',
                        ),
                        _StoreFeature(
                          icon: Icons.inventory_2_outlined,
                          text: 'All your store products in one place',
                        ),
                        _StoreFeature(
                          icon: Icons.people_outline,
                          text: 'Students can follow your store',
                        ),
                        _StoreFeature(
                          icon: Icons.dashboard_outlined,
                          text: 'Manage your products from Seller Dashboard',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
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

class _StoreFeature extends StatelessWidget {
  final IconData icon;
  final String text;
  const _StoreFeature({required this.icon, required this.text});

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
