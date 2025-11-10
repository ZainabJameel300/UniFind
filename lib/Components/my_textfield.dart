import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? Function(String?)? validator; 
  final void Function(String)? onChanged;
  final Widget? suffixIcon;
  final bool? chatField;

  const MyTextField({
    super.key,
    required this.hintText,
    required this.obscureText,
    required this.controller,
    this.focusNode,
    this.validator,
    this.onChanged,
    this.suffixIcon,
    this.chatField,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: (chatField ?? false) 
          ? EdgeInsets.symmetric(horizontal: 10) 
          : const EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 241, 241, 241),
          border: (chatField ?? false) 
                  ? null 
                  : Border.all(color: const Color(0xFF771F98), width: 2.5),
          borderRadius: BorderRadius.circular(12),
        ),
        height: 55,
        width: 380,
        child: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscureText,
            onChanged: onChanged,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
              suffixIcon: suffixIcon,
            ),
            validator: validator, // only used if wrapped in a Form
          ),
        ),
      ),
    );
  }
}
