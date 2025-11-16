import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';

class ImageBottomSheet {
  static Future<File?> show({
    required BuildContext context,
    required String title,
    bool showDelete = false,
    VoidCallback? onDelete,
  }) async {
    final ImagePicker picker = ImagePicker();

    //based on if the showdelete is true or not the sheet will resize
    final sheetHeight = showDelete
        ? MediaQuery.of(context).size.height * 0.35
        : MediaQuery.of(context).size.height * 0.30;

    return await showModalBottomSheet<File?>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return SizedBox(
          height: sheetHeight,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 10,
            ),
            child: Column(
              children: [
                //little grey bar at the top
                Center(
                  child: Container(
                    width: 60,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 25),
                // X for exiting the sheet and title
                Row(
                  children: [
                    // close button
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 28,
                        color: Colors.black87,
                      ),
                      onPressed: () => Navigator.pop(context, null),
                    ),

                    SizedBox(width: 80),

                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                // Camera option
                _bottomOption(
                  icon: Symbols.photo_camera,
                  label: "Camera",
                  onTap: () async {
                    final picked = await picker.pickImage(
                      source: ImageSource.camera,
                      maxWidth: 800,
                      maxHeight: 800,
                    );
                    if (picked != null)
                      Navigator.pop(context, File(picked.path));
                  },
                ),

                const SizedBox(height: 14),

                // Gallery OPTION
                _bottomOption(
                  icon: Symbols.image,
                  label: "Gallery",
                  onTap: () async {
                    final picked = await picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 800,
                      maxHeight: 800,
                    );
                    if (picked != null)
                      Navigator.pop(context, File(picked.path));
                  },
                ),

                const SizedBox(height: 14),

                if (showDelete)
                  _bottomOption(
                    icon: Symbols.delete,
                    label: "Delete Image",
                    onTap: () {
                      Navigator.pop(context, null);
                      if (onDelete != null) onDelete();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _bottomOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 55,

        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          children: [
            Icon(icon, color: Color(0xFF771F98), size: 26),
            const SizedBox(width: 18),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
