import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

const Color diuBlue = Color(0xFF034EA2);
const Color diuGreen = Color(0xFF39B54A);
const Color diuGray = Color(0xFF636466);
const Color campusBg = Color(0xFFF6F8FB);

class OfferServiceScreen extends StatefulWidget {
  final String? serviceId;
  final Map<String, dynamic>? serviceData;

  const OfferServiceScreen({super.key, this.serviceId, this.serviceData});

  bool get isEditMode => serviceId != null;

  @override
  State<OfferServiceScreen> createState() => _OfferServiceScreenState();
}

class _OfferServiceScreenState extends State<OfferServiceScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();

  final TextEditingController descriptionController = TextEditingController();

  final TextEditingController priceController = TextEditingController();

  final TextEditingController imageUrlController = TextEditingController();

  String selectedCategory = 'Programming';

  String selectedPriceType = 'Fixed';

  bool isAvailable = true;

  bool isPublishing = false;

  final List<String> categories = [
    'Programming',
    'Graphic Design',
    'Video Editing',
    'Writing',
    'Photography',
    'Marketing',
    'Data Entry',
    'Others',
  ];

  final List<String> priceTypes = [
    'Fixed',
    'Per Hour',
    'Per Project',
    'Negotiable',
  ];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    final data = widget.serviceData;

    if (data == null) {
      return;
    }

    // Existing title
    titleController.text = data['title']?.toString() ?? '';

    // Existing description
    descriptionController.text = data['description']?.toString() ?? '';

    // Existing price
    priceController.text = data['price']?.toString() ?? '';

    // Existing image
    imageUrlController.text = data['imageUrl']?.toString() ?? '';

    // Existing category
    final category = data['category']?.toString();

    if (category != null && categories.contains(category)) {
      selectedCategory = category;
    }

    // Existing price type
    final priceType = data['priceType']?.toString();

    if (priceType != null && priceTypes.contains(priceType)) {
      selectedPriceType = priceType;
    }

    // Existing availability
    isAvailable = data['isAvailable'] == true;
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    imageUrlController.dispose();

    super.dispose();
  }

  // ============================================================
  // CREATE / UPDATE SERVICE
  // ============================================================

  Future<void> publishService() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
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
      final serviceData = {
        'providerId': user.uid,

        'providerName':
            user.displayName ??
            user.email?.split('@').first ??
            'CampusMart Student',

        'providerEmail': user.email ?? '',

        'title': titleController.text.trim(),

        'category': selectedCategory,

        'description': descriptionController.text.trim(),

        'price': int.tryParse(priceController.text.trim()) ?? 0,

        'priceType': selectedPriceType,

        'imageUrl': imageUrlController.text.trim(),

        'isAvailable': isAvailable,

        'updatedAt': FieldValue.serverTimestamp(),
      };

      // ========================================================
      // EDIT EXISTING SERVICE
      // ========================================================

      if (widget.isEditMode) {
        await FirebaseFirestore.instance
            .collection('services')
            .doc(widget.serviceId)
            .update(serviceData);
      }
      // ========================================================
      // CREATE NEW SERVICE
      // ========================================================
      else {
        await FirebaseFirestore.instance.collection('services').add({
          ...serviceData,

          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditMode
                  ? 'Service updated successfully!'
                  : 'Service published successfully!',
            ),

            backgroundColor: diuGreen,

            behavior: SnackBarBehavior.floating,
          ),
        );

      Navigator.pop(context);
    }
    // ==========================================================
    // FIREBASE ERROR
    // ==========================================================
    on FirebaseException catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              e.code == 'permission-denied'
                  ? 'Permission denied. Check your Firestore rules.'
                  : 'Could not save service: ${e.message}',
            ),

            backgroundColor: Colors.red,

            behavior: SnackBarBehavior.floating,
          ),
        );
    }
    // ==========================================================
    // OTHER ERROR
    // ==========================================================
    catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Something went wrong: $e'),

            backgroundColor: Colors.red,

            behavior: SnackBarBehavior.floating,
          ),
        );
    }
    // ==========================================================
    // FINALLY
    // ==========================================================
    finally {
      if (mounted) {
        setState(() {
          isPublishing = false;
        });
      }
    }
  }

  // ============================================================
  // TEXT FIELD DECORATION
  // ============================================================

  InputDecoration inputDecoration({required String hint, IconData? icon}) {
    return InputDecoration(
      hintText: hint,

      hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),

      prefixIcon: icon == null ? null : Icon(icon, color: diuBlue, size: 20),

      filled: true,

      fillColor: Colors.white,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),

        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),

        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),

        borderSide: const BorderSide(color: diuBlue, width: 1.3),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),

        borderSide: const BorderSide(color: Colors.red),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),

        borderSide: const BorderSide(color: Colors.red),
      ),

      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),

      child: Text(
        title,

        style: const TextStyle(
          color: Color(0xFF111827),

          fontSize: 14,

          fontWeight: FontWeight.bold,
        ),
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

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        backgroundColor: Colors.white,

        elevation: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },

          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF111827)),
        ),

        title: Text(
          widget.isEditMode ? 'Edit Service' : 'Offer a Service',

          style: const TextStyle(
            color: Color(0xFF111827),

            fontSize: 18,

            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ========================================================
      // FORM
      // ========================================================
      body: Form(
        key: _formKey,

        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ==================================================
              // HEADER CARD
              // ==================================================

              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FB),

                  borderRadius: BorderRadius.circular(16),
                ),

                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius: BorderRadius.circular(14),
                      ),

                      child: const Icon(
                        Icons.handyman_rounded,

                        color: diuBlue,

                        size: 26,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            widget.isEditMode
                                ? 'Edit your service'
                                : 'Share your skills',

                            style: const TextStyle(
                              color: Color(0xFF111827),

                              fontSize: 15,

                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            widget.isEditMode
                                ? 'Update your service information.'
                                : 'Help other students and earn from your skills.',

                            style: const TextStyle(
                              color: diuGray,

                              fontSize: 10,

                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // ==================================================
              // SERVICE TITLE
              // ==================================================
              sectionTitle('Service Title'),

              TextFormField(
                controller: titleController,

                textInputAction: TextInputAction.next,

                decoration: inputDecoration(
                  hint: 'e.g. I will design a professional logo',

                  icon: Icons.title_rounded,
                ),

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a service title';
                  }

                  if (value.trim().length < 5) {
                    return 'Title is too short';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 18),

              // ==================================================
              // CATEGORY
              // ==================================================
              sectionTitle('Service Category'),

              Container(
                width: double.infinity,

                padding: const EdgeInsets.symmetric(horizontal: 14),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(12),

                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),

                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCategory,

                    isExpanded: true,

                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,

                      color: diuBlue,
                    ),

                    items: categories.map((category) {
                      return DropdownMenuItem(
                        value: category,

                        child: Row(
                          children: [
                            const Icon(
                              Icons.handyman_outlined,

                              size: 17,

                              color: diuBlue,
                            ),

                            const SizedBox(width: 8),

                            Text(
                              category,

                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    }).toList(),

                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }

                      setState(() {
                        selectedCategory = value;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ==================================================
              // DESCRIPTION
              // ==================================================
              sectionTitle('Description'),

              TextFormField(
                controller: descriptionController,

                minLines: 5,

                maxLines: 8,

                decoration: inputDecoration(
                  hint: 'Describe what you offer, what is included, and what the client will receive.',

                  icon: Icons.description_outlined,
                ),

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please describe your service';
                  }

                  if (value.trim().length < 20) {
                    return 'Description should be at least 20 characters';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 18),

              // ==================================================
              // PRICE
              // ==================================================
              sectionTitle('Price'),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Expanded(
                    child: TextFormField(
                      controller: priceController,

                      keyboardType: TextInputType.number,

                      decoration: inputDecoration(
                        hint: 'e.g. 500',

                        icon: Icons.payments_outlined,
                      ),

                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter price';
                        }

                        final price = int.tryParse(value.trim());

                        if (price == null || price < 0) {
                          return 'Invalid price';
                        }

                        return null;
                      },
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Container(
                      height: 50,

                      padding: const EdgeInsets.symmetric(horizontal: 12),

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius: BorderRadius.circular(12),

                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),

                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedPriceType,

                          isExpanded: true,

                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,

                            color: diuBlue,
                          ),

                          items: priceTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,

                              child: Text(
                                type,

                                style: const TextStyle(fontSize: 11),
                              ),
                            );
                          }).toList(),

                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }

                            setState(() {
                              selectedPriceType = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ==================================================
              // IMAGE URL
              // ==================================================
              sectionTitle('Service Image URL (Optional)'),

              TextFormField(
                controller: imageUrlController,

                keyboardType: TextInputType.url,

                decoration: inputDecoration(
                  hint: 'https://example.com/image.jpg',

                  icon: Icons.image_outlined,
                ),
              ),

              const SizedBox(height: 18),

              // ==================================================
              // AVAILABILITY
              // ==================================================
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(12),

                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),

                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,

                  title: const Text(
                    'Available for hire',

                    style: TextStyle(
                      color: Color(0xFF111827),

                      fontSize: 13,

                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  subtitle: const Text(
                    'Turn this off when you are not accepting new requests.',

                    style: TextStyle(color: diuGray, fontSize: 9),
                  ),

                  value: isAvailable,

                  activeColor: diuGreen,

                  onChanged: (value) {
                    setState(() {
                      isAvailable = value;
                    });
                  },
                ),
              ),

              const SizedBox(height: 25),

              // ==================================================
              // SAVE / PUBLISH BUTTON
              // ==================================================
              SizedBox(
                width: double.infinity,

                height: 52,

                child: ElevatedButton.icon(
                  onPressed: isPublishing ? null : publishService,

                  icon: isPublishing
                      ? const SizedBox(
                          width: 20,
                          height: 20,

                          child: CircularProgressIndicator(
                            strokeWidth: 2,

                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          widget.isEditMode
                              ? Icons.save_rounded
                              : Icons.publish_rounded,
                        ),

                  label: Text(
                    isPublishing
                        ? (widget.isEditMode ? 'Updating...' : 'Publishing...')
                        : (widget.isEditMode
                              ? 'Update Service'
                              : 'Publish Service'),
                  ),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: diuBlue,

                    foregroundColor: Colors.white,

                    disabledBackgroundColor: diuBlue.withOpacity(.5),

                    elevation: 0,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),

                    textStyle: const TextStyle(
                      fontSize: 14,

                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Center(
                child: Text(
                  widget.isEditMode
                      ? 'Your changes will be saved to this service.'
                      : 'You can edit or remove your service later.',

                  style: const TextStyle(color: diuGray, fontSize: 9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
