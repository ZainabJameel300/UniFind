import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:unifind/components/my_button.dart';
import 'package:unifind/Components/my_textfield.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpasswordController =
      TextEditingController();

  String password = ""; // For password strenght indicator

  int _passwordScore(String password) {
    int score = 0;
    if (password.length >= 8) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'\d'))) score++;
    if (password.contains(RegExp(r'[@$!%*?&._-]'))) score++;
    return score; // returns 0–5
  }

  Color _strengthColor(int score) {
    if (score <= 2) return Colors.red; // weak
    if (score == 3) return const Color.fromARGB(255, 243, 119, 81); // medium
    return Colors.green; // strong
  }

  String _strengthLabel(int score) {
    if (score <= 2) return "Weak";
    if (score == 3) return "Medium";
    return "Strong";
  }

  bool obscureText = true;

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmpasswordController.dispose();
    super.dispose();
  }

  Future<void> signUp() async {
    try {
      //create the user
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      // Add user details to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'uid': userCredential.user!.uid,
            'username': usernameController.text.trim(),
            'email': emailController.text.trim(),
            'avatar': '', // Set later
          });

      // if Success then show SnackBar and navigate to homepage
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Account created successfully!",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          backgroundColor: const Color(0xFF771F98),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      Navigator.pushReplacementNamed(context, 'bottomnavBar');

      //if there's an error show the diaoulge box
    } on FirebaseAuthException catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Symbols.error_outline, color: const Color(0xFF771F98)),
              const SizedBox(width: 8),
              const Text(
                "Sign Up Failed",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            "Error: ${e.code}",
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF771F98),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  } // end of SignUp method

  final _formKey = GlobalKey<FormState>();

  // UOB email validator method for both students and staff/instructors
  bool _isUobEmail(String email) {
    final regex = RegExp(
      r'^((20(1[0-9]|2[0-5])\d{5}@stu\.uob\.edu\.bh)|([a-zA-Z0-9._-]+@uob\.edu\.bh))$',
      caseSensitive: false,
    );
    return regex.hasMatch(email.trim());
  }

  //This ensures that the password has:
  //  At least 8 characters
  //  At least 1 uppercase letter
  //  At least 1 lowercase letter
  //  At least 1 number
  //  At least 1 special character (!@#$%^&* etc.)

  bool _isStrongPassword(String password) {
    final regex = RegExp(
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&._-])[A-Za-z\d@$!%*?&._-]{8,}$',
    );
    return regex.hasMatch(password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Image(
                    image: AssetImage('assets/logo-small.png'),
                    height: 160,
                    width: 160,
                  ),
                  SizedBox(height: 25),

                  // Sign Up Message
                  Text(
                    "Sign Up",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
                  ),
                  SizedBox(height: 10),

                  // Welcome Text Message
                  Text(
                    "Please fill in the details to Sign Up!",
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 20),

                  // Username TextField
                  MyTextField(
                    hintText: 'Username',
                    obscureText: false,
                    controller: usernameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Username cannot be empty";
                      }
                      if (value.length > 50) {
                        return "Username cannot exceed 20 characters";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 18),

                  // Email TextField
                  MyTextField(
                    hintText: 'Email',
                    obscureText: false,
                    controller: emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Email cannot be empty";
                      }
                      if (!_isUobEmail(value)) {
                        return "Enter a valid UOB email";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 19),

                  // Password TextFiled
                  MyTextField(
                    hintText: 'Password',
                    obscureText: obscureText,
                    controller: passwordController,
                    onChanged: (value) {
                      setState(() {
                        password = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Password cannot be empty";
                      }
                      if (!_isStrongPassword(value)) {
                        return "Weak password";
                      }
                      return null;
                    },
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          obscureText = !obscureText;
                        });
                      },
                      child: Icon(
                        obscureText
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: Color(0xFF771F98),
                        size: 28,
                      ),
                    ),
                  ),
                  // Password strength indicator
                  Builder(
                    builder: (context) {
                      final score = _passwordScore(password);
                      if (password.isNotEmpty && !_isStrongPassword(password)) {
                        return Column(
                          children: [
                            const SizedBox(height: 6),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 7,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          child: LinearProgressIndicator(
                                            value: score / 5,
                                            minHeight: 6,
                                            backgroundColor:
                                                Colors.grey.shade300,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  _strengthColor(score),
                                                ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Tooltip(
                                        message:
                                            "Password must contain:\n• At least 8 characters\n• Uppercase letter (A-Z)\n• Lowercase letter (a-z)\n• Number (0-9)\n• Symbol (@, #, !, _)",
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                            221,
                                            161,
                                            159,
                                            159,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        textStyle: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                        ),
                                        child: const Icon(
                                          Icons.info_outline,
                                          size: 18,
                                          color: Color(0xFF771F98),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _strengthLabel(score),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _strengthColor(score),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  SizedBox(height: 18),

                  // Confirm Password Textfield
                  MyTextField(
                    hintText: 'Confirm Password',
                    obscureText: true,
                    controller: confirmpasswordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Confirm Password cannot be empty";
                      }
                      if (value != passwordController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 40),

                  // Sign Up Button
                  MyButton(
                    text: 'Sign Up',
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        signUp();
                      }
                    },
                  ),
                  SizedBox(height: 18),

                  // Already have an account? Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, 'loginpage');
                        },
                        child: Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 119, 31, 153),
                            fontWeight: FontWeight.w500,
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
