import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unifind/Components/empty_state_widget.dart';
import 'package:unifind/Components/my_appbar.dart';
import 'package:unifind/Components/notification_tile.dart';

class NotificationsPage extends StatefulWidget {
  final String uid;
  const NotificationsPage({super.key, required this.uid});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // get notifications
  Stream<QuerySnapshot> getNotifications() {
    Query query = FirebaseFirestore.instance
        .collection('notifications')
        .where("toUserID", isEqualTo: widget.uid)
        .orderBy('timestamp', descending: true);

    return query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MyAppbar(title: "Notifications"),
      body: SafeArea(
        child: StreamBuilder(
          stream: getNotifications(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: const Text("Error", style: TextStyle(fontSize: 16)));
            }
      
            final notifications = snapshot.data!.docs;
            if (notifications.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.notifications_none,
                title: "No Notifications",
                subtitle: "We’ll let you know when any of your unclaimed items get matched!",
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final data = notifications[index];
                return NotificationTile(
                  message: data['message'],
                  matchPostID: data['matchPostID'],
                  timestamp: data['timestamp'],
                  isRead: data['isRead'],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
