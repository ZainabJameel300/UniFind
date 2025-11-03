import 'package:flutter/material.dart';

class BadgeIcon extends StatelessWidget {
  final Stream<int> badgeStream;
  final Icon icon;

  const BadgeIcon({
    super.key,
    required this.badgeStream,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: badgeStream,
      builder: (context, snapshot) {
        final int count = snapshot.data ?? 0;

        return Badge(
          backgroundColor: Colors.transparent,
          // backgroundColor: const Color(0xFF771F98),
          label: Container(
            padding: const EdgeInsets.all(2), 
            decoration: const BoxDecoration(
              color: Color(0xFFF1F1F1),
              shape: BoxShape.circle,
            ),
            child: Container(
              padding: const EdgeInsets.all(4), 
              decoration: BoxDecoration(
                color: Color(0xFF771F98).withAlpha(220),
                shape: BoxShape.circle,
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          isLabelVisible: count > 0,
          offset: const Offset(0, -3),
          child: icon,
        );
      }
    );
  }
}