import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unifind/Pages/view_post.dart';
import 'package:unifind/utils/date_formats.dart';

class NotificationTile extends StatelessWidget {
  final String notificationID;
  final String message;
  final String matchPostID;
  final Timestamp timestamp;
  final bool isRead;

  const NotificationTile({
    super.key,
    required this.notificationID,
    required this.message,
    required this.matchPostID,
    required this.timestamp,
    required this.isRead,
  });

  Future<void> markAsReadAndNavigate(context) async {
    try {
      // mark as read 
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationID)
          .update({'isRead': true});

      // navigate to the matched post details page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ViewPost(
          postID: matchPostID
        )),
      );
      } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationDate = DateFormats.formatNotificationTime(timestamp.toDate());

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isRead
              ? Colors.grey[200]
              : const Color(0xFFEADDEF),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.notifications,
          color: isRead ? Colors.grey[600] : const Color(0xFF771F98),
          size: 22,
        ),
      ),
      title: Text(
        message,
        style: TextStyle(
          fontSize: 14.5,
          fontWeight: isRead ? FontWeight.w400 : FontWeight.w600,
          color: Colors.black,
          height: 1.3,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
             "View post to verify.",
             style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              notificationDate,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
      onTap: () => markAsReadAndNavigate(context),
    );
  }
}
