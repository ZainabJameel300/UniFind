import 'package:flutter/material.dart';
import 'package:unifind/Components/empty_state_widget.dart';

class ChatroomsPage extends StatelessWidget {
  const ChatroomsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: EmptyStateWidget(
        icon: Icons.inbox_outlined,
        title: "No chats yet",
        subtitle: "You haven’t started any conversations. Start a chat to confirm ownership or return an item.",
      ),
    );
  }
}