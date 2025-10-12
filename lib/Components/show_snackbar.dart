import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      backgroundColor: const Color(0xFF771F98),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(top: 12, left: 12, right: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      dismissDirection: DismissDirection.up,
    ),
  );
}
