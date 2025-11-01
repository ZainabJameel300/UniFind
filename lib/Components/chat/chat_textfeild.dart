import 'package:flutter/material.dart';

class ChatTextfield extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final void Function(String) onChanged;

  const ChatTextfield({
    super.key,
    required this.hintText,
    required this.controller,
    this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 25.0, right: 10),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 241, 241, 241),
          borderRadius: BorderRadius.circular(12),
        ),
        height: 55,
        width: double.infinity,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.grey),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 14, 
            ),
          ),
        ),
      ),
    );
  }
}
