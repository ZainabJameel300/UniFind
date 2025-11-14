import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unifind/providers/filter_provider.dart';

class PostService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String currentUser = FirebaseAuth.instance.currentUser!.uid;

  /// get all users 
  Future<Map<String, Map<String, dynamic>>> loadAllUsers() async {
    final snap = await firestore.collection('users').get();
    return {for (var doc in snap.docs) doc.id: doc.data()};
  }

  /// get filtered posts 
  Stream<QuerySnapshot> getFilteredPosts(BuildContext context) {
    final filterProvider = Provider.of<FilterProvider>(context, listen: false);

    Query query = firestore
        .collection('posts')
        .where('claim_status', isEqualTo: false);

    // type filter
    if (filterProvider.postType != "All") {
      query = query.where('type', isEqualTo: filterProvider.postType);
    }

    // drawer filters
    if (filterProvider.hasAnyFilter) {
      final selectedCategory = filterProvider.selectedCategory;
      final selectedLocation = filterProvider.selectedLocation;
      final selectedDate = filterProvider.selectedDate;

      if (selectedCategory != null) {
        query = query.where('category', isEqualTo: selectedCategory);
      }
      if (selectedLocation != null) {
        query = query.where('location', isEqualTo: selectedLocation);
      }

      if (selectedDate != null) {
        final now = DateTime.now();
        DateTime? start;
        DateTime? end;

        switch (selectedDate) {
          case "Today":
            start = DateTime(now.year, now.month, now.day);
            end = start.add(const Duration(days: 1));
            break;
          case "This week":
            start = DateTime(now.year, now.month, now.day - (now.weekday % 7));
            end = start.add(const Duration(days: 7));
            break;
          case "This month":
            start = DateTime(now.year, now.month, 1);
            end = DateTime(now.year, now.month + 1, 1);
            break;
          case "Last 3 months":
            start = DateTime(now.year, now.month - 3, now.day);
            end = now.add(const Duration(days: 1));
            break;
          case "Last 6 months":
            start = DateTime(now.year, now.month - 6, now.day);
            end = now.add(const Duration(days: 1));
            break;
        }

        query = query
            .where('date', isGreaterThanOrEqualTo: start)
            .where('date', isLessThan: end);
      } 
    }

    query = query.orderBy('createdAt', descending: true);
    return query.snapshots();
  }

  /// get one post
  Stream<DocumentSnapshot> getPostByID(String postID) {
    return firestore.collection('posts').doc(postID).snapshots();
  }

  /// get one publisher 
  Future<DocumentSnapshot> getPublisherByID(String uid) {
    return firestore.collection('users').doc(uid).get();
  }

  // get all post for search (only unclaimed)
  Stream<QuerySnapshot> getAllPosts({int? limit}) {
    var query = firestore
        .collection('posts')
        .where('claim_status', isEqualTo: false)
        .orderBy('createdAt', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots();
  }
}
