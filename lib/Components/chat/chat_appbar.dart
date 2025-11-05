import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:unifind/Components/user_avatar.dart';

AppBar chatAppBar(BuildContext context, String name, String avatarUrl) {
  return AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Symbols.arrow_back, color: Colors.black),
      onPressed: () => Navigator.pop(context),
    ),
    titleSpacing: 0,
    title: Row(
      children: [
        UserAvatar(avatarUrl: avatarUrl, radius: 20),
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