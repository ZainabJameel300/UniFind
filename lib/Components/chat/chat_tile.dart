import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unifind/utils/date_formats.dart';

class ChatTile extends StatelessWidget {
  final String name;
  final String avatar;
  final String lastMsg;
  final Timestamp lastMsgTime;
  final bool isLastSender;
  final bool isUnread;
  final void Function()? onTap;

  const ChatTile({
    super.key,
    required this.name,
    required this.avatar,
    required this.lastMsg,
    required this.lastMsgTime,
    required this.isLastSender,
    required this.isUnread,
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
    final chatTime = DateFormats.formatChatTime(lastMsgTime.toDate());
    final previewText = isLastSender ? "You: $lastMsg" : lastMsg;

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
                fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          Text(
            chatTime,
            style: TextStyle(
              fontSize: 12,
              color: isUnread ? const Color(0xFF771F98) : Colors.grey[600],
              fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
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
                previewText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: isUnread ? Colors.black : Colors.grey,
                  fontWeight: isUnread ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
            if (isUnread)
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
