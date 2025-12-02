import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:unifind/Components/app_button.dart';
import 'package:unifind/Components/empty_state_widget.dart';
import 'package:unifind/Components/my_appbar.dart';
import 'package:unifind/Components/fullscreen_image.dart';
import 'package:unifind/Components/post/big_detail.dart';
import 'package:unifind/Components/user_avatar.dart';
import 'package:unifind/services/post_service.dart';
import 'package:unifind/utils/date_formats.dart';
import 'package:unifind/Pages/chat_page.dart';

class ViewPost extends StatelessWidget {
  final String postID;
  final Map<String, dynamic>? publisherDataFromHome;
  final DocumentSnapshot<Object?>? postDataFromHome;

  const ViewPost({
    super.key,
    required this.postID,
    this.publisherDataFromHome,
    this.postDataFromHome,
  });

  @override
  Widget build(BuildContext context) {
    final postService = PostService();

    // if opened from HomePage and post data already provided
    if (postDataFromHome != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: MyAppbar(title: "View Post"),
        body: _buildView(context, postDataFromHome!, publisherDataFromHome),
      );
    }

    // otherwise fetch normally
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MyAppbar(title: "View Post"),
      body: StreamBuilder<DocumentSnapshot>(
        stream: postService.getPostByID(postID),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // post deleted or not found
          if (snapshot.hasData && !snapshot.data!.exists) {
            return const EmptyStateWidget(
              icon: Symbols.error_outline,
              title: "Post Unavailable",
              subtitle: "This post has been deleted or no longer exists.",
            );
          }

          final postDoc = snapshot.data!;
          return _buildView(context, postDoc, null);
        },
      ),
    );
  }

  Widget _buildView(BuildContext context, postData, publisherData) {
    final postService = PostService();
    final publisherID = postData['uid'];

    if (publisherDataFromHome != null) {
      return _buildContent(context, postData, publisherData);
    }

    return FutureBuilder<DocumentSnapshot>(
      future: postService.getPublisherByID(publisherID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Error loading publisher"));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final publisherData = snapshot.data!.data() as Map<String, dynamic>;
        return _buildContent(context, postData, publisherData);
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    DocumentSnapshot<Object?> postData,
    Map<String, dynamic> publisherData,
  ) {
    final bool isCurrentUser =
        postData['uid'] == FirebaseAuth.instance.currentUser!.uid;
    final String pubID = publisherData["uid"];
    final String pubName = publisherData["username"];
    final String name = isCurrentUser ? "You" : publisherData["username"];
    final String avatar = publisherData["avatar"];
    final String type = postData["type"];
    final DateTime createdAt = postData["createdAt"].toDate();
    final String pic = postData["picture"];
    final String title = postData["title"];
    final String desc = postData["description"];
    final Timestamp lostDate = postData["date"];
    final String location = postData["location"];
    final bool status = postData["claim_status"];
    final String category = postData["category"];

    final String statusText = postData["claim_status"]
        ? "Claimed"
        : "Unclaimed";
    final Color? statusColor = postData["claim_status"]
        ? Colors.teal[700]
        : Colors.red[700];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // publisher avatar
              UserAvatar(avatarUrl: avatar, radius: 22),
              const SizedBox(width: 8.0),

              // publisher name & publish time
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    DateFormats.formatPublishTime(createdAt),
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
              const Spacer(),

              // post type - lost or found
              Container(
                width: 64,
                height: 26,
                decoration: BoxDecoration(
                  color: type == "Lost" ? Colors.red[400] : Colors.teal[400],
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Center(
                  child: Text(
                    type,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12.0),
          const Divider(
            color: Color.fromARGB(255, 230, 230, 230),
            thickness: 1,
            height: 1,
          ),

          // item pic - only show image for Lost posts
          if (pic.isNotEmpty && type == "Lost" || isCurrentUser)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullScreenImage(imageUrl: pic),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    pic,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child; // image loaded

                      // while loading, show placeholder container
                      return Container(
                        width: double.infinity,
                        height: 200,
                        color: Colors.grey[300],
                      );
                    },
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12.0),

          // title
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color.fromARGB(255, 67, 17, 87),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6.0),

          // Show description - only if current user is the publisher or Lost
          if (type == "Lost" || isCurrentUser)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                desc,
                style: const TextStyle(fontSize: 14.0, height: 1.3),
              ),
            ),
          const SizedBox(height: 16.0),

          // details
          Column(
            children: [
              BigDetail(
                icon: Symbols.calendar_today,
                text: DateFormats.formatLostDate(lostDate),
              ),
              BigDetail(
                icon: Symbols.location_on, 
                text: location
              ),
              BigDetail(
                icon: Symbols.sell, 
                text: category
              ),
              BigDetail(
                icon: Symbols.task_alt,
                text: statusText,
                textColor: statusColor,
              ),
            ],
          ),
          const Spacer(),

          // chat button
          if (!isCurrentUser && status == false)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: AppButton(
                text: type == "Lost" ? "Return Item" : "Claim Item",
                icon: Symbols.chat_bubble,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      receiverID: pubID,
                      name: pubName,
                      avatar: avatar,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

