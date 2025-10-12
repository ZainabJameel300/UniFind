import 'package:flutter/material.dart';

class MyAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final bool showBack;
  const MyAppbar({
    super.key,
    required this.title,
    this.onBack,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: false,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: onBack ?? () => Navigator.pop(context),
            )
          : null,
      title: Text(
        title,
        style: const TextStyle(fontSize: 30, color: Colors.black),
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(20),
        child: Divider(color: Color.fromARGB(255, 110, 110, 110), height: 1.5),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}
