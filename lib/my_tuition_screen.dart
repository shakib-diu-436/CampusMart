import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'offer_tuition_screen.dart';

const Color tuitionBlue = Color(0xFF034EA2);
const Color tuitionGreen = Color(0xFF39B54A);
const Color tuitionGray = Color(0xFF636466);
const Color tuitionBg = Color(0xFFF6F8FB);

class MyTuitionScreen extends StatelessWidget {
  const MyTuitionScreen({super.key});

  // ============================================================
  // DELETE TUITION
  // ============================================================

  Future<void> _deleteTuition(BuildContext context, String tuitionId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Tuition Post?'),
          content: const Text('This tuition post will be permanently removed.'),
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
          .collection('tuition')
          .doc(tuitionId)
          .delete();

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Tuition post deleted successfully.'),
            backgroundColor: tuitionGreen,
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
            content: Text('Could not delete tuition: ${e.message}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  // ============================================================
  // EDIT TUITION
  // ============================================================

  Future<void> _editTuition(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            OfferTuitionScreen(tuitionId: doc.id, tuitionData: doc.data()),
      ),
    );

    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Tuition updated successfully.'),
            backgroundColor: tuitionGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  // ============================================================
  // TUITION CARD
  // ============================================================

  Widget _tuitionCard(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    final subject = data['subject']?.toString() ?? 'Other';

    final classLevel = data['classLevel']?.toString() ?? 'All Levels';

    final description = data['description']?.toString() ?? '';

    final fee = data['fee'] ?? 0;

    final feeType = data['feeType']?.toString() ?? 'Monthly';

    final teachingMode = data['teachingMode']?.toString() ?? 'Online';

    final location = data['location']?.toString() ?? '';

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
                            Icons.school_rounded,
                            color: tuitionBlue,
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
                                Icons.school_rounded,
                                color: tuitionBlue,
                                size: 38,
                              ),
                            );
                          },
                        ),
                ),
              ),

              // ==================================================
              // INFORMATION
              // ==================================================
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(11),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              subject,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF111827),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          // ==================================================
                          // MENU
                          // ==================================================
                          PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.more_vert_rounded,
                              color: tuitionGray,
                              size: 20,
                            ),
                            onSelected: (value) {
                              if (value == 'edit') {
                                _editTuition(context, doc);
                              }

                              if (value == 'delete') {
                                _deleteTuition(context, doc.id);
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
                                        color: tuitionBlue,
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
                      // CLASS LEVEL
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
                          classLevel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: tuitionBlue,
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
                          color: tuitionGray,
                          fontSize: 9,
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // ==================================================
                      // MODE + LOCATION
                      // ==================================================
                      Row(
                        children: [
                          Icon(
                            teachingMode == 'Online'
                                ? Icons.computer_rounded
                                : teachingMode == 'Offline'
                                ? Icons.location_on_outlined
                                : Icons.swap_horiz_rounded,
                            color: tuitionGreen,
                            size: 13,
                          ),

                          const SizedBox(width: 4),

                          Expanded(
                            child: Text(
                              location.isEmpty
                                  ? teachingMode
                                  : '$teachingMode • $location',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: tuitionGray,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 7),

                      // ==================================================
                      // FEE + STATUS
                      // ==================================================
                      Row(
                        children: [
                          Text(
                            '৳$fee',
                            style: const TextStyle(
                              color: tuitionBlue,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(width: 4),

                          Text(
                            '/ $feeType',
                            style: const TextStyle(
                              color: tuitionGray,
                              fontSize: 8,
                            ),
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
                                color: isAvailable ? tuitionGreen : Colors.red,
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
                  _editTuition(context, doc);
                },
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit Tuition'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: tuitionBlue,
                  side: const BorderSide(color: tuitionBlue),
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

  Widget _emptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.school_outlined, size: 60, color: tuitionGray),
            SizedBox(height: 12),
            Text(
              'You have no tuition posts',
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Offer tuition and start teaching other students.',
              textAlign: TextAlign.center,
              style: TextStyle(color: tuitionGray, fontSize: 11, height: 1.4),
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
        backgroundColor: tuitionBg,
        appBar: AppBar(title: const Text('My Tuition')),
        body: const Center(child: Text('Please login first.')),
      );
    }

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

        title: const Text(
          'My Tuition',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('tuition')
            .where('tutorId', isEqualTo: user.uid)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: tuitionBlue),
            );
          }

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
                      'Could not load your tuition posts',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: tuitionGray, fontSize: 10),
                    ),
                  ],
                ),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return _emptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              return _tuitionCard(context, docs[index]);
            },
          );
        },
      ),
    );
  }
}
