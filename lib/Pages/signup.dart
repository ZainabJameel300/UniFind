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
  bool hideRequirements = false; // to hide the password list later!

  bool obscureText = true;
  bool obscureConfirm = true;

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
                  Builder(
                    builder: (context) {
                      bool hasUpper = password.contains(RegExp(r'[A-Z]'));
                      bool hasLower = password.contains(RegExp(r'[a-z]'));
                      bool hasNumber = password.contains(RegExp(r'\d'));
                      bool hasSymbol = password.contains(
                        RegExp(r'[@$!%*?&._-]'),
                      );
                      bool isLongEnough = password.length >= 8;

                      // If nothing typed, reset and hide list
                      if (password.isEmpty) {
                        hideRequirements = false;
                        return const SizedBox.shrink();
                      }

                      // All requirements met (NUMBER AND SYMBOL)
                      bool allGood =
                          isLongEnough &&
                          hasUpper &&
                          hasLower &&
                          hasNumber &&
                          hasSymbol;

                      if (allGood) {
                        if (!hideRequirements) {
                          hideRequirements = true;

                          Future.delayed(const Duration(seconds: 10), () {
                            if (mounted) {
                              setState(() {
                                password = "";
                                hideRequirements = false;
                              });
                            }
                          });
                        }
                        return const SizedBox.shrink();
                      }

                      return Padding(
                        padding: const EdgeInsets.only(
                          top: 8,
                          left: 32,
                          right: 32,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _reqItem(
                                    "At least 8 characters",
                                    isLongEnough,
                                  ),
                                  const SizedBox(height: 6),
                                  _reqItem("Uppercase letter (A-Z)", hasUpper),
                                ],
                              ),
                            ),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _reqItem("Lowercase letter (a-z)", hasLower),
                                  const SizedBox(height: 6),
                                  _reqItem(
                                    "Number and Symbol",
                                    hasNumber && hasSymbol,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 18),

                  // Confirm Password Textfield
                  MyTextField(
                    hintText: 'Confirm Password',
                    obscureText: obscureConfirm,
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
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          obscureConfirm = !obscureConfirm;
                        });
                      },
                      child: Icon(
                        obscureConfirm
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: const Color(0xFF771F98),
                        size: 28,
                      ),
                    ),
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

Widget _reqItem(String text, bool ok) {
  return Row(
    children: [
      Icon(
        ok ? Icons.check_circle : Icons.cancel,
        size: 18,
        color: ok ? Colors.green : Colors.red,
      ),
      const SizedBox(width: 6),
      Expanded(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: ok ? Colors.green : Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ],
  );
}
