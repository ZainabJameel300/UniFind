import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String currentUserID = FirebaseAuth.instance.currentUser!.uid;

  // create unique chatroom ID
  String _getChatroomID(String otherUserID) {
    final ids = [currentUserID, otherUserID];
    ids.sort();
    return ids.join('_');
  }
  
  // get user info (username & avatar)
  Future<Map<String, dynamic>?> getUserInfo(String userId) async {
    final userSnap = await firestore.collection('users').doc(userId).get();
    return userSnap.data();
  }

  // send message
  Future<void> sendMessage(String receiverID, String message, String type) async {
    final timestamp = Timestamp.now();
    final chatroomID = _getChatroomID(receiverID);

    final chatRef = firestore.collection("chat_rooms").doc(chatroomID);
    final msgRef = chatRef.collection("messages");

    // add message
    await msgRef.add({
      "senderId": currentUserID,
      "type": type,
      "content": message,
      "timestamp": timestamp,
    });

    // add or update chatroom info
    await chatRef.set({
      "participants": [currentUserID, receiverID],
      "lastMsg": message,
      "lastMsgTime": timestamp,
      "lastSender": currentUserID,
      'isRead': {
        currentUserID: true, // sender has read
        receiverID: false, // receiver hasn’t read yet
      }
    }, SetOptions(merge: true));
  }

  // get chatrooms for current user
  Stream<QuerySnapshot<Map<String, dynamic>>> getUserChatrooms() {
    return firestore
        .collection("chat_rooms")
        .where("participants", arrayContains: currentUserID)
        .orderBy("lastMsgTime", descending: true)
        .snapshots();
  }
  
  // get chatroom info for read & seen
  Stream<DocumentSnapshot<Map<String, dynamic>>> getChatroomInfo(String otherUserID) {
    final chatroomID = _getChatroomID(otherUserID);
    return firestore.collection("chat_rooms").doc(chatroomID).snapshots();
  }


  // get all chat messages
  Stream<QuerySnapshot<Map<String, dynamic>>> getMessages(String otherUserID) {
    final chatroomID = _getChatroomID(otherUserID);

    return firestore
        .collection("chat_rooms")
        .doc(chatroomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  // mark chat as read 
  Future<void> markAsRead(String otherUserID) async {
    final chatroomID = _getChatroomID(otherUserID);
    final chatRef = firestore.collection("chat_rooms").doc(chatroomID);

    await chatRef.set({
      'isRead': {currentUserID: true},
    }, SetOptions(merge: true));
  }

  // get unread chats count (for chat tab icon)
Stream<int> unreadChatsCount() {
  return FirebaseFirestore.instance
      .collection('chat_rooms')
      .where('participants', arrayContains: currentUserID)
      .snapshots()
      .map((snapshot) {
        // count chats where current user didn't read
        final unreadCount = snapshot.docs.where((doc) {
          final data = doc.data();
          final isRead = data['isRead'] ?? {};
          return isRead[currentUserID] == false;
        }).length;

        return unreadCount; 
      });
  }

}
