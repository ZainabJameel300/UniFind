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
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: const Color(0xFF9B7FBF), size: 18.0),
        const SizedBox(width: 2.0),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: textColor ?? Colors.grey[800],
              height: 1.2,
            ),
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    );
  }
}
