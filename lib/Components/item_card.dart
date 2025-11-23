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
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE6E6E6), width: 1.7),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Image
            Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () {
                  if (imageUrl.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FullScreenImage(imageUrl: imageUrl),
                      ),
                    );
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          width: double.infinity,
                          height: 130,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          "assets/no-pictures.png",
                          width: double.infinity,
                          height: 130,
                          fit: BoxFit.cover,
                          color: Colors.grey[200],
                        ),
                ),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.only(left: 12),
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

            SizedBox(height: 4),

            // Created at
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  Icon(
                    Symbols.calendar_today,
                    size: 16,
                    color: const Color(0xFF9B7FBF),
                  ),
                  SizedBox(width: 4),
                  Text(
                    "Reported: ",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  Flexible(
                    child: Text(
                      date,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4),

            // Status
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  Icon(Symbols.task_alt, size: 16, color: const Color(0xFF9B7FBF)),
                  SizedBox(width: 4),
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
            SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
