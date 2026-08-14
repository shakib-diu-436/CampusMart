import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'become_seller_screen.dart';

const Color diuBlue = Color(0xFF034EA2);
const Color diuGreen = Color(0xFF39B54A);
const Color diuGray = Color(0xFF636466);
const Color backgroundColor = Color(0xFFF6F8FB);

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();
  final descriptionController = TextEditingController();
  final imageUrlController = TextEditingController();

  String selectedCategory = 'Plants';
  bool isPublishing = false;

  final List<String> categories = [
    'Plants',
    'Books',
    'Tech',
    'Phones',
    'Computers',
    'Laptops',
    'Tablets',
    'Accessories',
    'Electronics',
    'Gaming',
    'Clothing',
    'Fashion',
    'Shoes',
    'Bags',
    'Crafts',
    'Stationery',
    'Beauty',
    'Food',
    'Home & Living',
    'Sports',
    'Services',
    'Others',
  ];

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    stockController.dispose();
    descriptionController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }

  String convertImageUrl(String url) {
    url = url.trim();
    final driveRegex = RegExp(r'drive\.google\.com\/file\/d\/([^\/]+)');
    final match = driveRegex.firstMatch(url);
    if (match != null) {
      final fileId = match.group(1);
      return 'https://drive.google.com/uc?export=view&id=$fileId';
    }
    return url;
  }

  Future<void> publishProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      showMessage('Please login first.', Colors.red);
      return;
    }

    // ===== CHECK IF USER HAS A STORE =====
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final userData = userDoc.data();
    final storeId = userData?['storeId']?.toString();

    if (storeId == null || storeId.trim().isEmpty) {
      showMessage(
        'You need a store to sell products. Please create a store first.',
        Colors.orange,
      );
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const BecomeSellerScreen()),
      );
      return;
    }

    setState(() {
      isPublishing = true;
    });

    try {
      final imageUrl = convertImageUrl(imageUrlController.text);

      final userDoc2 = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userData2 = userDoc2.data();
      final sellerName =
          userData2?['name'] ?? user.displayName ?? 'CampusMart Seller';
      final storeId2 = userData2?['storeId']?.toString() ?? '';
      final hasStore = storeId2.isNotEmpty;

      await FirebaseFirestore.instance.collection('products').add({
        'sellerId': user.uid,
        'sellerName': sellerName,
        'sellerType': hasStore ? 'business' : 'individual',
        'storeId': hasStore ? storeId2 : null,
        'name': nameController.text.trim(),
        'description': descriptionController.text.trim(),
        'price': double.parse(priceController.text.trim()),
        'category': selectedCategory,
        'stock': int.parse(stockController.text.trim()),
        'imageUrl': imageUrl,
        'rating': 0.0,
        'reviewCount': 0,
        'isAvailable': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      setState(() {
        isPublishing = false;
      });

      showMessage('Product added to your store successfully! 🎉', diuGreen);

      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isPublishing = false;
      });
      showMessage('Something went wrong. Please try again.', Colors.red);
      debugPrint('Publish Product Error: $e');
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

  @override
  Widget build(BuildContext context) {
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
          'Add Product',
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
              constraints: const BoxConstraints(maxWidth: 650),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Product Image',
                      style: TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      height: 210,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: imageUrlController.text.isEmpty
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.image_outlined,
                                  color: diuGray,
                                  size: 50,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Product image preview',
                                  style: TextStyle(
                                    color: diuGray,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.network(
                                convertImageUrl(imageUrlController.text),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.broken_image_outlined,
                                          color: Colors.red,
                                          size: 40,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Image could not be loaded',
                                          style: TextStyle(
                                            color: diuGray,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: imageUrlController,
                      onChanged: (_) {
                        setState(() {});
                      },
                      keyboardType: TextInputType.url,
                      decoration: inputDecoration(
                        label: 'Image URL',
                        hint: 'Paste Google Drive or image URL',
                        icon: Icons.link_rounded,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter an image URL';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'Google Drive: set the image access to “Anyone with the link”.',
                      style: TextStyle(color: diuGray, fontSize: 11),
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      'Product Information',
                      style: TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: nameController,
                      decoration: inputDecoration(
                        label: 'Product Name',
                        hint: 'e.g. Succulent Plant',
                        icon: Icons.shopping_bag_outlined,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter product name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: inputDecoration(
                        label: 'Category',
                        hint: 'Select category',
                        icon: Icons.category_outlined,
                      ),
                      items: categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedCategory = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: priceController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: inputDecoration(
                              label: 'Price',
                              hint: '500',
                              icon: Icons.payments_outlined,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter price';
                              }
                              if (double.tryParse(value.trim()) == null) {
                                return 'Invalid price';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: stockController,
                            keyboardType: TextInputType.number,
                            decoration: inputDecoration(
                              label: 'Stock',
                              hint: '10',
                              icon: Icons.inventory_2_outlined,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter stock';
                              }
                              if (int.tryParse(value.trim()) == null) {
                                return 'Invalid stock';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: descriptionController,
                      maxLines: 5,
                      decoration: inputDecoration(
                        label: 'Description',
                        hint: 'Describe your product...',
                        icon: Icons.description_outlined,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter product description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: isPublishing ? null : publishProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: diuGreen,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: diuGreen.withOpacity(0.5),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isPublishing
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
                                  Icon(Icons.publish_rounded),
                                  SizedBox(width: 9),
                                  Text(
                                    'Publish Product',
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
}
