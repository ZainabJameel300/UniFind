import 'package:flutter/material.dart';
import 'package:unifind/Components/post/fullscreen_image.dart';
import 'package:unifind/utils/date_formats.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final DateTime timestamp;
  final String type;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.timestamp,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final msgTime = DateFormats.formatMsgTime(timestamp);

    final bgColor = isCurrentUser
        ? const Color(0xFF771F98)
        : const Color(0xFFF0F0F0);

    return Container(
      margin: (type == "text")
      ? EdgeInsets.only(
        left: isCurrentUser ? 80 : 20,
        right: isCurrentUser ? 20 : 80,
        top: 6,
        bottom: 6,
      )
      : EdgeInsets.only(
        left: isCurrentUser ? 80 : 20,
        right: isCurrentUser ? 20 : 80,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: isCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: (type == "text") 
                  ? EdgeInsets.all(10)
                  : EdgeInsets.symmetric(vertical: 8),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: type == "text" ? BoxDecoration(
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
              )
              :  BoxDecoration(),
              child: Column(
                crossAxisAlignment: isCurrentUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (type == "text") 
                    Text(
                      message,
                      style: TextStyle(
                        color: isCurrentUser ? Colors.white : Colors.black87,
                        fontSize: 15,
                        height: 1.3,
                      ),
                    ),

                  if (type == "pic") 
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullScreenImage(imageUrl: message),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(10),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            message,
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width * 0.6,
                            height: 220,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child; // image loaded 
                              
                              // while loading, show placeholder container
                              return Container(
                                width: MediaQuery.of(context).size.width * 0.6,
                                height: 220,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: SizedBox(
                                    width: 26,
                                    height: 26,
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF771F98),
                                      strokeWidth: 2.5,
                                    ),
                                  ),
                                ),
                              );
                            },                            
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    msgTime,
                    style: TextStyle(
                      color: type == "text"
                          ? (isCurrentUser ? Colors.white70 : Colors.grey[600])
                          : Colors.grey[600],
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
