import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:unifind/Components/app_button.dart';
import 'package:unifind/Components/my_appbar.dart';
import 'package:unifind/Components/my_textfield.dart';

class Forgotpassword extends StatefulWidget {
  const Forgotpassword({super.key});

  @override
  State<Forgotpassword> createState() => _ForgotpasswordState();
}

class _ForgotpasswordState extends State<Forgotpassword> {
  final TextEditingController emialcontroller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emialcontroller.dispose();
    super.dispose();
  }

  // UOB email validator method
  bool _isUobEmail(String email) {
    final regex = RegExp(
      r'^(20(1[0-9]|2[0-5]))\d{5}@((stu\.uob\.edu\.bh)|(uob\.edu\.bh))$',
    );
    return regex.hasMatch(email);
  }

  //password reset function
  Future passwordReset() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emialcontroller.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Password reset link sent! Check your email.",
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

      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacementNamed(context, 'loginpage');
      });

      //if there is an error it will display it in a diaoulg box
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
                Symbols.error_outline,
                color: const Color.fromARGB(255, 119, 31, 153),
              ),
              const SizedBox(width: 8),
              const Text(
                "Reset Failed",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            "Error: ${e.message}",
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
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MyAppbar(title: "Forgot Password"),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),

            //Enter Email Text
            const Padding(
              padding: EdgeInsets.only(left: 25),
              child: Text(
                "Enter Email:",
                style: TextStyle(
                  fontSize: 20,
                  // fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 15),

            //Email Textfield
            MyTextField(
              hintText: '',
              obscureText: false,
              controller: emialcontroller,
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
            const SizedBox(height: 50),

            // Reset Link Button
            Center(
              child: SizedBox(
                width: 180,
                child: AppButton(
                  text: "Send Reset Link",
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      passwordReset();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
