import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String currentUserID = FirebaseAuth.instance.currentUser!.uid;

  // construct unique chatroom ID
  String getChatroomID(String otherUserID) {
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
    final String chatroomID = getChatroomID(receiverID);
    final String lastMsg = (type == "pic") ? "Photo" : message;

    final chatRef = firestore.collection("chat_rooms").doc(chatroomID);
    final msgRef = chatRef.collection("messages");

    // update chatroom info
    await chatRef.set({
      "participants": [currentUserID, receiverID],
      "lastMsg": lastMsg,
      "lastMsgType": type,
      "lastMsgTime": timestamp,
      "lastSender": currentUserID,
      "lastReadTime": {
        currentUserID: timestamp
      },
    }, SetOptions(merge: true));

    // add message 
    await msgRef.add({
      "senderId": currentUserID,
      "type": type,
      "content": message,
      "timestamp": timestamp,
    });
  }

  // get chatrooms for current user
  Stream<QuerySnapshot<Map<String, dynamic>>> getUserChatrooms() {
    return firestore
        .collection("chat_rooms")
        .where("participants", arrayContains: currentUserID)
        .orderBy("lastMsgTime", descending: true)
        .snapshots();
  }

  // get all chat messages
  Stream<QuerySnapshot<Map<String, dynamic>>> getMessages(String otherUserID) {
    final chatroomID = getChatroomID(otherUserID);

    return firestore
        .collection("chat_rooms")
        .doc(chatroomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  // mark chat as read 
  Future<void> markAsRead(String otherUserID) async {
    final chatroomID = getChatroomID(otherUserID);
    final chatRef = firestore.collection("chat_rooms").doc(chatroomID);

    await chatRef.set({
      "lastReadTime": {
        currentUserID: FieldValue.serverTimestamp(),
      },
    }, SetOptions(merge: true));
  }      

  // get unread chats count
  Stream<int> unreadChatsCount() {
    return FirebaseFirestore.instance
        .collection('chat_rooms')
        .where('participants', arrayContains: currentUserID)
        .snapshots()
        .map((snapshot) {
          int unread = 0;

          for (var doc in snapshot.docs) {
            final chatroom = doc.data();
            final Timestamp lastMsg = chatroom['lastMsgTime'];
            final Timestamp? lastRead = (chatroom['lastReadTime'] ?? {})[currentUserID];

            // if never read or message newer than last read -> unread
            if (lastRead == null || lastMsg.toDate().isAfter(lastRead.toDate())) {
              unread++;
            }
          }

          return unread;
        });
  }

}
