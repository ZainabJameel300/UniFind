import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationTile extends StatelessWidget {
  final String message;
  final String matchPostID;
  final Timestamp timestamp;
  final bool isRead;

  const NotificationTile({
    super.key,
    required this.message,
    required this.matchPostID,
    required this.timestamp,
    required this.isRead,
  });

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}