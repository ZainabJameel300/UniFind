import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:unifind/Components/empty_state_widget.dart';
import 'package:unifind/Components/my_appbar.dart';
import 'package:unifind/Pages/view_post.dart';
import 'package:unifind/services/notifications_service.dart';
import 'package:unifind/utils/date_formats.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationService notificationService = NotificationService();

  // click on notification -> mark as read and view matched post
  Future<void> markAsReadAndNavigate(context, notificationID, matchPostID) async {
    try {
      await notificationService.markAsRead(notificationID);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ViewPost(postID: matchPostID)),
      );
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MyAppbar(title: "Notifications"),
      body: StreamBuilder(
        stream: notificationService.getUserNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: const Text("Error loading notifications", style: TextStyle(fontSize: 16)));
          }
            
          final notifications = snapshot.data!.docs;
          if (notifications.isEmpty) {
            return const EmptyStateWidget(
              icon: Symbols.notifications_none,
              title: "No Notifications",
              subtitle: "We’ll let you know when any of your unclaimed items get matched!",
            );
          }
      
          return ListView.builder(
            shrinkWrap: true,
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notificationData = notifications[index];
              final matchPostID = notificationData['matchPostID'];
              final notificationID = notificationData.id;

              return NotificationTile(
                message: notificationData['message'],
                timestamp: notificationData['timestamp'],
                isRead: notificationData['isRead'],
                onTap: () => markAsReadAndNavigate(context, notificationID, matchPostID),
              );
            },
          );
        },
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final String message;
  final Timestamp timestamp;
  final bool isRead;
  final Future<void> Function() onTap;

  const NotificationTile({
    super.key,
    required this.message,
    required this.timestamp,
    required this.isRead,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final notificationDate = DateFormats.formatNotificationTime(timestamp.toDate());

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isRead ? Colors.grey[200] : const Color(0xFFEADDEF),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Symbols.notifications,
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
      onTap: onTap,
    );
  }
}

