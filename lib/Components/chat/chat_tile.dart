import 'package:flutter/material.dart';
import 'package:unifind/utils/date_formats.dart';

class ChatTile extends StatelessWidget {
  final String name;
  final String avatar;
  final String lastMsg;
  final DateTime lastMsgTime;
  final bool isLastSender;
  final bool isRead;
  final void Function()? onTap;

  const ChatTile({
    super.key,
    required this.name,
    required this.avatar,
    required this.lastMsg,
    required this.lastMsgTime,
    required this.isLastSender,
    required this.isRead,
    required this.onTap,
  });

  Widget _buildAvatar(String avatar) {
    if (avatar.isNotEmpty) {
      return CircleAvatar(radius: 30, backgroundImage: NetworkImage(avatar));
    } else {
      return const Icon(Icons.account_circle, size: 30 * 2, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatTime = DateFormats.formatChatTime(lastMsgTime);
    final previewMsg = isLastSender ? "You: $lastMsg" : lastMsg;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: _buildAvatar(avatar),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isRead ? FontWeight.w600 : FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
          Text(
            chatTime,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                previewMsg,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: isRead ? Colors.grey :  Colors.black,
                  fontWeight: isRead ? FontWeight.w400 : FontWeight.w500,
                ),
              ),
            ),
            // not read chat 
            if (!isRead)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(left: 6, bottom: 2),
                decoration: const BoxDecoration(
                  color: Color(0xFF771F98),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
