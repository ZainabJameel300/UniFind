import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String postID;
  final String uid;
  final String title;
  final String description;
  final String category;
  final String type;
  final String location;
  final bool claimStatus;
  final String date; 
  final Timestamp createdAt;
  final String picture;
  final List<double> embedding;

  Post({
    required this.postID,
    required this.uid,
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    required this.location,
    required this.claimStatus,
    required this.date,
    required this.createdAt,
    required this.picture,
    required this.embedding,
  });

  Post.fromJson(Map<String, Object?> json) 
      : this(
        postID: json['postID']! as String,
        uid: json['uid']! as String,
        title: json['title']! as String,
        description: json['description']! as String,
        category: json['category']! as String,
        type: json['type']! as String,
        location: json['location']! as String,
        claimStatus: json['claimStatus']! as bool,
        date: json['date']! as String,
        createdAt: json['createdAt']! as Timestamp,
        picture: json['picture'] as String,
        embedding: json['embedding'] as List<double>,
      );
  
  Map<String, Object?> tojson() {
    return {
      'postID': postID,
      "uid": uid,
      "title": title,
      "description": description,
      "category": category,
      "type": type,
      "location": location,
      "claimStatus": claimStatus,
      "date": date,
      "createdAt": createdAt,
      "picture": picture,
      "embedding": embedding,
    };
  }
  
}
