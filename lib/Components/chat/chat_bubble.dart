import 'package:flutter/material.dart';
import 'package:unifind/utils/date_formats.dart';
import 'package:material_symbols_icons/symbols.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final DateTime timestamp;
  final bool isLastAndSeen;
  final String type;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.timestamp,
    required this.isLastAndSeen,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final msgTime = DateFormats.formatMsgTime(timestamp);

    final bgColor = isCurrentUser
        ? const Color(0xFF771F98)
        : const Color(0xFFF0F0F0);
    final textColor = isCurrentUser ? Colors.white : Colors.black87;

    return Container(
      margin: isLastAndSeen 
      ? EdgeInsets.only(
        left: isCurrentUser ? 80 : 1,
        right: isCurrentUser ? 1 : 80,
        top: 6,
        bottom: 6,
      )
      : EdgeInsets.only(
        left: isCurrentUser ? 80 : 20,
        right: isCurrentUser ? 20 : 80,
        top: 6,
        bottom: 6,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: isCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // bubble
          Flexible(
            child: Container(
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
                  Text(
                    message,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14.5,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    msgTime,
                    style: TextStyle(
                      color: isCurrentUser ? Colors.white70 : Colors.grey[600],
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // seen 
          if (isLastAndSeen)
            Padding(
              padding: const EdgeInsets.only(left: 3, right: 3, bottom: 2),
              child: Icon(
                Symbols.check_circle,
                size: 15,
                color: const Color(0xFF6C3FA8),
              ),
            ),
        ],
      ),
    );
  }
}
