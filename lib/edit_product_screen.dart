import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color diuBlue = Color(0xFF034EA2);
const Color diuGreen = Color(0xFF39B54A);
const Color diuGray = Color(0xFF636466);

class EditProductScreen extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> product;

  const EditProductScreen({
    super.key,
    required this.productId,
    required this.product,
  });

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController priceController;
  late final TextEditingController stockController;
  late final TextEditingController descriptionController;
  late final TextEditingController imageUrlController;

  late String selectedCategory;

  bool isUpdating = false;

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
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.product['name'] ?? '');

    priceController = TextEditingController(
      text: (widget.product['price'] ?? '').toString(),
    );

    stockController = TextEditingController(
      text: (widget.product['stock'] ?? '').toString(),
    );

    descriptionController = TextEditingController(
      text: widget.product['description'] ?? '',
    );

    imageUrlController = TextEditingController(
      text: widget.product['imageUrl'] ?? '',
    );

    selectedCategory = widget.product['category'] ?? 'Other';

    if (!categories.contains(selectedCategory)) {
      selectedCategory = 'Other';
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    stockController.dispose();
    descriptionController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }

  // ============================================================
  // GOOGLE DRIVE URL
  // ============================================================

  String convertImageUrl(String url) {
    url = url.trim();

    final regex = RegExp(r'drive\.google\.com\/file\/d\/([^\/]+)');

    final match = regex.firstMatch(url);

    if (match != null) {
      final fileId = match.group(1);

      return 'https://drive.google.com/uc?export=view&id=$fileId';
    }

    return url;
  }

  // ============================================================
  // UPDATE PRODUCT
  // ============================================================

  Future<void> updateProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isUpdating = true;
    });

    try {
      final imageUrl = convertImageUrl(imageUrlController.text);

      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .update({
            'name': nameController.text.trim(),

            'category': selectedCategory,

            'price': double.parse(priceController.text.trim()),

            'stock': int.parse(stockController.text.trim()),

            'description': descriptionController.text.trim(),

            'imageUrl': imageUrl,

            'updatedAt': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;

      setState(() {
        isUpdating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product updated successfully! ✅'),
          backgroundColor: diuGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 600));

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isUpdating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Update failed: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),

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
          'Edit Product',
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
                    // =================================================
                    // IMAGE PREVIEW
                    // =================================================

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
                          ? const Center(
                              child: Icon(
                                Icons.image_outlined,
                                color: diuGray,
                                size: 50,
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(18),

                              child: Image.network(
                                convertImageUrl(imageUrlController.text),

                                fit: BoxFit.cover,

                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      color: Colors.red,
                                      size: 45,
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
                        hint: 'Paste image or Google Drive URL',
                        icon: Icons.link_rounded,
                      ),

                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter image URL';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 25),

                    // =================================================
                    // PRODUCT NAME
                    // =================================================
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
                        hint: 'Enter product name',
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

                    // =================================================
                    // CATEGORY
                    // =================================================
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,

                      decoration: inputDecoration(
                        label: 'Category',
                        hint: 'Select category',
                        icon: Icons.category_outlined,
                      ),

                      items: categories
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ),
                          )
                          .toList(),

                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedCategory = value;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 14),

                    // =================================================
                    // PRICE + STOCK
                    // =================================================
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

                    // =================================================
                    // DESCRIPTION
                    // =================================================
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
                          return 'Enter description';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 25),

                    // =================================================
                    // UPDATE BUTTON
                    // =================================================
                    SizedBox(
                      width: double.infinity,
                      height: 55,

                      child: ElevatedButton(
                        onPressed: isUpdating ? null : updateProduct,

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
                                    'Update Product',
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
}
