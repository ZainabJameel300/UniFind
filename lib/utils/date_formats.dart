import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DateFormats {
  // for publish time 
  static String formatPublishTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (timestamp.isAfter(today)) {
      return DateFormat('h:mm a').format(timestamp);
    } else if (timestamp.isAfter(yesterday)) {
      return "Yesterday";
    } else if (now.difference(timestamp).inDays < 7) {
      return DateFormat('EEEE').format(timestamp); 
    } else {
      return DateFormat('d MMM yyyy').format(timestamp);
    }
  }

  // for lost date 
  static String formatLostDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('d/M/yyyy').format(date);
  }
}
