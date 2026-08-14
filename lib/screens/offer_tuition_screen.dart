import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

const Color tuitionBlue = Color(0xFF034EA2);
const Color tuitionGreen = Color(0xFF39B54A);
const Color tuitionGray = Color(0xFF636466);
const Color tuitionBg = Color(0xFFF6F8FB);

class OfferTuitionScreen extends StatefulWidget {
  final String? tuitionId;
  final Map<String, dynamic>? tuitionData;

  const OfferTuitionScreen({super.key, this.tuitionId, this.tuitionData});

  bool get isEditMode => tuitionId != null;

  @override
  State<OfferTuitionScreen> createState() => _OfferTuitionScreenState();
}

class _OfferTuitionScreenState extends State<OfferTuitionScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController classController = TextEditingController();

  final TextEditingController descriptionController = TextEditingController();

  final TextEditingController feeController = TextEditingController();

  final TextEditingController locationController = TextEditingController();

  final TextEditingController imageUrlController = TextEditingController();

  String selectedSubject = 'CSE';

  String selectedFeeType = 'Monthly';

  String selectedTeachingMode = 'Both';

  bool isAvailable = true;

  bool isPublishing = false;

  final List<String> subjects = [
    'CSE',
    'Programming',
    'Mathematics',
    'Physics',
    'Chemistry',
    'English',
    'Accounting',
    'Economics',
    'Other',
  ];

  final List<String> feeTypes = [
    'Monthly',
    'Per Class',
    'Per Hour',
    'Negotiable',
  ];

  final List<String> teachingModes = ['Online', 'Offline', 'Both'];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    final data = widget.tuitionData;

    if (data == null) {
      return;
    }

    classController.text = data['classLevel']?.toString() ?? '';

    descriptionController.text = data['description']?.toString() ?? '';

    feeController.text = data['fee']?.toString() ?? '';

    locationController.text = data['location']?.toString() ?? '';

    imageUrlController.text = data['imageUrl']?.toString() ?? '';

    final subject = data['subject']?.toString();

    if (subject != null && subjects.contains(subject)) {
      selectedSubject = subject;
    }

    final feeType = data['feeType']?.toString();

    if (feeType != null && feeTypes.contains(feeType)) {
      selectedFeeType = feeType;
    }

    final teachingMode = data['teachingMode']?.toString();

    if (teachingMode != null && teachingModes.contains(teachingMode)) {
      selectedTeachingMode = teachingMode;
    }

    isAvailable = data['isAvailable'] == true;
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    classController.dispose();
    descriptionController.dispose();
    feeController.dispose();
    locationController.dispose();
    imageUrlController.dispose();

    super.dispose();
  }

  // ============================================================
  // CREATE / UPDATE TUITION
  // ============================================================

  Future<void> publishTuition() async {
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
      // ========================================================
      // GET USER DATA
      // ========================================================

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final userData = userDoc.data();

      final tutorName =
          userData?['name'] ??
          user.displayName ??
          user.email?.split('@').first ??
          'CampusMart Tutor';

      // ========================================================
      // TUITION DATA
      // ========================================================

      final tuitionData = {
        'tutorId': user.uid,

        'tutorName': tutorName,

        'tutorEmail': user.email ?? '',

        'subject': selectedSubject,

        'classLevel': classController.text.trim(),

        'description': descriptionController.text.trim(),

        'fee': int.tryParse(feeController.text.trim()) ?? 0,

        'feeType': selectedFeeType,

        'teachingMode': selectedTeachingMode,

        'location': locationController.text.trim(),

        'imageUrl': imageUrlController.text.trim(),

        'isAvailable': isAvailable,

        'updatedAt': FieldValue.serverTimestamp(),
      };

      // ========================================================
      // EDIT EXISTING TUITION
      // ========================================================

      if (widget.isEditMode) {
        await FirebaseFirestore.instance
            .collection('tuition')
            .doc(widget.tuitionId)
            .update(tuitionData);
      }
      // ========================================================
      // CREATE NEW TUITION
      // ========================================================
      else {
        await FirebaseFirestore.instance.collection('tuition').add({
          ...tuitionData,

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
                  ? 'Tuition updated successfully!'
                  : 'Tuition posted successfully!',
            ),

            backgroundColor: tuitionGreen,

            behavior: SnackBarBehavior.floating,
          ),
        );

      Navigator.pop(context, true);
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
                  : 'Could not save tuition: ${e.message}',
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
  // INPUT DECORATION
  // ============================================================

  InputDecoration inputDecoration({required String hint, IconData? icon}) {
    return InputDecoration(
      hintText: hint,

      hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),

      prefixIcon: icon == null
          ? null
          : Icon(icon, color: tuitionBlue, size: 20),

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

        borderSide: const BorderSide(color: tuitionBlue, width: 1.3),
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
  // DROPDOWN
  // ============================================================

  Widget dropdownBox({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(horizontal: 14),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(12),

        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),

      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,

          isExpanded: true,

          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: tuitionBlue,
          ),

          items: items.map((item) {
            return DropdownMenuItem(
              value: item,

              child: Row(
                children: [
                  Icon(icon, size: 17, color: tuitionBlue),

                  const SizedBox(width: 8),

                  Text(item, style: const TextStyle(fontSize: 12)),
                ],
              ),
            );
          }).toList(),

          onChanged: onChanged,
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
      backgroundColor: tuitionBg,

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
          widget.isEditMode ? 'Edit Tuition' : 'Offer Tuition',

          style: const TextStyle(
            color: Color(0xFF111827),

            fontSize: 18,

            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Form(
        key: _formKey,

        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ==================================================
              // HEADER
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
                        Icons.school_rounded,

                        color: tuitionBlue,

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
                                ? 'Edit your tuition'
                                : 'Offer Tuition',

                            style: const TextStyle(
                              color: Color(0xFF111827),

                              fontSize: 15,

                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            widget.isEditMode
                                ? 'Update your tuition information.'
                                : 'Share your knowledge and teach other students.',

                            style: const TextStyle(
                              color: tuitionGray,

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
              // SUBJECT
              // ==================================================
              sectionTitle('Subject'),

              dropdownBox(
                value: selectedSubject,

                items: subjects,

                icon: Icons.menu_book_rounded,

                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    selectedSubject = value;
                  });
                },
              ),

              const SizedBox(height: 18),

              // ==================================================
              // CLASS / LEVEL
              // ==================================================
              sectionTitle('Class / Level'),

              TextFormField(
                controller: classController,

                textInputAction: TextInputAction.next,

                decoration: inputDecoration(
                  hint: 'e.g. Class 9-10 / HSC / University',

                  icon: Icons.class_outlined,
                ),

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter class or level';
                  }

                  return null;
                },
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
                  hint: 'Describe what you teach, your experience and what students can expect.',

                  icon: Icons.description_outlined,
                ),

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please describe your tuition';
                  }

                  if (value.trim().length < 20) {
                    return 'Description should be at least 20 characters';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 18),

              // ==================================================
              // FEE
              // ==================================================
              sectionTitle('Tuition Fee'),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Expanded(
                    child: TextFormField(
                      controller: feeController,

                      keyboardType: TextInputType.number,

                      decoration: inputDecoration(
                        hint: 'e.g. 3000',

                        icon: Icons.payments_outlined,
                      ),

                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter fee';
                        }

                        final fee = int.tryParse(value.trim());

                        if (fee == null || fee < 0) {
                          return 'Invalid fee';
                        }

                        return null;
                      },
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: dropdownBox(
                      value: selectedFeeType,

                      items: feeTypes,

                      icon: Icons.payments_outlined,

                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          selectedFeeType = value;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ==================================================
              // TEACHING MODE
              // ==================================================
              sectionTitle('Teaching Mode'),

              dropdownBox(
                value: selectedTeachingMode,

                items: teachingModes,

                icon: Icons.computer_rounded,

                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    selectedTeachingMode = value;
                  });
                },
              ),

              const SizedBox(height: 18),

              // ==================================================
              // LOCATION
              // ==================================================
              sectionTitle('Location'),

              TextFormField(
                controller: locationController,

                textInputAction: TextInputAction.next,

                decoration: inputDecoration(
                  hint: 'e.g. Daffodil Smart City / Mirpur / Online',

                  icon: Icons.location_on_outlined,
                ),

                validator: (value) {
                  if (selectedTeachingMode == 'Offline' ||
                      selectedTeachingMode == 'Both') {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your teaching location';
                    }
                  }

                  return null;
                },
              ),

              const SizedBox(height: 18),

              // ==================================================
              // IMAGE URL
              // ==================================================
              sectionTitle('Profile / Tuition Image URL (Optional)'),

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
              // AVAILABLE
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
                    'Available for tuition',

                    style: TextStyle(
                      color: Color(0xFF111827),

                      fontSize: 13,

                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  subtitle: const Text(
                    'Turn this off when you are not accepting new students.',

                    style: TextStyle(color: tuitionGray, fontSize: 9),
                  ),

                  value: isAvailable,

                  activeColor: tuitionGreen,

                  onChanged: (value) {
                    setState(() {
                      isAvailable = value;
                    });
                  },
                ),
              ),

              const SizedBox(height: 25),

              // ==================================================
              // BUTTON
              // ==================================================
              SizedBox(
                width: double.infinity,

                height: 52,

                child: ElevatedButton.icon(
                  onPressed: isPublishing ? null : publishTuition,

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
                              ? 'Update Tuition'
                              : 'Publish Tuition'),
                  ),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: tuitionBlue,

                    foregroundColor: Colors.white,

                    disabledBackgroundColor: tuitionBlue.withOpacity(.5),

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
                      ? 'Your changes will be saved to this tuition post.'
                      : 'You can edit or remove your tuition post later.',

                  style: const TextStyle(color: tuitionGray, fontSize: 9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
