import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unifind/components/post_detail.dart';
import 'package:unifind/pages/chat_page.dart';
import '../helpers/timestamp_format.dart';

class Post extends StatelessWidget {
  final bool isCurrentUser;
  final String publisherAvatar;
  final String publisherName;
  final String publisherID;
  final DateTime createdAt;
  final String pic;
  final String title;
  final String description;
  final Timestamp date; // <-- lost date from Firestore
  final String location;
  final bool status;

  const Post({
    super.key,
    required this.isCurrentUser,
    required this.publisherAvatar,
    required this.publisherName,
    required this.publisherID,
    required this.createdAt,
    required this.pic,
    required this.title,
    required this.description,
    required this.date, // <-- Timestamp
    required this.location,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final name = isCurrentUser ? "You" : publisherName;
    final statusText = status ? "Claimed" : "Unclaimed";
    final statusColor = status ? Colors.green[700] : Colors.red[700];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFF771F98), width: 1.5),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                buildAvatar(publisherAvatar),
                const SizedBox(width: 8.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    Text(
                      TimestampFormat.getFormat(createdAt),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12.0),
                    ),
                  ],
                ),
                const Spacer(),
                if (!isCurrentUser)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ChatPage(receiverID: publisherID),
                        ),
                      );
                    },
                    child: Row(
                      children: const [
                        Icon(
                          Icons.chat_bubble,
                          color: Color(0xFFD0B1DB),
                          size: 20.0,
                        ),
                        SizedBox(width: 3),
                        Text("Chat", style: TextStyle(fontSize: 13.0)),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12.0),
            Divider(color: Colors.grey[500], thickness: 1, height: 1),

            // Image
            if (pic.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    pic,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 180,
                  ),
                ),
              ),

            const SizedBox(height: 12.0),

            // Title
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15.0,
              ),
            ),

            const SizedBox(height: 5.0),

            // Description
            Text(description, style: const TextStyle(fontSize: 13.0)),

            // Details Row
            Padding(
              padding: const EdgeInsets.only(
                top: 15,
                right: 10,
                left: 10,
                bottom: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Lost date
                  PostDetail(
                    icon: Icons.calendar_today_outlined,
                    text: TimestampFormat.formatLostDate(
                      date,
                    ), // <-- formatted Timestamp
                  ),

                  // Location
                  PostDetail(icon: Icons.location_on_outlined, text: location),

                  // Status
                  PostDetail(
                    icon: Icons.task_alt_outlined,
                    text: statusText,
                    textColor: statusColor,
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

// Avatar helper
Widget buildAvatar(String avatar) {
  if (avatar.isNotEmpty) {
    return CircleAvatar(radius: 24, backgroundImage: NetworkImage(avatar));
  } else {
    return const Icon(Icons.account_circle, size: 40, color: Colors.grey);
  }
}
