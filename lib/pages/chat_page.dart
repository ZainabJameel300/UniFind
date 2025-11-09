import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:unifind/Components/chat/chat_appbar.dart';
import 'package:unifind/Components/chat/chat_bubble.dart';
import 'package:unifind/Components/chat/chat_textfeild.dart';
import 'package:unifind/services/chat_service.dart';
import 'package:unifind/utils/date_formats.dart';

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

  File? _selectedImage;
  bool _isMarkingRead = false;
  int _lastMarkedTimestamp = 0;

  @override
  void initState() {
    super.initState();
    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) => scrollDown());
      }
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

  // send text
  Future<void> _sendTextMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    
    final text = _messageController.text.trim();
    _messageController.clear();
    
    await chatService.sendMessage(widget.receiverID, text, 'text');
    scrollDown();
  }

  // send image
  Future<void> _sendImageMessage() async {
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

  // mark chat as read only if new message is sent by other user
  Future<void> _markAsReadIfNeeded(
    String lastSenderId,
    Timestamp lastMessageTime,
    Timestamp? myLastReadTime,
  ) async {
    // skip if last message sent by current user 
    if (lastSenderId == currentUserID) return;

    final int lastMessageMs = lastMessageTime.millisecondsSinceEpoch;
    final int myReadMs = myLastReadTime?.millisecondsSinceEpoch ?? 0;

    // skip if last message is already read 
    if (lastMessageMs <= myReadMs || lastMessageMs <= _lastMarkedTimestamp) return;
    if (_isMarkingRead) return; 

    _isMarkingRead = true;
    try {
      await chatService.markAsReadUpTo(widget.receiverID, lastMessageTime);
      _lastMarkedTimestamp = lastMessageMs; 
    } finally {
      _isMarkingRead = false; 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: chatAppBar(context, widget.name, widget.avatar),
      body: Column(
        children: [
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
              final Timestamp lastMsgTime = chatroomData['lastMsgTime'] ?? Timestamp.now();
              final lastReadMap = chatroomData['lastReadTime'] ?? {};
              final Timestamp? receiverReadTime = lastReadMap[widget.receiverID];
              final Timestamp? myLastReadTime = lastReadMap[currentUserID];

              // mark as read when chatroom info update
              _markAsReadIfNeeded(lastSenderID, lastMsgTime, myLastReadTime);

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

                    // find current user last message read by other user
                    int? lastSeenIndex;
                    if (receiverReadTime != null) {
                      for (int i = messages.length - 1; i >= 0; i--) {
                        final msg = messages[i].data();
                        if (msg['senderId'] == currentUserID) {
                          final msgTime = (msg['timestamp'] as Timestamp).toDate();
                          if (!msgTime.isAfter(receiverReadTime.toDate())) {
                            lastSeenIndex = i;
                            break;
                          }
                        }
                      }
                    }

                    // Build messages list 
                    List<Widget> messagesList = [];
                    DateTime? lastDay;
              
                    for (int i = 0; i < messages.length; i++) {
                      final msg = messages[i].data();
                      final DateTime time = msg['timestamp'].toDate();
                      final bool isCurrentUser = msg['senderId'] == currentUserID;
                      final bool isLastSeen = (i == lastSeenIndex);

                      // day header
                      final DateTime messageDay = DateTime(time.year, time.month, time.day);
                      final String dayLabel = DateFormats.formatDayHeader(time);
                      if (lastDay == null || messageDay != lastDay) {
                        messagesList.add(_buildDateHeader(dayLabel));
                        lastDay = messageDay;
                      }

                      messagesList.add(
                        ChatBubble(
                          message: msg['content'],
                          isCurrentUser: isCurrentUser,
                          timestamp: time,
                          type: msg['type'],
                          isLastSeen: isLastSeen,
                        ),
                      );
                    }
              
                    // show messages
                    return ListView(
                      controller: _scrollController,
                      reverse: false, 
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      children: [
                        _buildSystemMessage(),
                        ...messagesList,
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: basePurple.withAlpha(20), 
          border: Border.all(color: basePurple.withAlpha(60)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Text(
          "Chat started for a potential match. Please verify ownership before collection.",
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

  // date header
  Widget _buildDateHeader(String dayLabel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          dayLabel,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
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
                      await _sendImageMessage();
                    } else if (isTyping) {
                      _sendTextMessage();
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
                        : Symbols.image,
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
