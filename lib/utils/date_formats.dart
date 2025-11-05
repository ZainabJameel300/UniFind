import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DateFormats {
  // publish time 
  static String formatPublishTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (timestamp.isAfter(today)) {
      return DateFormat('h:mm a').format(timestamp);
    } else if (timestamp.isAfter(yesterday)) {
      return 'Yesterday ${DateFormat('h:mm a').format(timestamp)}';
    } else if (now.difference(timestamp).inDays < 7) {
      return DateFormat('EEEE h:mm a').format(timestamp); 
    } else if (timestamp.year == now.year) {
      return DateFormat('d MMM h:mm a').format(timestamp);
    } else {
      return DateFormat('d MMM yyyy h:mm a').format(timestamp);
    }
  }

  // lost date 
  static String formatLostDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('d/M/yyyy').format(date);
  }

  // notification time
  static String formatNotificationTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (timestamp.isAfter(today)) {
      return DateFormat('h:mm a').format(timestamp);
    } else if (timestamp.isAfter(yesterday)) {
      return 'Yesterday';
    } else {
      return DateFormat('d/M/yyyy').format(timestamp);
    }
  }

  // for chat last message time
  static String formatChatTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (timestamp.isAfter(today)) {
      return DateFormat('h:mm a').format(timestamp);
    } else if (timestamp.isAfter(yesterday)) {
      return 'Yesterday';
    } else if (now.difference(timestamp).inDays < 7) {
      return DateFormat('EEEE').format(timestamp);
    } else {
      return DateFormat('d/M/yyyy').format(timestamp);
    }
  }

  // messages day header 
  static String formatDayHeader(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (timestamp.isAfter(today)) {
      return 'Today';
    } else if (timestamp.isAfter(yesterday)) {
      return 'Yesterday';
    } else if (now.difference(timestamp).inDays < 7) {
      return DateFormat('EEEE').format(timestamp);
    } else if (timestamp.year == now.year) {
      return DateFormat('d MMM').format(timestamp); 
    } else {
      return DateFormat('d MMM yyyy').format(timestamp); 
    }
  }

  // for chat bubble time
  static String formatMsgTime(DateTime timestamp) {
    return DateFormat('h:mm a').format(timestamp);
  }

}
