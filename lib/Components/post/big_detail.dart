import 'package:flutter/material.dart';

class BigDetail extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? textColor;

  const BigDetail({
    super.key,
    required this.icon,
    required this.text,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(7),
            child: Icon(icon, color: const Color(0xFF771F98), size: 20),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: textColor ?? Colors.grey.shade800,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget buildDetail(IconData icon, String value, {Color? valueColor}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(7),
          child: Icon(icon, color: const Color(0xFF771F98), size: 20),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: valueColor ?? Colors.grey.shade800,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
        ),
      ],
    ),
  );
}
