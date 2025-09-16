import 'package:intl/intl.dart';

class TimestampFormat {
  static String getFormat(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (timestamp.isAfter(today)) {
      return DateFormat('h:mm a').format(timestamp); 
    } else if (timestamp.isAfter(yesterday)) {
      return "Yesterday";
    } else if (now.difference(timestamp).inDays < 7) {
      return DateFormat('EEEE').format(timestamp); // day
    } else {
      return DateFormat('d MMM yyyy').format(timestamp); 
    }
  }
}
