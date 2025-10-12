import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String text;
  final void Function()? onTap;

  const AppButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 60), 
        backgroundColor: const Color(0xFF771F98),
        foregroundColor: Colors.white,
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }
}
