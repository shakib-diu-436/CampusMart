import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// ================================================================
// CAMPUSMART COLORS
// ================================================================

const Color diuBlue = Color(0xFF034EA2);
const Color diuGreen = Color(0xFF39B54A);
const Color diuGray = Color(0xFF636466);
const Color campusBg = Color(0xFFF6F8FB);

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // ==============================================================
  // CONTROLLERS
  // ==============================================================

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final studentIdController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // ==============================================================
  // VARIABLES
  // ==============================================================

  String? selectedDepartment;

  bool isLoading = false;
  bool hidePassword = true;
  bool hideConfirmPassword = true;

  final List<String> departments = const [
    'Computer Science & Engineering',
    'Software Engineering',
    'Electrical & Electronic Engineering',
    'Civil Engineering',
    'Business Administration',
    'English',
    'Law',
    'Other',
  ];

  // ==============================================================
  // DISPOSE
  // ==============================================================

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    studentIdController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  // ==============================================================
  // REGISTER STUDENT
  // ==============================================================

  Future<void> registerStudent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedDepartment == null) {
      showMessage('Please select your department.', error: true);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final String name = nameController.text.trim();

      final String email = emailController.text.trim().toLowerCase();

      final String studentId = studentIdController.text.trim();

      final String phone = phoneController.text.trim();

      final String password = passwordController.text;

      // ==========================================================
      // FIREBASE AUTHENTICATION
      // ==========================================================

      final UserCredential credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final User? user = credential.user;

      if (user == null) {
        throw Exception('User account could not be created.');
      }

      // ==========================================================
      // UPDATE DISPLAY NAME
      // ==========================================================

      await user.updateDisplayName(name);

      // ==========================================================
      // SEND VERIFICATION EMAIL
      // ==========================================================

      await user.sendEmailVerification();

      // ==========================================================
      // CREATE FIRESTORE USER
      // ==========================================================

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name,
        'email': email,
        'studentId': studentId,
        'department': selectedDepartment,
        'phone': phone,
        'profileImage': '',

        // IMPORTANT:
        // One account can be buyer AND seller.
        'isBuyer': true,
        'isSeller': false,

        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // ==========================================================
      // OPEN EMAIL VERIFICATION SCREEN
      // ==========================================================

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => VerifyEmailScreen(email: email)),
      );
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already registered.';
          break;

        case 'invalid-email':
          message = 'Please enter a valid DIU email.';
          break;

        case 'weak-password':
          message = 'Password must be at least 6 characters.';
          break;

        case 'network-request-failed':
          message = 'Check your internet connection.';
          break;

        default:
          message = e.message ?? 'Registration failed. Please try again.';
      }

      if (mounted) {
        showMessage(message, error: true);
      }
    } catch (e) {
      if (mounted) {
        showMessage('Something went wrong. Please try again.', error: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ==============================================================
  // SNACKBAR
  // ==============================================================

  void showMessage(String message, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: error ? Colors.red : diuGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ==============================================================
  // FIELD DECORATION
  // ==============================================================

  InputDecoration fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,

      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF8FA0B8)),

      prefixIcon: Icon(icon, size: 19, color: Color(0xFF8CA0BA)),

      suffixIcon: suffixIcon,

      filled: true,
      fillColor: Colors.white,

      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD9E2EC)),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD9E2EC)),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: diuBlue, width: 1.4),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  // ==============================================================
  // FIELD LABEL
  // ==============================================================

  Widget fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF25344A),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: .3,
        ),
      ),
    );
  }

  // ==============================================================
  // BUILD
  // ==============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: campusBg,

      // No AppBar
      // No BottomNavigationBar
      // Registration is standalone.
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),

            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),

              child: Container(
                width: double.infinity,

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(18),

                  border: Border.all(color: const Color(0xFFE2E8F0)),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.07),
                      blurRadius: 18,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),

                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),

                  child: Column(
                    children: [
                      // =================================================
                      // HEADER
                      // =================================================

                      Container(
                        width: double.infinity,

                        padding: const EdgeInsets.symmetric(
                          vertical: 23,
                          horizontal: 20,
                        ),

                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [diuBlue, Color(0xFF0A8F8B)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),

                        child: Column(
                          children: [
                            // ICON
                            Container(
                              width: 48,
                              height: 48,

                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(.14),

                                borderRadius: BorderRadius.circular(13),

                                border: Border.all(
                                  color: Colors.white.withOpacity(.35),
                                ),
                              ),

                              child: const Icon(
                                Icons.school_outlined,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),

                            const SizedBox(height: 10),

                            // TITLE
                            const Text(
                              'Create Student Account',

                              textAlign: TextAlign.center,

                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 4),

                            const Text(
                              'Join the DIU CampusMart student community',

                              textAlign: TextAlign.center,

                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // =================================================
                      // FORM
                      // =================================================
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),

                        child: Form(
                          key: _formKey,

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              // =================================================
                              // 1. FULL NAME
                              // =================================================

                              fieldLabel('Full Name'),

                              TextFormField(
                                controller: nameController,

                                textInputAction: TextInputAction.next,

                                decoration: fieldDecoration(
                                  hint: 'e.g. Tanvir Hossain',
                                  icon: Icons.person_outline_rounded,
                                ),

                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Enter your full name';
                                  }

                                  if (value.trim().length < 3) {
                                    return 'Enter a valid name';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              // =================================================
                              // 2. DIU EMAIL
                              // =================================================
                              fieldLabel('DIU Email'),

                              TextFormField(
                                controller: emailController,

                                keyboardType: TextInputType.emailAddress,

                                textInputAction: TextInputAction.next,

                                decoration: fieldDecoration(
                                  hint: 'student@diu.edu.bd',
                                  icon: Icons.mail_outline_rounded,
                                ),

                                validator: (value) {
                                  final email =
                                      value?.trim().toLowerCase() ?? '';

                                  if (email.isEmpty) {
                                    return 'Enter your DIU email';
                                  }

                                  if (!email.endsWith('@diu.edu.bd')) {
                                    return 'Use your @diu.edu.bd email';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              // =================================================
                              // 3. STUDENT ID
                              // =================================================
                              fieldLabel('Student ID'),

                              TextFormField(
                                controller: studentIdController,

                                textInputAction: TextInputAction.next,

                                decoration: fieldDecoration(
                                  hint: 'e.g. 211-15-1234',
                                  icon: Icons.badge_outlined,
                                ),

                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Enter your student ID';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              // =================================================
                              // 4. DEPARTMENT
                              // =================================================
                              fieldLabel('Department'),

                              DropdownButtonFormField<String>(
                                value: selectedDepartment,

                                isExpanded: true,

                                decoration: fieldDecoration(
                                  hint: 'Select department',
                                  icon: Icons.business_outlined,
                                ),

                                items: departments.map((department) {
                                  return DropdownMenuItem<String>(
                                    value: department,

                                    child: Text(
                                      department,

                                      overflow: TextOverflow.ellipsis,

                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  );
                                }).toList(),

                                onChanged: (value) {
                                  setState(() {
                                    selectedDepartment = value;
                                  });
                                },

                                validator: (value) {
                                  if (value == null) {
                                    return 'Select your department';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              // =================================================
                              // 5. PHONE NUMBER
                              // =================================================
                              fieldLabel('Phone Number'),

                              TextFormField(
                                controller: phoneController,

                                keyboardType: TextInputType.phone,

                                textInputAction: TextInputAction.next,

                                decoration: fieldDecoration(
                                  hint: '01700000000',
                                  icon: Icons.phone_outlined,
                                ),

                                validator: (value) {
                                  final phone = value?.trim() ?? '';

                                  if (phone.isEmpty) {
                                    return 'Enter your phone number';
                                  }

                                  if (phone.length < 11) {
                                    return 'Enter a valid phone number';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              // =================================================
                              // 6. PASSWORD
                              // =================================================
                              fieldLabel('Password'),

                              TextFormField(
                                controller: passwordController,

                                obscureText: hidePassword,

                                textInputAction: TextInputAction.next,

                                decoration: fieldDecoration(
                                  hint: 'At least 6 characters',
                                  icon: Icons.lock_outline_rounded,

                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        hidePassword = !hidePassword;
                                      });
                                    },

                                    icon: Icon(
                                      hidePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,

                                      size: 19,

                                      color: diuGray,
                                    ),
                                  ),
                                ),

                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Enter a password';
                                  }

                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              // =================================================
                              // 7. CONFIRM PASSWORD
                              // =================================================
                              fieldLabel('Confirm Password'),

                              TextFormField(
                                controller: confirmPasswordController,

                                obscureText: hideConfirmPassword,

                                textInputAction: TextInputAction.done,

                                decoration: fieldDecoration(
                                  hint: 'Re-type password',
                                  icon: Icons.lock_outline_rounded,

                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        hideConfirmPassword =
                                            !hideConfirmPassword;
                                      });
                                    },

                                    icon: Icon(
                                      hideConfirmPassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,

                                      size: 19,

                                      color: diuGray,
                                    ),
                                  ),
                                ),

                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Confirm your password';
                                  }

                                  if (value != passwordController.text) {
                                    return 'Passwords do not match';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 14),

                              // =================================================
                              // TERMS
                              // =================================================
                              const Text(
                                'By registering, you agree to follow DIU CampusMart terms of conduct and student code.',

                                style: TextStyle(
                                  color: diuGray,
                                  fontSize: 9,
                                  height: 1.4,
                                ),
                              ),

                              const SizedBox(height: 18),

                              // =================================================
                              // REGISTER BUTTON
                              // =================================================
                              SizedBox(
                                width: double.infinity,

                                height: 48,

                                child: ElevatedButton(
                                  onPressed: isLoading ? null : registerStudent,

                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: diuGreen,

                                    foregroundColor: Colors.white,

                                    disabledBackgroundColor: diuGreen
                                        .withOpacity(.55),

                                    elevation: 2,

                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),

                                  child: isLoading
                                      ? const SizedBox(
                                          width: 21,
                                          height: 21,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,

                                          children: [
                                            Icon(
                                              Icons.person_add_alt_1_rounded,
                                              size: 17,
                                            ),

                                            SizedBox(width: 7),

                                            Text(
                                              'Register Student Account',

                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),

                              const SizedBox(height: 19),

                              // =================================================
                              // BACK TO LOGIN
                              // =================================================
                              Center(
                                child: Wrap(
                                  alignment: WrapAlignment.center,

                                  children: [
                                    const Text(
                                      'Already have a CampusMart account? ',

                                      style: TextStyle(
                                        color: diuGray,
                                        fontSize: 10,
                                      ),
                                    ),

                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },

                                      child: const Text(
                                        '← Back to Sign In',

                                        style: TextStyle(
                                          color: diuBlue,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// VERIFY EMAIL SCREEN
// ==================================================================

class VerifyEmailScreen extends StatefulWidget {
  final String email;

  const VerifyEmailScreen({super.key, required this.email});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool checking = false;
  bool resending = false;

  // ================================================================
  // CHECK VERIFICATION
  // ================================================================

  Future<void> checkVerification() async {
    setState(() {
      checking = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      await user?.reload();

      final refreshedUser = FirebaseAuth.instance.currentUser;

      if (refreshedUser != null && refreshedUser.emailVerified) {
        if (!mounted) return;

        Navigator.popUntil(context, (route) => route.isFirst);

        return;
      }

      if (mounted) {
        showMessage(
          'Email is not verified yet. Please check your inbox.',
          error: true,
        );
      }
    } catch (e) {
      if (mounted) {
        showMessage('Could not check verification status.', error: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          checking = false;
        });
      }
    }
  }

  // ================================================================
  // RESEND VERIFICATION
  // ================================================================

  Future<void> resendVerification() async {
    setState(() {
      resending = true;
    });

    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();

      if (mounted) {
        showMessage('Verification email sent again.');
      }
    } catch (e) {
      if (mounted) {
        showMessage('Could not resend verification email.', error: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          resending = false;
        });
      }
    }
  }

  // ================================================================
  // MESSAGE
  // ================================================================

  void showMessage(String message, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: error ? Colors.red : diuGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: campusBg,

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),

              child: Container(
                padding: const EdgeInsets.all(28),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(18),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.07),
                      blurRadius: 18,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),

                child: Column(
                  children: [
                    // ICON
                    Container(
                      width: 72,
                      height: 72,

                      decoration: const BoxDecoration(
                        color: Color(0xFFEAF2FB),
                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.mark_email_read_outlined,
                        color: diuBlue,
                        size: 40,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Verify Your DIU Email',

                      textAlign: TextAlign.center,

                      style: TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 9),

                    const Text(
                      'We sent a verification link to:',

                      textAlign: TextAlign.center,

                      style: TextStyle(color: diuGray, fontSize: 13),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      widget.email,

                      textAlign: TextAlign.center,

                      style: const TextStyle(
                        color: diuBlue,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 23),

                    // CHECK
                    SizedBox(
                      width: double.infinity,

                      height: 48,

                      child: ElevatedButton(
                        onPressed: checking ? null : checkVerification,

                        style: ElevatedButton.styleFrom(
                          backgroundColor: diuBlue,

                          foregroundColor: Colors.white,

                          elevation: 0,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),

                        child: checking
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('I Have Verified My Email'),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // RESEND
                    SizedBox(
                      width: double.infinity,

                      height: 48,

                      child: OutlinedButton(
                        onPressed: resending ? null : resendVerification,

                        style: OutlinedButton.styleFrom(
                          foregroundColor: diuBlue,

                          side: const BorderSide(color: diuBlue),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),

                        child: resending
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: diuBlue,
                                ),
                              )
                            : const Text('Resend Verification Email'),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // DIFFERENT EMAIL
                    TextButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();

                        if (!context.mounted) return;

                        Navigator.pop(context);
                      },

                      child: const Text(
                        'Use a different email',

                        style: TextStyle(color: diuGray),
                      ),
                    ),
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
