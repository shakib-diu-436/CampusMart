import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

const Color diuBlue = Color(0xFF034EA2);
const Color diuGreen = Color(0xFF39B54A);
const Color diuGray = Color(0xFF636466);
const Color backgroundColor = Color(0xFFF6F8FB);

class EditStoreScreen extends StatefulWidget {
  final String storeId;
  const EditStoreScreen({super.key, required this.storeId});

  @override
  State<EditStoreScreen> createState() => _EditStoreScreenState();
}

class _EditStoreScreenState extends State<EditStoreScreen> {
  final TextEditingController storeNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController logoUrlController = TextEditingController();

  bool isLoading = true;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadStoreData();
  }

  Future<void> _loadStoreData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('stores')
          .doc(widget.storeId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        storeNameController.text = data['storeName']?.toString() ?? '';
        descriptionController.text = data['description']?.toString() ?? '';
        logoUrlController.text = data['logoUrl']?.toString() ?? '';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading store: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> updateStore() async {
    final storeName = storeNameController.text.trim();
    final description = descriptionController.text.trim();
    final logoUrl = logoUrlController.text.trim();

    if (storeName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a store name.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a store description.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => isUpdating = true);

    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('stores').doc(widget.storeId).update({
        'storeName': storeName,
        'description': description,
        'logoUrl': logoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await firestore.collection('users').doc(user.uid).set({
          'storeName': storeName,
          'storeId': widget.storeId,
        }, SetOptions(merge: true));
      }

      if (!mounted) return;
      setState(() => isUpdating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Store updated successfully! ✅'),
          backgroundColor: diuGreen,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => isUpdating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not update store: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    storeNameController.dispose();
    descriptionController.dispose();
    logoUrlController.dispose();
    super.dispose();
  }

  InputDecoration inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: diuGray),
      filled: true,
      fillColor: Colors.white,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: diuGray),
        ),
        title: const Text(
          'Edit Store',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: diuBlue))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        const Text(
                          'Update your store details',
                          style: TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Your store name and description will be visible to customers.',
                          style: TextStyle(color: diuGray, fontSize: 13),
                        ),
                        const SizedBox(height: 25),
                        // Store Name
                        TextField(
                          controller: storeNameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: inputDecoration(
                            label: 'Store Name *',
                            hint: 'e.g. CampusCraft',
                            icon: Icons.storefront_outlined,
                          ),
                        ),
                        const SizedBox(height: 18),
                        // Description
                        TextField(
                          controller: descriptionController,
                          maxLines: 4,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: inputDecoration(
                            label: 'Store Description *',
                            hint: 'Tell customers what your store sells...',
                            icon: Icons.description_outlined,
                          ),
                        ),
                        const SizedBox(height: 18),
                        // Logo URL
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
                          'Add a direct image URL for your store logo. If empty, your profile picture will be used.',
                          style: TextStyle(color: diuGray, fontSize: 11),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: isUpdating ? null : updateStore,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: diuBlue,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: diuBlue.withOpacity(0.5),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: isUpdating
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
                                      Icon(Icons.save_rounded),
                                      SizedBox(width: 9),
                                      Text(
                                        'Update Store',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
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
