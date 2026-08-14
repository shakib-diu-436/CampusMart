import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'offer_service_screen.dart';

const Color diuBlue = Color(0xFF034EA2);
const Color diuGreen = Color(0xFF39B54A);
const Color diuGray = Color(0xFF636466);
const Color campusBg = Color(0xFFF6F8FB);

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Skill & Services'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OfferServiceScreen()),
              );
            },
            icon: const Icon(Icons.add_business_rounded, color: diuBlue),
          ),
        ],
      ),
      body: const ServicesBody(),
    );
  }
}

class ServicesBody extends StatefulWidget {
  const ServicesBody({super.key});

  @override
  State<ServicesBody> createState() => _ServicesBodyState();
}

class _ServicesBodyState extends State<ServicesBody> {
  final TextEditingController searchController = TextEditingController();
  String selectedCategory = 'All';

  final List<String> categories = [
    'All',
    'Programming',
    'Graphic Design',
    'Video Editing',
    'Writing',
    'Photography',
    'Marketing',
    'Data Entry',
    'Others',
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getServicesStream() {
    return FirebaseFirestore.instance
        .collection('services')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> filterServices(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final search = searchController.text.trim().toLowerCase();
    return docs.where((doc) {
      final data = doc.data();
      final title = data['title']?.toString().toLowerCase() ?? '';
      final provider = data['providerName']?.toString().toLowerCase() ?? '';
      final category = data['category']?.toString().toLowerCase() ?? '';

      if (selectedCategory != 'All' &&
          category != selectedCategory.toLowerCase()) {
        return false;
      }

      if (search.isNotEmpty) {
        return title.contains(search) ||
            provider.contains(search) ||
            category.contains(search);
      }

      return true;
    }).toList();
  }

  IconData categoryIcon(String category) {
    switch (category) {
      case 'Programming':
        return Icons.code_rounded;
      case 'Graphic Design':
        return Icons.design_services_rounded;
      case 'Video Editing':
        return Icons.video_library_rounded;
      case 'Writing':
        return Icons.edit_note_rounded;
      case 'Photography':
        return Icons.camera_alt_rounded;
      case 'Marketing':
        return Icons.campaign_rounded;
      case 'Data Entry':
        return Icons.keyboard_rounded;
      default:
        return Icons.handyman_rounded;
    }
  }

  Widget serviceCard(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final title = data['title']?.toString() ?? 'Untitled Service';
    final provider = data['providerName']?.toString() ?? 'CampusMart Student';
    final category = data['category']?.toString() ?? 'Others';
    final description = data['description']?.toString() ?? '';
    final imageUrl = data['imageUrl']?.toString() ?? '';
    final price = data['price'] ?? 0;
    final priceType = data['priceType']?.toString() ?? 'Fixed';

    return InkWell(
      onTap: () {
        _showServiceDetails(context, data);
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
              height: 125,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: imageUrl.isEmpty
                    ? Container(
                        color: const Color(0xFFEAF2FB),
                        child: Icon(
                          categoryIcon(category),
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
                            child: Icon(
                              categoryIcon(category),
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
                        category,
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
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
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
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline_rounded,
                          color: diuGray,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            provider,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: diuGray, fontSize: 9),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '৳$price',
                          style: const TextStyle(
                            color: diuBlue,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          priceType,
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

  void _showServiceDetails(BuildContext context, Map<String, dynamic> data) {
    final title = data['title']?.toString() ?? 'Service';
    final provider = data['providerName']?.toString() ?? 'Student';
    final category = data['category']?.toString() ?? 'Others';
    final description =
        data['description']?.toString() ?? 'No description available.';
    final price = data['price'] ?? 0;
    final priceType = data['priceType']?.toString() ?? 'Fixed';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
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
                const SizedBox(height: 22),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline_rounded,
                      color: diuBlue,
                      size: 18,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      provider,
                      style: const TextStyle(
                        color: diuGray,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF2FB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      color: diuBlue,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'About this service',
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
                Row(
                  children: [
                    const Text(
                      'Starting from',
                      style: TextStyle(color: diuGray, fontSize: 11),
                    ),
                    const Spacer(),
                    Text(
                      '৳$price',
                      style: const TextStyle(
                        color: diuBlue,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '/ $priceType',
                      style: const TextStyle(color: diuGray, fontSize: 9),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
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
                              'Request for "$title" will be connected next.',
                            ),
                            backgroundColor: diuBlue,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                    },
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text('Request / Hire'),
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
              hintText: 'Search skills or services...',
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
                onTap: () => setState(() => selectedCategory = category),
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
                  child: Row(
                    children: [
                      Icon(
                        categoryIcon(category),
                        size: 15,
                        color: selected ? Colors.white : diuBlue,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        category,
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : const Color(0xFF111827),
                          fontSize: 9,
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: getServicesStream(),
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
                          'Could not load services',
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
              final filtered = filterServices(docs);

              if (filtered.isEmpty) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.handyman_outlined,
                          color: diuGray,
                          size: 55,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No services available',
                          style: TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Be the first student to offer a service.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: diuGray, fontSize: 11),
                        ),
                        const SizedBox(height: 18),
                        // Removed the button because FAB handles it
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
                  childAspectRatio: .66,
                ),
                itemBuilder: (context, index) {
                  return serviceCard(context, filtered[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
