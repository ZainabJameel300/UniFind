import 'package:flutter/material.dart';

class MyAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;

  const MyAppbar({super.key, required this.title, this.onBack});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black),
        onPressed: onBack ?? () => Navigator.pop(context),
      ),
      title: Text(title, style: TextStyle(fontSize: 28, color: Colors.black)),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(20),
        child: Divider(color: Color.fromARGB(255, 110, 110, 110), height: 1.5),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}
