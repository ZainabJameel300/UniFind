import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:unifind/Components/chat/chat_appbar.dart';
import 'package:unifind/Components/chat/chat_bubble.dart';
import 'package:unifind/Components/chat/chat_textfeild.dart';
import 'package:unifind/services/chat_service.dart';

class ChatPage extends StatefulWidget {
  final String receiverID;
  final String name;
  final String avatar;

  const ChatPage({
    super.key, 
    required this.receiverID,                                            
    required this.name,
    required this.avatar,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final chatService = ChatService();
  final currentUserID = FirebaseAuth.instance.currentUser!.uid;

  final TextEditingController _messageController = TextEditingController();
  final FocusNode myFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  bool _isMarkingRead = false; 

  @override
  void initState() {
    super.initState();
    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) => scrollDown());
      }
    });
  }

  // mark messages as read
  void _markRead() {
    if (_isMarkingRead) return;
    _isMarkingRead = true;

    chatService.markAsRead(widget.receiverID).then((_) {
      _isMarkingRead = false;
    });
  }


  @override
  void dispose() {
    myFocusNode.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void scrollDown() {
    if (!_scrollController.hasClients) return;

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 280),
      curve: Curves.fastOutSlowIn,
    );
  }

  // send message
  void sendMessage(String type) async {
    if (_messageController.text.isNotEmpty) {
      await chatService.sendMessage(
        widget.receiverID, 
        _messageController.text,
        type,
      );
      _messageController.clear();

      // scroll when message is sent
      Future.delayed(const Duration(milliseconds: 300), () => scrollDown());
    }
  }

  // send image
  void sendImage() async {
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: chatAppBar(context, widget.name, widget.avatar),
      body: Column(
        children: [
          // chat messages 
          StreamBuilder(
            stream: chatService.getChatroomInfo(widget.receiverID),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Expanded(child: const Center(child: Text("Error loading chat")));
              }
              if (!snapshot.hasData || !snapshot.data!.exists){ 
                return Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    children: [_buildSystemMessage()],
                  ),
                );             
              }

              final chatroomData = snapshot.data?.data() ?? {};
              final lastSenderID = chatroomData['lastSender'] ?? "";
              final isReadByReciever = (chatroomData['isRead'] ?? {})[widget.receiverID] ?? false;
              final bool isSeen = isReadByReciever == true;
              
              return Expanded(
                child: StreamBuilder(
                  stream: chatService.getMessages(widget.receiverID),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text("Error loading messages"));
                    }
              
                    final messages = snapshot.data?.docs ?? [];
                    if (messages.isEmpty) {
                      return ListView(
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        children: [_buildSystemMessage()],
                      );
                    }
              
                    // mark messages as read while chat is opened
                    final isFromOtherUser = lastSenderID != currentUserID;
                    if (isFromOtherUser) {
                      _markRead();
                    }
              
                    return ListView(
                      controller: _scrollController,
                      reverse: false, 
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      children: [
                        _buildSystemMessage(),
                        ...List.generate(messages.length, (i) {
                          final doc = messages[i];
                          final Map<String, dynamic> msg = doc.data();
                          final isCurrentUser = msg['senderId'] == currentUserID;
                          final bool isLastAndSeen =
                              isCurrentUser && // current user msg
                              i == messages.length - 1 && // last msg
                              isSeen == true; // read by other user
              
                          return ChatBubble(
                            message: msg['content'],
                            isCurrentUser: isCurrentUser,
                            timestamp: msg['timestamp'].toDate(),
                            isLastAndSeen: isLastAndSeen,
                            type: msg['type'],
                          );
                        }),
                      ],
                    );
                  },
                ),
              );
            }
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
    bool isTyping = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 50, top: 6),
          child: Row(
            children: [
              // text feild
              Expanded(
                child: ChatTextfield(
                  hintText: "Type a message",
                  controller: _messageController,
                  focusNode: myFocusNode,
                  onChanged: (value) {
                    setState(() {
                      isTyping = value.trim().isNotEmpty; 
                    });
                  },
                ),
              ),
        
              // action button (changes between camera & send)
              Container(
                decoration: BoxDecoration(
                  color: isTyping
                      ? const Color(0xFF771F98)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                margin: const EdgeInsets.only(right: 25.0),
                child: IconButton(
                  onPressed: isTyping ? () => sendMessage("text") : sendImage,              
                  icon: Icon(
                    isTyping ? Symbols.send : Symbols.photo_camera,
                    color: isTyping ? Colors.white : Colors.grey[800],
                    fill: 1,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}
