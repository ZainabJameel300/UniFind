import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unifind/utils/date_formats.dart';

class ChatTile extends StatelessWidget {
  final String name;
  final String avatar;
  final String lastMsg;
  final Timestamp lastMsgTime;
  final void Function()? onTap;

  const ChatTile({
    super.key,
    required this.name,
    required this.avatar,
    required this.lastMsg,
    required this.lastMsgTime,
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
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          Text(
            chatTime,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          lastMsg,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
