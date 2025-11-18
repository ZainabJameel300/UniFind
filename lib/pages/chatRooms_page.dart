import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:unifind/Components/empty_state_widget.dart';
import 'package:unifind/Components/my_AppBar.dart';
import 'package:unifind/Components/user_avatar.dart';
import 'package:unifind/Pages/chat_page.dart';
import 'package:unifind/services/chat_service.dart';
import 'package:unifind/utils/date_formats.dart';

class ChatroomsPage extends StatelessWidget {
  const ChatroomsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final chatService = ChatService();
    final currentUserID = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MyAppbar(title: "Chats", showBack: false),
      body: StreamBuilder<QuerySnapshot>(
        stream: chatService.getUserChatrooms(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading chats"));
          }

          final chatrooms = snapshot.data!.docs;

          // no chats
          if (chatrooms.isEmpty) {
            return const EmptyStateWidget(
              icon: Symbols.inbox,
              title: "No chats yet",
              subtitle: "You haven’t started any conversations. Start a chat to confirm ownership or return an item.",
            );
          }

          return ListView.builder(
            itemCount: chatrooms.length,
            itemBuilder: (context, index) {
              final chatData = chatrooms[index].data() as Map<String, dynamic>;

              // other user data
              final participants = List<String>.from(chatData['participants']);
              participants.remove(currentUserID);
              final String otherUserID = participants.first;

              // check if chat is read
              final Timestamp? lastReadTime = (chatData['lastReadTime'] ?? {})[currentUserID];
              final Timestamp lastMsgTimeStamp = chatData['lastMsgTime'];
              final bool isReadCurrent =
                  chatData['lastSender'] == currentUserID ||
                  (lastReadTime != null && !lastReadTime.toDate().isBefore(lastMsgTimeStamp.toDate()));

              // chat data
              final String lastMsg = chatData['lastMsg'] ?? '';
              final String lastMsgType = chatData['lastMsgType'] ?? '';
              final DateTime lastMsgTime = lastMsgTimeStamp.toDate();
              final bool isLastSender = chatData['lastSender'] == currentUserID;

              // read sender name & avatar
              return FutureBuilder<Map<String, dynamic>?>(
                future: chatService.getUserInfo(otherUserID),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink();
                  }

                  final userData = userSnapshot.data ?? {};
                  final name = userData['username'] ?? "Unknown User";
                  final avatar = userData['avatar'] ?? "";

                  return ChatTile(
                    name: name,
                    avatar: avatar,
                    lastMsg: lastMsg,
                    lastMsgType: lastMsgType,
                    lastMsgTime: lastMsgTime,
                    isLastSender: isLastSender,
                    isRead: isReadCurrent,
                    onTap: () async {
                      // navigate to chat page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            receiverID: otherUserID,
                            name: name,
                            avatar: avatar,
                          ),
                        ),
                      );
                    }
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// chat tile
class ChatTile extends StatelessWidget {
  final String name;
  final String avatar;
  final String lastMsg;
  final String lastMsgType;
  final DateTime lastMsgTime;
  final bool isLastSender;
  final bool isRead;
  final void Function()? onTap;

  const ChatTile({
    super.key,
    required this.name,
    required this.avatar,
    required this.lastMsg,
    required this.lastMsgType,
    required this.lastMsgTime,
    required this.isLastSender,
    required this.isRead,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chatTime = DateFormats.formatChatTime(lastMsgTime);

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: UserAvatar(avatarUrl: avatar, radius: 30),
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
            // show "You:" if current user is last sender  
            if (isLastSender)
              Text(
                "You: ",
                style: TextStyle(
                  fontSize: 14,
                  color: isRead ? Colors.grey : Colors.black,
                  fontWeight: isRead ? FontWeight.w400 : FontWeight.w500,
                ),
              ),

            // show preview depend on last message type
            if (lastMsgType == "image") ...[
              Icon(
                Symbols.photo_camera,
                fill: 1,
                size: 16,
                color: isRead ? Colors.grey : Colors.black87,
              ),
              const SizedBox(width: 4),
              Text(
                "Photo",
                style: TextStyle(
                  fontSize: 14,
                  color: isRead ? Colors.grey : Colors.black87,
                  fontWeight: isRead ? FontWeight.w400 : FontWeight.w500,
                ),
              ),
            ] else ...[
              // text message
              Expanded(
                child: Text(
                  lastMsg,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: isRead ? Colors.grey : Colors.black,
                    fontWeight: isRead ? FontWeight.w400 : FontWeight.w500,
                  ),
                ),
              ),
            ],
            // unread chat indicator
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
