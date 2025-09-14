import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final void Function()? onTap;

  const MyButton({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(320, 60),
        backgroundColor: const Color.fromARGB(255, 119, 31, 153),
        foregroundColor: Colors.white,
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w500),
      ),
    );
  }
}
