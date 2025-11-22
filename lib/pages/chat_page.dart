import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:unifind/Components/chat/chat_appbar.dart';
import 'package:unifind/Components/chat/chat_bubble.dart';
import 'package:unifind/Components/my_textfield.dart';
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
  final ChatService chatService = ChatService();
  final String currentUserID = FirebaseAuth.instance.currentUser!.uid;

  final TextEditingController _messageController = TextEditingController();
  final FocusNode myFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  File? _selectedImage;
  bool _isUploading = false;

  bool _isMarkingRead = false;
  int _lastMarkedTimestamp = 0;

  @override
  void initState() {
    super.initState();

    // scroll when keyboard opens
    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 500), () {
          scrollDown();
        });
      }
    });

    // show recent messages when chat is opened
    Future.delayed(const Duration(milliseconds: 350), () async {
      if (!_scrollController.hasClients) return;

      await _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutQuad,
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
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
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
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
    if (_selectedImage == null) return;

    final file = _selectedImage!;
    final int timestamp = DateTime.now().millisecondsSinceEpoch;
    final String chatroomID = chatService.getChatroomID(widget.receiverID);
    
    setState(() => _isUploading = true); // start loading

    final ref = FirebaseStorage.instance.ref().child(
      'chat_images/$chatroomID/$timestamp-$currentUserID.jpg',
    );

    await ref.putFile(file);
    final imageUrl = await ref.getDownloadURL();
    await chatService.sendMessage(widget.receiverID, imageUrl, "pic");

    setState(() {
      _isUploading = false;
      _selectedImage = null; // remove preview after send
    });

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
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
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
                        final DateTime time = msg['timestamp'].toDate() ?? DateTime.now();
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

                      // auto scroll if:
                      // 1. user is already near bottom
                      // 2. message was sent by the other user
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!_scrollController.hasClients || messages.isEmpty) return;

                        final position = _scrollController.position;
                        final atBottom = position.pixels >= position.maxScrollExtent - 100; 
                        final lastMessage = messages.last.data();
                        final isFromOtherUser = lastMessage['senderId'] != currentUserID;

                        if (atBottom || isFromOtherUser) {
                          _scrollController.animateTo(
                            position.maxScrollExtent,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        }
                      });
                
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
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        decoration: BoxDecoration(
          color: basePurple.withAlpha(20), 
          border: Border.all(color: basePurple.withAlpha(60)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Text(
          "Chat to confirm item ownership. Mark it as claimed once collection is arranged.",
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
    return StatefulBuilder(
      builder: (context, setState) {
        bool hasText = _messageController.text.trim().isNotEmpty;

        _messageController.addListener(() {
          setState(() {}); 
        });

        return SafeArea(
          minimum: EdgeInsets.symmetric(vertical: 6, horizontal: 18),          
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // input field or image preview
              Expanded(
                child: Container(
                  height: _selectedImage == null ? 55 : 130,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: _selectedImage == null
                      ? // text input
                      MyTextField(
                          hintText: "Type a message",
                          obscureText: false,
                          controller: _messageController,
                          focusNode: myFocusNode,
                          chatField: true,
                        )
                      : // image input
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          width: MediaQuery.of(context).size.width * 0.35,
                          height: 120,
                          child: Stack(
                            children: [
                              // picked pic
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
          
                              // show loading while uploading the pic
                              if (_isUploading)
                                Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withAlpha(100),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Center(
                                    child: SizedBox(
                                      width: 30,
                                      height: 30,
                                      child: CircularProgressIndicator(
                                        color: Colors.white70,
                                        strokeWidth: 2.5,
                                      ),
                                    ),
                                  ),
                                ),
          
                              // cancel only if not uploading
                              if (!_isUploading)
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
          
              // action button (send or pick image)
              Container(
                decoration: BoxDecoration(
                  color: _isUploading
                      ? const Color(0xFF771F98).withAlpha(120)
                      : (hasText || _selectedImage != null)
                          ? const Color(0xFF771F98)
                          : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: _isUploading
                    ? null
                    : () async {
                        if (_selectedImage != null) {
                          await _sendImageMessage();
                        } else if (hasText) {
                          _sendTextMessage();
                          setState(() => hasText = false);
                        } else {
                          _showImagePickerMenu(context);
                        }
                      },
                  icon: Icon(
                    (hasText || _selectedImage != null) ? Symbols.send : Symbols.add,
                    color: (hasText || _selectedImage != null)
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

  // pick image menu (camera / gallery)
  void _showImagePickerMenu(BuildContext context) async {
    FocusScope.of(context).unfocus();
    await Future.delayed(const Duration(milliseconds: 300));

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final ImagePicker picker = ImagePicker();
 
    // options
    final options = [
      {
        "icon": Symbols.photo_camera,
        "label": "Camera",
        "source": ImageSource.camera,
      },
      {
        "icon": Symbols.image,
        "label": "Gallery",
        "source": ImageSource.gallery,
      },
    ];

    // Show popup
    await showMenu(
      context: context,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 1,
      position: RelativeRect.fromLTRB(position.dx + 40, position.dy - 120, 20, 0),
      items: options.map((opt) {
        return PopupMenuItem(
          onTap: () async {
            final XFile? picked = await picker.pickImage(
              source: opt["source"] as ImageSource,
            );
            if (picked != null) {
              setState(() => _selectedImage = File(picked.path));
            }          
          },
          child: Row(
            children: [
              Icon(
                opt["icon"] as IconData,
                color: const Color(0xFF771F98),
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                opt["label"] as String,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

}

