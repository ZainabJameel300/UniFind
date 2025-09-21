import 'package:flutter/material.dart';

class MyDrawerButton extends StatelessWidget {
  final String text;
  final void Function()? onTap;

  const MyDrawerButton({
    super.key, 
    required this.text, 
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    bool secondery = text == "Clear";
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        side: secondery
            ? BorderSide(color: Colors.grey.shade400, width: 1.5)
            : BorderSide.none,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero, ),
        backgroundColor: secondery ? Colors.white : const Color.fromARGB(255, 119, 31, 153),
        foregroundColor: secondery ? Colors.grey[800] : Colors.white,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: secondery ? FontWeight.normal : FontWeight.bold,
        ),
      ),
    );
  }
}
