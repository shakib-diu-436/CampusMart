import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'offer_service_screen.dart';

const Color diuBlue = Color(0xFF034EA2);
const Color diuGreen = Color(0xFF39B54A);
const Color diuGray = Color(0xFF636466);
const Color campusBg = Color(0xFFF6F8FB);

class MyServicesScreen extends StatelessWidget {
  const MyServicesScreen({super.key});

  // ============================================================
  // DELETE SERVICE
  // ============================================================

  Future<void> _deleteService(BuildContext context, String serviceId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Service?'),

          content: const Text('This service will be permanently removed.'),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },

              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,

                foregroundColor: Colors.white,
              ),

              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('services')
          .doc(serviceId)
          .delete();

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Service deleted successfully.'),

            backgroundColor: diuGreen,

            behavior: SnackBarBehavior.floating,
          ),
        );
    } on FirebaseException catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Could not delete service: ${e.message}'),

            backgroundColor: Colors.red,

            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  // ============================================================
  // EDIT SERVICE
  // ============================================================

  Future<void> _editService(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            OfferServiceScreen(serviceId: doc.id, serviceData: doc.data()),
      ),
    );
  }

  // ============================================================
  // SERVICE CARD
  // ============================================================

  Widget _serviceCard(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    final title = data['title']?.toString() ?? 'Untitled Service';

    final category = data['category']?.toString() ?? 'Others';

    final description = data['description']?.toString() ?? '';

    final price = data['price'] ?? 0;

    final priceType = data['priceType']?.toString() ?? 'Fixed';

    final imageUrl = data['imageUrl']?.toString() ?? '';

    final isAvailable = data['isAvailable'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),

      child: Column(
        children: [
          // ======================================================
          // MAIN SERVICE AREA
          // ======================================================

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ==================================================
              // IMAGE
              // ==================================================

              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),

                  bottomLeft: Radius.circular(16),
                ),

                child: SizedBox(
                  width: 105,

                  height: 125,

                  child: imageUrl.isEmpty
                      ? Container(
                          color: const Color(0xFFEAF2FB),

                          child: const Icon(
                            Icons.handyman_rounded,

                            color: diuBlue,

                            size: 38,
                          ),
                        )
                      : Image.network(
                          imageUrl,

                          fit: BoxFit.cover,

                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFFEAF2FB),

                              child: const Icon(
                                Icons.handyman_rounded,

                                color: diuBlue,

                                size: 38,
                              ),
                            );
                          },
                        ),
                ),
              ),

              // ==================================================
              // SERVICE INFO
              // ==================================================
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(11),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      // ==================================================
                      // TITLE + MENU
                      // ==================================================

                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,

                              maxLines: 2,

                              overflow: TextOverflow.ellipsis,

                              style: const TextStyle(
                                color: Color(0xFF111827),

                                fontSize: 14,

                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          PopupMenuButton<String>(
                            padding: EdgeInsets.zero,

                            icon: const Icon(
                              Icons.more_vert_rounded,

                              size: 20,

                              color: diuGray,
                            ),

                            onSelected: (value) {
                              if (value == 'edit') {
                                _editService(context, doc);
                              }

                              if (value == 'delete') {
                                _deleteService(context, doc.id);
                              }
                            },

                            itemBuilder: (context) {
                              return [
                                const PopupMenuItem(
                                  value: 'edit',

                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.edit_outlined,

                                        color: diuBlue,

                                        size: 18,
                                      ),

                                      SizedBox(width: 8),

                                      Text('Edit'),
                                    ],
                                  ),
                                ),

                                const PopupMenuItem(
                                  value: 'delete',

                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete_outline_rounded,

                                        color: Colors.red,

                                        size: 18,
                                      ),

                                      SizedBox(width: 8),

                                      Text('Delete'),
                                    ],
                                  ),
                                ),
                              ];
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 5),

                      // ==================================================
                      // CATEGORY
                      // ==================================================
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,

                          vertical: 4,
                        ),

                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF2FB),

                          borderRadius: BorderRadius.circular(6),
                        ),

                        child: Text(
                          category,

                          style: const TextStyle(
                            color: diuBlue,

                            fontSize: 8,

                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 7),

                      // ==================================================
                      // DESCRIPTION
                      // ==================================================
                      Text(
                        description,

                        maxLines: 2,

                        overflow: TextOverflow.ellipsis,

                        style: const TextStyle(
                          color: diuGray,

                          fontSize: 9,

                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // ==================================================
                      // PRICE + STATUS
                      // ==================================================
                      Row(
                        children: [
                          Text(
                            '৳$price',

                            style: const TextStyle(
                              color: diuBlue,

                              fontSize: 15,

                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(width: 4),

                          Text(
                            '/ $priceType',

                            style: const TextStyle(color: diuGray, fontSize: 8),
                          ),

                          const Spacer(),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,

                              vertical: 4,
                            ),

                            decoration: BoxDecoration(
                              color: isAvailable
                                  ? const Color(0xFFE8F7EC)
                                  : const Color(0xFFFEECEC),

                              borderRadius: BorderRadius.circular(6),
                            ),

                            child: Text(
                              isAvailable ? 'Available' : 'Unavailable',

                              style: TextStyle(
                                color: isAvailable ? diuGreen : Colors.red,

                                fontSize: 8,

                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ======================================================
          // EDIT BUTTON
          // ======================================================
          Container(
            padding: const EdgeInsets.fromLTRB(11, 0, 11, 10),

            child: SizedBox(
              width: double.infinity,

              height: 38,

              child: OutlinedButton.icon(
                onPressed: () {
                  _editService(context, doc);
                },

                icon: const Icon(Icons.edit_outlined, size: 16),

                label: const Text('Edit Service'),

                style: OutlinedButton.styleFrom(
                  foregroundColor: diuBlue,

                  side: const BorderSide(color: diuBlue),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),

                  textStyle: const TextStyle(
                    fontSize: 11,

                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            const Icon(Icons.handyman_outlined, size: 60, color: diuGray),

            const SizedBox(height: 12),

            const Text(
              'You have no services',

              style: TextStyle(
                color: Color(0xFF111827),

                fontSize: 17,

                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Offer your skills and start earning from other students.',

              textAlign: TextAlign.center,

              style: TextStyle(color: diuGray, fontSize: 11, height: 1.4),
            ),
          ],
        ),
      ),
    );
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

        appBar: AppBar(title: const Text('My Services')),

        body: const Center(child: Text('Please login first.')),
      );
    }

    return Scaffold(
      backgroundColor: campusBg,

      appBar: AppBar(
        backgroundColor: Colors.white,

        elevation: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },

          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF111827)),
        ),

        title: const Text(
          'My Services',

          style: TextStyle(
            color: Color(0xFF111827),

            fontSize: 18,

            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('services')
            .where('providerId', isEqualTo: user.uid)
            .snapshots(),

        builder: (context, snapshot) {
          // ======================================================
          // LOADING
          // ======================================================

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: diuBlue),
            );
          }

          // ======================================================
          // ERROR
          // ======================================================

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(25),

                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    const Icon(
                      Icons.error_outline_rounded,

                      color: Colors.red,

                      size: 50,
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Could not load your services',

                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      snapshot.error.toString(),

                      textAlign: TextAlign.center,

                      style: const TextStyle(color: diuGray, fontSize: 10),
                    ),
                  ],
                ),
              ),
            );
          }

          // ======================================================
          // DOCUMENTS
          // ======================================================

          final docs = snapshot.data?.docs ?? [];

          // ======================================================
          // EMPTY
          // ======================================================

          if (docs.isEmpty) {
            return _emptyState(context);
          }

          // ======================================================
          // LIST
          // ======================================================

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),

            itemCount: docs.length,

            itemBuilder: (context, index) {
              return _serviceCard(context, docs[index]);
            },
          );
        },
      ),
    );
  }
}
