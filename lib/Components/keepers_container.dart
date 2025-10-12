import 'package:flutter/material.dart';

class KeepersContainer extends StatelessWidget {
  final String code;
  final String title;
  final Color fillColor;
  final Color borderColor;
  final Color circleColor;

  const KeepersContainer({
    super.key,
    required this.code,
    required this.title,
    required this.circleColor,
    required this.fillColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 25),
      child: Container(
        height: 55,
        width: 400,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: fillColor,
          border: Border.all(color: borderColor, width: 2.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // College Code
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                code,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 26),
            // Title text
            Text(
              title,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
