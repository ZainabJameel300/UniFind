import 'package:flutter/material.dart';

AppBar chatAppBar(BuildContext context, String name, String avatarUrl) {
  return AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.black),
      onPressed: () => Navigator.pop(context),
    ),
    titleSpacing: 0,
    title: Row(
      children: [
        _buildAvatar(avatarUrl),
        const SizedBox(width: 12),
        Text(
          name,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
    bottom: const PreferredSize(
      preferredSize: Size.fromHeight(12),
      child: Divider(color: Color.fromARGB(255, 110, 110, 110), height: 1.5),
    ),
  );
}

Widget _buildAvatar(String avatar) {
  if (avatar.isNotEmpty) {
    return CircleAvatar(radius: 22, backgroundImage: NetworkImage(avatar));
  } else {
    return const Icon(Icons.account_circle, size: 22 * 2, color: Colors.grey);
  }
}
