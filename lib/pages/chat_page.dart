import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:unifind/Components/chat/chat_appbar.dart';
import 'package:unifind/Components/chat/chat_bubble.dart';
import 'package:unifind/Components/chat/chat_textfeild.dart';

class ChatPage extends StatefulWidget {
  final String? receiverID;

  const ChatPage({super.key, required this.receiverID});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // text controller
  final TextEditingController _messageController = TextEditingController();

  // for textfeild focus
  FocusNode myFocusNode = FocusNode();

  // @override
  // void initState() {
  //   super.initState();

  //   // add listner to focus
  //   myFocusNode.addListener(() {
  //     if (myFocusNode.hasFocus) {
  //       // cause a delay so that the keyboard has time to show up
  //       // then the amount of remaining space will be calculated,
  //       // then scroll down
  //       Future.delayed(const Duration(milliseconds: 500), () => scrollDown());
  //     }
  //   });

  //   // wait a bit for listview to be built, then scroll to bottom
  //   Future.delayed(const Duration(milliseconds: 500), () => scrollDown());
  // }

  @override
  void dispose() {
    myFocusNode.dispose();
    _messageController.dispose();
    // _scrollController.dispose();
    super.dispose();
  }

  // scroll controller
  // final ScrollController _scrollController = ScrollController();
  // void scrollDown() {
  //   _scrollController.animateTo(
  //     _scrollController.position.maxScrollExtent,
  //     duration: const Duration(seconds: 1),
  //     curve: Curves.fastOutSlowIn,
  //   );
  // }

  // send message
  void sendMessage() async {
    // // if there is something inside the textfeild
    // if (_messageController.text.isNotEmpty) {
    //   // send the message
    //   await _chatService.sendMessage(
    //     widget.recieverID,
    //     _messageController.text,
    //   );

    //   // clear the controller
    //   _messageController.clear();
    // }

    // scrollDown();
  }

  // send image
  void sendImage() async {
    
  }

  // check if typing
  bool _isTyping = false;
  void _onTextChanged(String value) {
    setState(() {
      _isTyping = value.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    // final bool isCurrentUser = postData['uid'] == FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: chatAppBar(context, "Faisal Ahmed", ""),
      body: Column(
        children: [
          // chat messages 
          Expanded(
            child: ListView(
              // controller: _scrollController,
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              children: [
                // system message (show once chat is opened)
                _buildSystemMessage(),

                // example bubbles for layout
                ChatBubble(
                  message: "Hey, did you find the watch?",
                  isCurrentUser: false,
                  timestamp: DateTime.now().subtract(
                    const Duration(minutes: 5),
                  ),
                ),
                ChatBubble(
                  message: "Yes, I did! It matches your description perfectly.",
                  isCurrentUser: true,
                  timestamp: DateTime.now().subtract(
                    const Duration(minutes: 2),
                  ),
                ),
              ],
            ),
          ),
          // user input
          _buildUserInput(),
        ],
      ),
    );
  }

  // system message  
  Widget _buildSystemMessage() {
    const basePurple = Color(0xFF771F98);
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 310),
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: basePurple.withAlpha(20), 
          border: Border.all(color: basePurple.withAlpha(60)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Text(
          "Chat started as an item found. Please verify ownership before collection.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.5,
            color: Color(0xFF6C3FA8),
            height: 1.4,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // user input 
  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50.0),
      child: Row(
        children: [
          // text feild
          Expanded(
            child: ChatTextfield(
              hintText: "Type a message",
              controller: _messageController,
              // focusNode: myFocusNode,
              onChanged: _onTextChanged, 
            ),
          ),

          // action button (changes between camera & send)
          Container(
            decoration: BoxDecoration(
              color: _isTyping
                  ? const Color(0xFF771F98)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            margin: const EdgeInsets.only(right: 25.0),
            child: IconButton(
              onPressed: _isTyping ? sendMessage : sendImage,
              icon: Icon(
                _isTyping ? Symbols.send : Symbols.photo_camera,
                color: _isTyping ? Colors.white : Colors.grey[800],
                fill: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
