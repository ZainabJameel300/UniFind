import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unifind/Components/chat/chat_tile.dart';
import 'package:unifind/Components/empty_state_widget.dart';
import 'package:unifind/Components/my_AppBar.dart';
import 'package:unifind/Pages/chat_page.dart';

class ChatroomsPage extends StatelessWidget {
  const ChatroomsPage({super.key});

  void openChat(context, receiverID) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(receiverID: receiverID),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MyAppbar(title: "Chats", showBack: false),
      // EmptyStateWidget(
      //   icon: Symbols.inbox,
      //   title: "No chats yet",
      //   subtitle:
      //       "You haven’t started any conversations. Start a chat to confirm ownership or return an item.",
      // ),
      body:
      ListView.builder(
        itemCount: 4,
        itemBuilder: (context, index) {
          return ChatTile(
            name: "Faisal Ahmed",
            avatar: "",
            lastMsg: "thank you for helping me to find my lost item!!",
            lastMsgTime: Timestamp.now(),
            onTap: () => openChat(context, "receiverID"),
          );
        },
      )
    );
  }
}
