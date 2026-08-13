import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'register_screen.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const CampusMartApp());
}

// ============================================================
// COLORS
// ============================================================

const Color diuBlue = Color(0xFF034EA2);
const Color diuGreen = Color(0xFF39B54A);
const Color diuGray = Color(0xFF636466);

const Color backgroundColor = Color(0xFFF6F8FB);
const Color lightBlue = Color(0xFFEAF2FB);
const Color lightGreen = Color(0xFFEEF9F0);

// ============================================================
// APP
// ============================================================

class CampusMartApp extends StatelessWidget {
  const CampusMartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'CampusMart DIU',

      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(seedColor: diuBlue),

        scaffoldBackgroundColor: backgroundColor,

        fontFamily: 'Arial',
      ),

      // ==========================================================
      // ROUTES
      // ==========================================================
      routes: {'/login': (_) => const LoginScreen()},

      // ==========================================================
      // INITIAL SCREEN
      // ==========================================================
      home: const LoginScreen(),
    );
  }
}

// ============================================================
// LOGIN SCREEN
// ============================================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool obscurePassword = true;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ==========================================================
  // LOGIN
  // ==========================================================

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showMessage('Please enter your DIU email and password.', Colors.orange);
      return;
    }

    if (!email.toLowerCase().endsWith('@diu.edu.bd')) {
      showMessage('Please use your DIU email address.', Colors.red);
      return;
    }

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user == null) return;

      await user.reload();

      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null && currentUser.emailVerified) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                HomeScreen(userName: currentUser.displayName ?? 'Student'),
          ),
        );

        // Home Screen will be added later.
      } else {
        await FirebaseAuth.instance.signOut();

        showMessage(
          'Please verify your DIU email before logging in.',
          Colors.orange,
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'user-not-found':
          message = 'No account found with this email.';
          break;

        case 'wrong-password':
        case 'invalid-credential':
          message = 'Incorrect email or password.';
          break;

        case 'invalid-email':
          message = 'Please enter a valid DIU email.';
          break;

        case 'user-disabled':
          message = 'This account has been disabled.';
          break;

        default:
          message = 'Login failed. Please try again.';
      }

      showMessage(message, Colors.red);
    }
  }

  void showMessage(String message, Color color) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 30, 24, 30),

            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),

              child: Column(
                children: [
                  // =================================================
                  // LOGO
                  // =================================================

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      Container(
                        width: 68,
                        height: 68,

                        decoration: BoxDecoration(
                          color: diuBlue,
                          borderRadius: BorderRadius.circular(19),

                          boxShadow: [
                            BoxShadow(
                              color: diuBlue.withOpacity(0.20),
                              blurRadius: 16,
                              offset: const Offset(0, 7),
                            ),
                          ],
                        ),

                        child: const Icon(
                          Icons.shopping_bag_rounded,
                          color: Colors.white,
                          size: 38,
                        ),
                      ),

                      const SizedBox(width: 14),

                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'CampusMart ',
                              style: TextStyle(
                                color: Color(0xFF111827),
                                fontSize: 29,
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            TextSpan(
                              text: 'DIU',
                              style: TextStyle(
                                color: diuBlue,
                                fontSize: 29,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    'Welcome back! Please login to\n'
                    'continue to CampusMart DIU',

                    textAlign: TextAlign.center,

                    style: TextStyle(color: diuGray, fontSize: 16, height: 1.5),
                  ),

                  const SizedBox(height: 28),

                  // =================================================
                  // ILLUSTRATION
                  // =================================================
                  Container(
                    height: 205,
                    width: double.infinity,

                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,

                        colors: [Color(0xFFEAF4FC), Color(0xFFF0F8F1)],
                      ),

                      borderRadius: BorderRadius.circular(24),

                      border: Border.all(color: Colors.white, width: 2),
                    ),

                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),

                      child: Stack(
                        children: [
                          // Sun
                          Positioned(
                            top: 22,
                            right: 35,

                            child: Container(
                              width: 42,
                              height: 42,

                              decoration: const BoxDecoration(
                                color: Color(0xFFFFD76A),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),

                          // Cloud
                          Positioned(
                            top: 40,
                            left: 28,

                            child: Container(
                              width: 70,
                              height: 22,

                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),

                          // Left tree
                          Positioned(
                            bottom: 30,
                            left: 20,

                            child: const TreeWidget(size: 50),
                          ),

                          // Right tree
                          Positioned(
                            bottom: 30,
                            right: 20,

                            child: const TreeWidget(size: 55),
                          ),

                          // DIU building
                          Positioned(
                            bottom: 30,
                            left: 80,
                            right: 80,

                            child: Column(
                              children: [
                                ClipPath(
                                  clipper: RoofClipper(),

                                  child: Container(height: 35, color: diuBlue),
                                ),

                                Container(
                                  height: 82,

                                  color: Colors.white,

                                  child: Column(
                                    children: [
                                      const SizedBox(height: 7),

                                      const Text(
                                        'DIU',

                                        style: TextStyle(
                                          color: diuBlue,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 7),

                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,

                                        children: [
                                          buildingWindow(),
                                          buildingWindow(),
                                          buildingWindow(),
                                          buildingWindow(),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Students
                          Positioned(
                            bottom: 12,
                            left: 65,

                            child: const StudentWidget(shirtColor: diuBlue),
                          ),

                          Positioned(
                            bottom: 10,
                            left: 150,

                            child: const StudentWidget(shirtColor: diuGreen),
                          ),

                          Positioned(
                            bottom: 12,
                            right: 65,

                            child: const StudentWidget(
                              shirtColor: Color(0xFFF1A43C),
                            ),
                          ),

                          // Ground
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,

                            child: Container(height: 12, color: diuGreen),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // =================================================
                  // LOGIN CARD
                  // =================================================
                  Container(
                    width: double.infinity,

                    padding: const EdgeInsets.all(22),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.circular(22),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        const Text(
                          'Login to your account',

                          style: TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        const Text(
                          'Use your verified DIU account',

                          style: TextStyle(color: diuGray, fontSize: 14),
                        ),

                        const SizedBox(height: 22),

                        // Email
                        const Text(
                          'DIU Email',

                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 8),

                        TextField(
                          controller: emailController,

                          keyboardType: TextInputType.emailAddress,

                          decoration: inputDecoration(
                            hint: 'student@diu.edu.bd',
                            icon: Icons.email_outlined,
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Password
                        const Text(
                          'Password',

                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 8),

                        TextField(
                          controller: passwordController,

                          obscureText: obscurePassword,

                          decoration: inputDecoration(
                            hint: 'Enter your password',

                            icon: Icons.lock_outline,

                            suffix: IconButton(
                              onPressed: () {
                                setState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },

                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 4),

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,

                          child: TextButton(
                            onPressed: () {},

                            child: const Text(
                              'Forgot Password?',

                              style: TextStyle(
                                color: diuBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 7),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 54,

                          child: ElevatedButton(
                            onPressed: login,

                            style: ElevatedButton.styleFrom(
                              backgroundColor: diuBlue,

                              foregroundColor: Colors.white,

                              elevation: 0,

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13),
                              ),
                            ),

                            child: const Text(
                              'Login',

                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Verification
                        Container(
                          width: double.infinity,

                          padding: const EdgeInsets.all(14),

                          decoration: BoxDecoration(
                            color: lightGreen,

                            borderRadius: BorderRadius.circular(13),

                            border: Border.all(
                              color: diuGreen.withOpacity(0.25),
                            ),
                          ),

                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Icon(
                                Icons.verified_user_outlined,
                                color: diuGreen,
                                size: 23,
                              ),

                              SizedBox(width: 10),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Text(
                                      'Secure & Verified',

                                      style: TextStyle(
                                        color: Color(0xFF218739),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),

                                    SizedBox(height: 4),

                                    Text(
                                      'Only verified DIU students can access CampusMart DIU.',

                                      style: TextStyle(
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
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Register
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      const Text(
                        "Don't have an account? ",

                        style: TextStyle(color: diuGray, fontSize: 14),
                      ),

                      MouseRegion(
                        cursor: SystemMouseCursors.click,

                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },

                          child: const Text(
                            'Register',

                            style: TextStyle(
                              color: diuBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// INPUT DECORATION
// ============================================================

InputDecoration inputDecoration({
  required String hint,
  required IconData icon,
  Widget? suffix,
}) {
  return InputDecoration(
    hintText: hint,

    prefixIcon: Icon(icon, color: diuGray),

    suffixIcon: suffix,

    filled: true,

    fillColor: const Color(0xFFFAFBFC),

    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),

    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),

      borderSide: const BorderSide(color: Color(0xFFDDE2E7)),
    ),

    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),

      borderSide: const BorderSide(color: Color(0xFFDDE2E7)),
    ),

    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),

      borderSide: const BorderSide(color: diuBlue, width: 1.5),
    ),
  );
}

// ============================================================
// TREE
// ============================================================

class TreeWidget extends StatelessWidget {
  final double size;

  const TreeWidget({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: size,
          height: size,

          decoration: const BoxDecoration(
            color: diuGreen,
            shape: BoxShape.circle,
          ),
        ),

        Container(width: 8, height: 28, color: const Color(0xFF8B6545)),
      ],
    );
  }
}

// ============================================================
// STUDENT
// ============================================================

class StudentWidget extends StatelessWidget {
  final Color shirtColor;

  const StudentWidget({super.key, required this.shirtColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 22,
          height: 22,

          decoration: const BoxDecoration(
            color: Color(0xFFF1B18D),
            shape: BoxShape.circle,
          ),
        ),

        Container(
          width: 30,
          height: 42,

          decoration: BoxDecoration(
            color: shirtColor,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// WINDOW
// ============================================================

Widget buildingWindow() {
  return Container(
    width: 14,
    height: 24,

    decoration: BoxDecoration(
      color: const Color(0xFF9CC9E8),

      borderRadius: BorderRadius.circular(3),

      border: Border.all(color: const Color(0xFFBBD9EC)),
    ),
  );
}

// ============================================================
// ROOF
// ============================================================

class RoofClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(0, size.height);

    path.lineTo(size.width / 2, 0);

    path.lineTo(size.width, size.height);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
