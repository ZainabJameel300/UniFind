import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:unifind/Components/chat/chat_tile.dart';
import 'package:unifind/Components/empty_state_widget.dart';
import 'package:unifind/Components/my_AppBar.dart';
import 'package:unifind/Pages/chat_page.dart';
import 'package:unifind/services/chat_service.dart';

class ChatroomsPage extends StatelessWidget {
  ChatroomsPage({super.key});

  final chatService = ChatService();
  final currentUserID = FirebaseAuth.instance.currentUser!.uid;

  void openChat(context, receiverID, receiverName, receiverAvatar, lastReadBy) async{
    // mark all chatroom messages as read before opening the chat
    await chatService.markAsRead(receiverID);

    // navigate to chat page    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          receiverID: receiverID,
          name: receiverName,
          avatar: receiverAvatar,
          lastReadBy: lastReadBy,
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
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
              final otherUserID = participants.first;

              // chat data
              final lastMsg = chatData['lastMsg'] ?? '';
              final lastMsgTime = chatData['lastMsgTime'];
              final isLastSender = chatData['lastSender'] == currentUserID;
              final isUnread = chatData['unreadBy'] == currentUserID;
              final lastReadBy = chatData['lastReadBy'];

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
                    lastMsgTime: lastMsgTime ?? Timestamp.now(),
                    isLastSender: isLastSender,
                    isUnread: isUnread,
                    onTap: () => openChat(context, otherUserID, name, avatar, lastReadBy),
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

