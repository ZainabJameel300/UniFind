import 'package:flutter/material.dart';

class PostDetail extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? textColor;
  
  const PostDetail({
    super.key,
    required this.icon,
    required this.text,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon, 
          color: const Color(0xFFD0B1DB), 
          size: 20.0,
        ),
        const SizedBox(width: 3.0),
        Text(
          text, 
          style: TextStyle(
            fontSize: 12.0,
            color: textColor,
          ),
        ),
      ],
    );
  }
}