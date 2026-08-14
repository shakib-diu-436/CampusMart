import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color diuBlue = Color(0xFF034EA2);
const Color diuGreen = Color(0xFF39B54A);
const Color diuGray = Color(0xFF636466);
const Color campusBg = Color(0xFFF6F8FB);

class AddStudentProductScreen extends StatefulWidget {
  final String? editProductId;
  final Map<String, dynamic>? editProductData;

  const AddStudentProductScreen({
    super.key,
    this.editProductId,
    this.editProductData,
  });

  bool get isEditMode => editProductId != null;

  @override
  State<AddStudentProductScreen> createState() =>
      _AddStudentProductScreenState();
}

class _AddStudentProductScreenState extends State<AddStudentProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();

  String selectedCategory = 'Books';
  String selectedCondition = 'Used - Good';
  bool isPublishing = false;

  final List<String> categories = [
    'Books',
    'Electronics',
    'Clothing',
    'Furniture',
    'Sports',
    'Stationery',
    'Others',
  ];

  final List<String> conditions = [
    'New',
    'Used - Like New',
    'Used - Good',
    'Used - Fair',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isEditMode && widget.editProductData != null) {
      final data = widget.editProductData!;
      titleController.text = data['title']?.toString() ?? '';
      descriptionController.text = data['description']?.toString() ?? '';
      priceController.text = data['price']?.toString() ?? '';
      imageUrlController.text = data['imageUrl']?.toString() ?? '';
      selectedCategory = data['category']?.toString() ?? 'Books';
      selectedCondition = data['condition']?.toString() ?? 'Used - Good';
      if (!categories.contains(selectedCategory)) selectedCategory = 'Books';
      if (!conditions.contains(selectedCondition))
        selectedCondition = 'Used - Good';
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }

  Future<void> publishProduct() async {
    if (!_formKey.currentState!.validate()) return;

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

    setState(() {
      isPublishing = true;
    });

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userData = userDoc.data();
      final studentName =
          userData?['name']?.toString() ?? user.displayName ?? 'DIU Student';

      final productData = {
        'studentId': user.uid,
        'studentName': studentName,
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'price': double.parse(priceController.text.trim()),
        'category': selectedCategory,
        'condition': selectedCondition,
        'imageUrl': imageUrlController.text.trim(),
        'isAvailable': true,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (widget.isEditMode) {
        await FirebaseFirestore.instance
            .collection('student_products')
            .doc(widget.editProductId)
            .update(productData);
      } else {
        await FirebaseFirestore.instance.collection('student_products').add({
          ...productData,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;
      setState(() {
        isPublishing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditMode
                ? 'Listing updated successfully! ✅'
                : 'Your listing has been published! 🎉',
          ),
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
        isPublishing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
      backgroundColor: campusBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: diuGray),
        ),
        title: Text(
          widget.isEditMode ? 'Edit Listing' : 'List an Item',
          style: const TextStyle(
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
                    Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: imageUrlController.text.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_outlined,
                                    color: diuGray,
                                    size: 50,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Item image preview',
                                    style: TextStyle(
                                      color: diuGray,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.network(
                                imageUrlController.text,
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
                      onChanged: (_) => setState(() {}),
                      keyboardType: TextInputType.url,
                      decoration: inputDecoration(
                        label: 'Image URL',
                        hint: 'Paste image URL (Google Drive or direct)',
                        icon: Icons.link_rounded,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter an image URL';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      'Item Information',
                      style: TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: titleController,
                      decoration: inputDecoration(
                        label: 'Item Title',
                        hint: 'e.g. Programming Book - CSE 101',
                        icon: Icons.shopping_bag_outlined,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter item title';
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
                    DropdownButtonFormField<String>(
                      value: selectedCondition,
                      decoration: inputDecoration(
                        label: 'Condition',
                        hint: 'Select condition',
                        icon: Icons.star_outline_rounded,
                      ),
                      items: conditions.map((condition) {
                        return DropdownMenuItem<String>(
                          value: condition,
                          child: Text(condition),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedCondition = value;
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
                              label: 'Price (৳)',
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
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: descriptionController,
                      maxLines: 5,
                      decoration: inputDecoration(
                        label: 'Description',
                        hint: 'Describe your item...',
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
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: isPublishing ? null : publishProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.isEditMode
                              ? diuBlue
                              : const Color(0xFFF57C00),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFFF57C00)
                              .withOpacity(0.5),
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
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    widget.isEditMode
                                        ? Icons.save_rounded
                                        : Icons.publish_rounded,
                                  ),
                                  const SizedBox(width: 9),
                                  Text(
                                    widget.isEditMode
                                        ? 'Update Listing'
                                        : 'Publish Listing',
                                    style: const TextStyle(
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
