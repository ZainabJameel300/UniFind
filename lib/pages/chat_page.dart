import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  File? _selectedImage;

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
  Future<void> sendMessage(String type) async {
    // send text
    if (type == "text" && _messageController.text.isNotEmpty) {
      await chatService.sendMessage(
        widget.receiverID,
        _messageController.text,
        "text",
      );
      _messageController.clear();
      scrollDown();
    }

    // send image 
    if (type == "pic" && _selectedImage != null) {
      final file = _selectedImage!;
      final int timestamp = DateTime.now().millisecondsSinceEpoch;
      final String chatroomID = chatService.getChatroomID(widget.receiverID);

      // hide pic preview after pressing send
      setState(() => _selectedImage = null);

      final ref = FirebaseStorage.instance.ref().child(
        'chat_images/$chatroomID/$timestamp-$currentUserID.jpg',
      );

      await ref.putFile(file);
      final imageUrl = await ref.getDownloadURL();
      await chatService.sendMessage(widget.receiverID, imageUrl, "pic");

      scrollDown();
    }
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

              // chat room doesn't exist
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
              
              // show chat room messages
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

                    // mark messages as read while chat is opened
                    final isFromOtherUser = lastSenderID != currentUserID;
                    if (isFromOtherUser) {
                      _markRead();
                    }

                    final messages = snapshot.data?.docs ?? [];

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
                          
                          return ChatBubble(
                            message: msg['content'],
                            isCurrentUser: isCurrentUser,
                            timestamp: msg['timestamp'].toDate(),
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
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // input field or image preview
              Expanded(
                child: Container(
                  height: _selectedImage == null ? 55 : 130,
                  margin: const EdgeInsets.only(left: 18, right: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: _selectedImage == null
                      ? ChatTextfield(
                          hintText: "Type a message",
                          controller: _messageController,
                          focusNode: myFocusNode,
                          onChanged: (value) {
                            setState(() {
                              isTyping = value.trim().isNotEmpty;
                            });
                          },
                        )
                      : Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.all(10),
                            width: MediaQuery.of(context).size.width * 0.35,
                            height: 120,
                            child: Stack(
                              children: [
                                // picked image 
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),

                                // cancel sending the image 
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() => _selectedImage = null);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withAlpha(100),
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: const Icon(
                                        Symbols.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),

              // action button (send or camera)
              Container(
                decoration: BoxDecoration(
                  color: (isTyping || _selectedImage != null)
                      ? const Color(0xFF771F98)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                margin: const EdgeInsets.only(right: 25.0),
                child: IconButton(
                  onPressed: () async {
                    if (_selectedImage != null) {
                      await sendMessage("pic");
                    } else if (isTyping) {
                      await sendMessage("text");
                      setState(() => isTyping = false);
                    } else {
                      // pick photo 
                      final ImagePicker picker = ImagePicker();
                      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        setState(() => _selectedImage = File(pickedFile.path));
                      }
                    }
                  },
                  icon: Icon(
                    (isTyping || _selectedImage != null)
                        ? Symbols.send
                        : Symbols.photo_camera,
                    color: (isTyping || _selectedImage != null)
                        ? Colors.white
                        : Colors.grey[800],
                    fill: 1,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
