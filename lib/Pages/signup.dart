import 'package:flutter/material.dart';
import 'package:unifind/Components/my_button.dart';
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

  final _formKey = GlobalKey<FormState>();

  // UOB email validator method
  bool _isUobEmail(String email) {
    final regex = RegExp(
      r'^(20(1[0-9]|2[0-5]))\d{5}@((stu\.uob\.edu\.bh)|(uob\.edu\.bh))$',
    );
    return regex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 239, 239, 239),
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
                      if (value.length > 20) {
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
                  SizedBox(height: 18),

                  // Password TextFiled
                  MyTextField(
                    hintText: 'Password',
                    obscureText: true,
                    controller: passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Password cannot be empty";
                      }
                      if (value.length < 8) {
                        return "Password must be at least 8 characters";
                      }
                      return null;
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
                        print("Signing up with:");
                        print("Username: ${usernameController.text}");
                        print("Email: ${emailController.text}");
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
