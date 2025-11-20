import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:unifind/Components/fullscreen_image.dart';
import 'package:unifind/Pages/view_post_edit.dart';

class ItemCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String date;
  final String status;
  final String postID;

  const ItemCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.date,
    required this.status,
    required this.postID,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ViewPostEdit(postID: postID)),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE6E6E6), width: 1.7),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (imageUrl.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FullScreenImage(imageUrl: imageUrl),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

            SizedBox(height: 10),

            // Title
            Center(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF771F98),
                ),
              ),
            ),

            SizedBox(height: 8),

            // Created at
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  Icon(
                    Symbols.calendar_today,
                    size: 16,
                    color: Color(0xFFD0B1DB),
                  ),
                  SizedBox(width: 6),
                  Text(
                    "Reported at: ",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    date,
                    style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),

            // Status
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  Icon(Symbols.task_alt, size: 16, color: Color(0xFFD0B1DB)),
                  SizedBox(width: 6),
                  Text(
                    "Status: ",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      color: status == "Claimed"
                          ? Colors.green
                          : Colors.red, // Not Claimed
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
