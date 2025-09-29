import 'package:flutter/material.dart';

class ReportItemTextfield extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final double height;

  const ReportItemTextfield({
    super.key,
    required this.hintText,
    required this.obscureText,
    required this.controller,
    this.validator,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFF771F98), width: 2.5),
          borderRadius: BorderRadius.circular(25),
        ),
        height: height,
        width: 380,
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 10),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            expands: true,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
            ),
            validator: validator,
          ),
        ),
      ),
    );
  }
}
