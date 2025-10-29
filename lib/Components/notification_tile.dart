import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:unifind/utils/date_formats.dart';

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
          color: isRead
              ? Colors.grey[200]
              : const Color(0xFFEADDEF),
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
