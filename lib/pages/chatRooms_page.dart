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
              final otherUserID = participants.first;

              // chat data
              final String lastMsg = chatData['lastMsg'] ?? '';
              final DateTime lastMsgTime = chatData['lastMsgTime'].toDate();
              // final String lastSender = chatData['lastSender'];//delete 
              final bool isLastSender = chatData['lastSender'] == currentUserID;
              final bool isReadCurrent = chatData['isRead'][currentUserID] == true;
              // final bool isReadOther = chatData['isRead'][otherUserID] == true;//delete 


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
                    lastMsgTime: lastMsgTime,
                    isLastSender: isLastSender,
                    isRead: isReadCurrent,
                    onTap: () async {
                      // mark chat as read 
                      await chatService.markAsRead(otherUserID);

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

