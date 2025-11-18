import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String currentUserID = FirebaseAuth.instance.currentUser!.uid;

  // get all notifications for current user
  Stream<QuerySnapshot> getUserNotifications() {
    return firestore
        .collection('notifications')
        .where('toUserID', isEqualTo: currentUserID)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // mark a notification as read
  Future<void> markAsRead(String notificationID) async {
    await firestore
        .collection('notifications')
        .doc(notificationID)
        .update({'isRead': true});
  }

  /// get unread notifications count at home
  Stream<int> unreadNotificationsCount() {
    return firestore
        .collection('notifications')
        .where('toUserID', isEqualTo: currentUserID)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }
}
