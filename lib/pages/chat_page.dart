import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  final String? receiverID; 

  const ChatPage({
    super.key, 
    required this.receiverID
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text('Chat with : $receiverID}')
      ),
    );
  }
}
