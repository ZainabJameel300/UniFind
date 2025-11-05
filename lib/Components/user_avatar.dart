import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String avatarUrl;
  final double radius;

  const UserAvatar({super.key, required this.avatarUrl, this.radius = 22});

  @override
  Widget build(BuildContext context) {
    if (avatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.transparent,
        backgroundImage: NetworkImage(avatarUrl),
      );
    } else {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.transparent,
        child: Icon(
          Icons.account_circle,
          size: radius * 2,
          color: Colors.grey,
        ),
      );
    }

  }
}
