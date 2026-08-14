import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'add_student_product_screen.dart';
import 'student_product_details_screen.dart';

const Color diuBlue = Color(0xFF034EA2);
const Color diuGreen = Color(0xFF39B54A);
const Color diuGray = Color(0xFF636466);
const Color campusBg = Color(0xFFF6F8FB);

class StudentListingScreen extends StatelessWidget {
  const StudentListingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: campusBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Student Marketplace',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddStudentProductScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add_box_rounded, color: diuBlue),
          ),
        ],
      ),
      body: const StudentListingBody(),
    );
  }
}

class StudentListingBody extends StatefulWidget {
  const StudentListingBody({super.key});

  @override
  State<StudentListingBody> createState() => _StudentListingBodyState();
}

class _StudentListingBodyState extends State<StudentListingBody> {
  final TextEditingController searchController = TextEditingController();
  String selectedCategory = 'All';
  String selectedCondition = 'All';

  final List<String> categories = [
    'All',
    'Books',
    'Electronics',
    'Clothing',
    'Furniture',
    'Sports',
    'Stationery',
    'Others',
  ];

  final List<String> conditions = [
    'All',
    'New',
    'Used - Like New',
    'Used - Good',
    'Used - Fair',
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getStudentProducts() {
    return FirebaseFirestore.instance
        .collection('student_products')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> filterProducts(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final search = searchController.text.trim().toLowerCase();
    return docs.where((doc) {
      final data = doc.data();
      final title = data['title']?.toString().toLowerCase() ?? '';
      final student = data['studentName']?.toString().toLowerCase() ?? '';
      final category = data['category']?.toString().toLowerCase() ?? '';
      final condition = data['condition']?.toString() ?? '';

      if (selectedCategory != 'All' &&
          category != selectedCategory.toLowerCase()) {
        return false;
      }
      if (selectedCondition != 'All' && condition != selectedCondition) {
        return false;
      }

      if (search.isNotEmpty) {
        return title.contains(search) ||
            student.contains(search) ||
            category.contains(search);
      }
      return true;
    }).toList();
  }

  Widget _studentProductCard(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final title = data['title']?.toString() ?? 'Untitled';
    final student = data['studentName']?.toString() ?? 'Student';
    final price = data['price'] ?? 0;
    final imageUrl = data['imageUrl']?.toString() ?? '';
    final condition = data['condition']?.toString() ?? 'Used';
    final category = data['category']?.toString() ?? 'Others';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StudentProductDetailsScreen(
              productId: doc.id,
              productData: data,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 110,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: imageUrl.isEmpty
                    ? Container(
                        color: const Color(0xFFF5F5F5),
                        child: const Icon(
                          Icons.image_outlined,
                          color: diuGray,
                          size: 42,
                        ),
                      )
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFFF5F5F5),
                            child: const Icon(
                              Icons.broken_image_outlined,
                              color: diuGray,
                              size: 42,
                            ),
                          );
                        },
                      ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF111827),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      student,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: diuGray, fontSize: 9),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: condition == 'New'
                            ? diuGreen.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        condition,
                        style: TextStyle(
                          color: condition == 'New' ? diuGreen : Colors.orange,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '৳$price',
                      style: const TextStyle(
                        color: diuBlue,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
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
              hintText: 'Search items, students...',
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
                        size: 18,
                        color: diuGray,
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
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final selected = selectedCategory == category;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCategory = category;
                  });
                },
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
                    category,
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
        SizedBox(
          height: 42,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: conditions.length,
            itemBuilder: (context, index) {
              final condition = conditions[index];
              final selected = selectedCondition == condition;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCondition = condition;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFFF57C00) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFFF57C00)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Text(
                    condition,
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
            stream: getStudentProducts(),
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
                          'Could not load student listings',
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
              final filtered = filterProducts(docs);

              if (filtered.isEmpty) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.recycling_rounded,
                          color: diuGray,
                          size: 55,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No student listings found',
                          style: TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Be the first student to list an item.',
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
                  childAspectRatio: .7,
                ),
                itemBuilder: (context, index) {
                  return _studentProductCard(context, filtered[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
