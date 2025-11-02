import 'package:flutter/material.dart';
import 'package:unifind/utils/date_formats.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final DateTime timestamp;
  final bool isLastAndSeen;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.timestamp,
    required this.isLastAndSeen,
  });

  @override
  Widget build(BuildContext context) {
    final msgTime = DateFormats.formatMsgTime(timestamp);
    
    final bgColor = isCurrentUser
        ? const Color(0xFF771F98)
        : const Color(0xFFF0F0F0);
    final textColor = isCurrentUser ? Colors.white : Colors.black87;

    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isCurrentUser ? 80 : 20,
          right: isCurrentUser ? 20 : 80,
          top: 6,
          bottom: 2,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isCurrentUser
                ? const Radius.circular(16)
                : const Radius.circular(4),
            bottomRight: isCurrentUser
                ? const Radius.circular(4)
                : const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isCurrentUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            // message
            Text(
              message,
              style: TextStyle(color: textColor, fontSize: 14.5, height: 1.35),
            ),
            const SizedBox(height: 4),
            // message time
            Text(
              msgTime,
              style: TextStyle(
                color: isCurrentUser ? Colors.white70 : Colors.grey[600],
                fontSize: 11,
              ),
            ),
            // seen indicator
            if (isLastAndSeen)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  "Seen",
                  style: TextStyle(
                    fontSize: 11,
                    color: isCurrentUser ? Colors.white70 : Colors.grey[600],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
