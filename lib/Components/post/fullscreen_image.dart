import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_view/photo_view.dart';

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PhotoView(
            imageProvider: NetworkImage(imageUrl),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            maxScale: PhotoViewComputedScale.covered * 3,
          ),

          // close button
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Symbols.close, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
