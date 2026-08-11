import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'seller_dashboard.dart';

const Color diuBlue = Color(0xFF034EA2);
const Color diuGreen = Color(0xFF39B54A);
const Color diuGray = Color(0xFF636466);
const Color backgroundColor = Color(0xFFF6F8FB);

class BecomeSellerScreen extends StatefulWidget {
  const BecomeSellerScreen({super.key});

  @override
  State<BecomeSellerScreen> createState() => _BecomeSellerScreenState();
}

class _BecomeSellerScreenState extends State<BecomeSellerScreen> {
  bool isLoading = false;

  Future<void> becomeSeller() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showMessage('Please login first.', Colors.red);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'isSeller': true},
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showMessage('You are now a seller! 🎉', diuGreen);

      await Future.delayed(const Duration(milliseconds: 700));

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SellerDashboard()),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showMessage('Could not activate seller account.', Colors.red);
    }
  }

  void showMessage(String message, Color color) {
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
          'Become a Seller',
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
              constraints: const BoxConstraints(maxWidth: 600),

              child: Column(
                children: [
                  const SizedBox(height: 15),

                  // =================================================
                  // HERO
                  // =================================================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),

                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [diuBlue, Color(0xFF1769C2)],

                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),

                      borderRadius: BorderRadius.circular(25),
                    ),

                    child: Column(
                      children: [
                        Container(
                          width: 82,
                          height: 82,

                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),

                            shape: BoxShape.circle,
                          ),

                          child: const Icon(
                            Icons.storefront_rounded,
                            color: Colors.white,
                            size: 45,
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          'Start Selling on CampusMart',

                          textAlign: TextAlign.center,

                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          'Turn your products into opportunities and reach students across DIU.',

                          textAlign: TextAlign.center,

                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // =================================================
                  // BENEFITS
                  // =================================================
                  const Align(
                    alignment: Alignment.centerLeft,

                    child: Text(
                      'Why become a seller?',

                      style: TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  benefitCard(
                    icon: Icons.people_alt_outlined,
                    title: 'Reach DIU Students',
                    description:
                        'Showcase your products to students across the campus.',
                    color: diuBlue,
                  ),

                  benefitCard(
                    icon: Icons.add_business_outlined,
                    title: 'Easy Product Listing',
                    description: 'Upload and manage your products directly from the app.',
                    color: diuGreen,
                  ),

                  benefitCard(
                    icon: Icons.trending_up_rounded,
                    title: 'Grow Your Business',
                    description: 'Build your seller profile and grow your customer base.',
                    color: const Color(0xFFF59E0B),
                  ),

                  benefitCard(
                    icon: Icons.verified_outlined,
                    title: 'DIU Student Marketplace',
                    description:
                        'Sell within a trusted student-focused marketplace.',
                    color: diuBlue,
                  ),

                  const SizedBox(height: 15),

                  // =================================================
                  // INFORMATION
                  // =================================================
                  Container(
                    width: double.infinity,

                    padding: const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.circular(16),

                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),

                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: diuBlue,
                          size: 22,
                        ),

                        SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            'Your buyer account will remain active. You can buy products and sell your own products using the same CampusMart account.',
                            style: TextStyle(
                              color: diuGray,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // =================================================
                  // BUTTON
                  // =================================================
                  SizedBox(
                    width: double.infinity,
                    height: 55,

                    child: ElevatedButton(
                      onPressed: isLoading ? null : becomeSeller,

                      style: ElevatedButton.styleFrom(
                        backgroundColor: diuGreen,
                        foregroundColor: Colors.white,

                        disabledBackgroundColor: diuGreen.withOpacity(0.5),

                        elevation: 0,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),

                      child: isLoading
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
                                Icon(Icons.storefront_rounded),

                                SizedBox(width: 9),

                                Text(
                                  'Become a Seller',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    'You can continue using CampusMart as a buyer.',

                    textAlign: TextAlign.center,

                    style: TextStyle(color: diuGray, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =============================================================
  // BENEFIT CARD
  // =============================================================

  Widget benefitCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      width: double.infinity,

      margin: const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),

      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,

            decoration: BoxDecoration(
              color: color.withOpacity(0.10),

              borderRadius: BorderRadius.circular(13),
            ),

            child: Icon(icon, color: color, size: 25),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  description,

                  style: const TextStyle(
                    color: diuGray,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
