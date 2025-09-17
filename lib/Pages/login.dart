import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unifind/Components/my_textfield.dart';
import 'package:unifind/components/my_button.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // if success -> show SnackBar and direct to homepage
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Login Successful!",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          backgroundColor: const Color.fromARGB(255, 119, 31, 153),
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
              Icon(
                Icons.error_outline,
                color: const Color.fromARGB(255, 119, 31, 153),
              ),
              const SizedBox(width: 8),
              const Text(
                "Login Failed",
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
                backgroundColor: const Color.fromARGB(255, 119, 31, 153),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  final _formKey = GlobalKey<FormState>();

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

                  // Login Message
                  Text(
                    "Login",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
                  ),
                  SizedBox(height: 10),

                  // Welcoming Text Message
                  Text(
                    "Please fill in the details to login!",
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 20),

                  // Email TextField
                  MyTextField(
                    hintText: 'Email',
                    obscureText: false,
                    controller: emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Email cannot be empty";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 18),

                  // Password TextField
                  MyTextField(
                    hintText: 'Password',
                    obscureText: true,
                    controller: passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Password cannot be empty";
                      }
                      return null;
                    },
                  ),

                  // Forgot Password? link
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, 'forgotpasswordpage');
                          },
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: Color.fromARGB(255, 119, 31, 153),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 25),

                  // Login Button
                  MyButton(
                    text: 'Login',
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        login();
                      }
                    },
                  ),
                  SizedBox(height: 18),

                  // Don't have an account ? SignUp!
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, 'signuppage');
                          },
                          child: Text(
                            "SignUp",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(255, 119, 31, 153),
                              fontWeight: FontWeight.w500,
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
        ),
      ),
    );
  }
}
