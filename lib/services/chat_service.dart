import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
    final participants = [currentUserID, receiverID]..sort();
    final String lastMsg = (type == "pic") ? "Photo" : message;

    final chatRef = firestore.collection("chat_rooms").doc(chatroomID);
    final msgRef = chatRef.collection("messages").doc(); 

    WriteBatch batch = firestore.batch();

    // add message
    batch.set(msgRef, {
      "senderId": currentUserID,
      "type": type,
      "content": message,
      "timestamp": timestamp,
    });

    // update chatroom info
    batch.set(chatRef, {
      "participants": participants,
      "lastMsg": lastMsg,
      "lastMsgType": type,
      "lastMsgTime": timestamp,
      "lastSender": currentUserID,
      "lastReadTime": {currentUserID: timestamp},
    }, SetOptions(merge: true));

    try {
      await batch.commit();
      debugPrint('Sent new message');
    } catch (e) {
      debugPrint('Batch failed: $e');
    }
  }

  // get chatrooms for current user
  Stream<QuerySnapshot<Map<String, dynamic>>> getUserChatrooms() {
    return firestore
        .collection("chat_rooms")
        .where("participants", arrayContains: currentUserID)
        .orderBy("lastMsgTime", descending: true)
        .snapshots();
  }

  // get one chatroom info 
  Stream<DocumentSnapshot<Map<String, dynamic>>> getChatroomInfo(String otherUserID) {
    final chatroomID = getChatroomID(otherUserID);
    return firestore
        .collection("chat_rooms")
        .doc(chatroomID)
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

  // mark new messages as read (update last read time with last message time)
  Future<void> markAsReadUpTo(String otherUserID, Timestamp upTo) async {
    final chatroomID = getChatroomID(otherUserID);
    final chatRef = firestore.collection("chat_rooms").doc(chatroomID);

    await chatRef.set({
      "lastReadTime": {currentUserID: upTo},
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
            final Timestamp lastMsgTime = chatroom['lastMsgTime'];
            final Timestamp? myReadTime = (chatroom['lastReadTime'] ?? {})[currentUserID];

            // if never read or message newer than last read -> unread
            if (myReadTime == null || lastMsgTime.toDate().isAfter(myReadTime.toDate())) {
              unread++;
            }
          }

          return unread;
        });
  }

}
