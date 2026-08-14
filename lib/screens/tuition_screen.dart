import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'offer_tuition_screen.dart';

const Color diuBlue = Color(0xFF034EA2);
const Color diuGreen = Color(0xFF39B54A);
const Color diuGray = Color(0xFF636466);
const Color campusBg = Color(0xFFF6F8FB);

class TuitionScreen extends StatelessWidget {
  const TuitionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Tuition Marketplace'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OfferTuitionScreen()),
              );
            },
            icon: const Icon(Icons.add_business_rounded, color: diuBlue),
          ),
        ],
      ),
      body: const TuitionBody(),
    );
  }
}

class TuitionBody extends StatefulWidget {
  const TuitionBody({super.key});

  @override
  State<TuitionBody> createState() => _TuitionBodyState();
}

class _TuitionBodyState extends State<TuitionBody> {
  final TextEditingController searchController = TextEditingController();
  String selectedSubject = 'All';
  String selectedMode = 'All';

  final List<String> subjects = [
    'All',
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

  final List<String> modes = ['All', 'Online', 'Offline', 'Both'];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getTuitionStream() {
    return FirebaseFirestore.instance
        .collection('tuition')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> filterTuition(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final search = searchController.text.trim().toLowerCase();
    return docs.where((doc) {
      final data = doc.data();
      final subject = data['subject']?.toString().toLowerCase() ?? '';
      final tutor = data['tutorName']?.toString().toLowerCase() ?? '';
      final classLevel = data['classLevel']?.toString().toLowerCase() ?? '';
      final mode = data['teachingMode']?.toString() ?? '';

      if (selectedSubject != 'All' &&
          subject != selectedSubject.toLowerCase()) {
        return false;
      }
      if (selectedMode != 'All' && mode != selectedMode) {
        return false;
      }

      if (search.isNotEmpty) {
        return subject.contains(search) ||
            tutor.contains(search) ||
            classLevel.contains(search);
      }

      return true;
    }).toList();
  }

  Widget tutorCard(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final tutorName = data['tutorName']?.toString() ?? 'CampusMart Tutor';
    final subject = data['subject']?.toString() ?? 'Other';
    final classLevel = data['classLevel']?.toString() ?? 'All Levels';
    final description = data['description']?.toString() ?? '';
    final fee = data['fee'] ?? 0;
    final feeType = data['feeType']?.toString() ?? 'Monthly';
    final mode = data['teachingMode']?.toString() ?? 'Online';
    final location = data['location']?.toString() ?? '';
    final imageUrl = data['imageUrl']?.toString() ?? '';

    return InkWell(
      onTap: () {
        _showTutorDetails(context, data);
      },
      borderRadius: BorderRadius.circular(17),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 115,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(17),
                ),
                child: imageUrl.isEmpty
                    ? Container(
                        color: const Color(0xFFEAF2FB),
                        child: const Icon(
                          Icons.school_rounded,
                          color: diuBlue,
                          size: 42,
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
                              color: diuBlue,
                              size: 42,
                            ),
                          );
                        },
                      ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(11),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                        subject,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: diuBlue,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      tutorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      classLevel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: diuGray, fontSize: 9),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(
                          mode == 'Online'
                              ? Icons.computer_rounded
                              : Icons.location_on_outlined,
                          color: diuGreen,
                          size: 13,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            mode,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: diuGray, fontSize: 9),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '৳$fee',
                          style: const TextStyle(
                            color: diuBlue,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          feeType,
                          style: const TextStyle(
                            color: diuGreen,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
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
      ),
    );
  }

  void _showTutorDetails(BuildContext context, Map<String, dynamic> data) {
    final tutorName = data['tutorName']?.toString() ?? 'CampusMart Tutor';
    final subject = data['subject']?.toString() ?? 'Other';
    final classLevel = data['classLevel']?.toString() ?? 'All Levels';
    final description =
        data['description']?.toString() ?? 'No description available.';
    final fee = data['fee'] ?? 0;
    final feeType = data['feeType']?.toString() ?? 'Monthly';
    final mode = data['teachingMode']?.toString() ?? 'Online';
    final location = data['location']?.toString() ?? 'Not specified';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          constraints: const BoxConstraints(maxHeight: 650),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 25),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1D5DB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF2FB),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.school_rounded,
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
                            tutorName,
                            style: const TextStyle(
                              color: Color(0xFF111827),
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            subject,
                            style: const TextStyle(
                              color: diuBlue,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _detailRow(Icons.class_outlined, 'Class / Level', classLevel),
                const SizedBox(height: 10),
                _detailRow(Icons.computer_outlined, 'Teaching Mode', mode),
                const SizedBox(height: 10),
                _detailRow(Icons.location_on_outlined, 'Location', location),
                const SizedBox(height: 20),
                const Text(
                  'About the Tutor',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  description,
                  style: const TextStyle(
                    color: diuGray,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F8FB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Tuition Fee',
                        style: TextStyle(color: diuGray, fontSize: 11),
                      ),
                      const Spacer(),
                      Text(
                        '৳$fee',
                        style: const TextStyle(
                          color: diuBlue,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '/ $feeType',
                        style: const TextStyle(color: diuGray, fontSize: 9),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(
                              'Tuition application for $tutorName will be connected next.',
                            ),
                            backgroundColor: diuBlue,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                    },
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text('Apply / Book Tuition'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: diuBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: diuBlue, size: 18),
        const SizedBox(width: 9),
        Text(
          '$title: ',
          style: const TextStyle(
            color: diuGray,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: TextField(
            controller: searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search tutor, subject or class...',
              hintStyle: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 12,
              ),
              prefixIcon: const Icon(Icons.search_rounded, color: diuBlue),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        searchController.clear();
                        setState(() {});
                      },
                      icon: const Icon(
                        Icons.close_rounded,
                        color: diuGray,
                        size: 18,
                      ),
                    )
                  : null,
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
                borderSide: const BorderSide(color: diuBlue, width: 1.3),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final subject = subjects[index];
              final selected = selectedSubject == subject;
              return GestureDetector(
                onTap: () => setState(() => selectedSubject = subject),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? diuBlue : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? diuBlue : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Text(
                    subject,
                    style: TextStyle(
                      color: selected ? Colors.white : const Color(0xFF111827),
                      fontSize: 9,
                      fontWeight: selected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 42,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: modes.length,
            itemBuilder: (context, index) {
              final mode = modes[index];
              final selected = selectedMode == mode;
              return GestureDetector(
                onTap: () => setState(() => selectedMode = mode),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? diuGreen : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: selected ? diuGreen : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Text(
                    mode,
                    style: TextStyle(
                      color: selected ? Colors.white : const Color(0xFF111827),
                      fontSize: 9,
                      fontWeight: selected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: getTuitionStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: diuBlue),
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
                          'Could not load tuition',
                          style: TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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
              final docs = snapshot.data?.docs ?? [];
              final filtered = filterTuition(docs);

              if (filtered.isEmpty) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.school_outlined,
                          color: diuGray,
                          size: 58,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No tuition posts available',
                          style: TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Be the first tutor to offer tuition.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: diuGray, fontSize: 11),
                        ),
                        const SizedBox(height: 15),
                        // Removed button; FAB handles it
                      ],
                    ),
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 25),
                itemCount: filtered.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: .67,
                ),
                itemBuilder: (context, index) {
                  return tutorCard(context, filtered[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
