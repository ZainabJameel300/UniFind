import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String avatarUrl;
  final double radius;

  const UserAvatar({
    super.key, 
    required this.avatarUrl, 
    required this.radius
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[350],
      backgroundImage: avatarUrl.isNotEmpty
          ? NetworkImage(avatarUrl)
          : const AssetImage('assets/default_avatar.png'),
    );
  }
}

