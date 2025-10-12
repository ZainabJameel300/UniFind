import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unifind/Components/app_button.dart';
import 'package:unifind/Components/fullscreen_image.dart';
import 'package:unifind/Components/my_appbar.dart';
import 'package:unifind/utils/date_formats.dart';
import 'package:unifind/pages/chat_page.dart';

class ViewPost extends StatelessWidget {
  final Map<String, dynamic> publisherData;
  final DocumentSnapshot<Object?> postData;

  const ViewPost({
    super.key,
    required this.publisherData,
    required this.postData,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCurrentUser = postData['uid'] == FirebaseAuth.instance.currentUser!.uid;
    final String pubID = publisherData["uid"];
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

    final String statusText = postData["claim_status"] ? "Claimed" : "Unclaimed";
    final Color? statusColor = postData["claim_status"] ? Colors.teal[700] : Colors.red[700];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MyAppbar(title: "View Post"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // publisher avatar
                buildAvatar(avatar),
                const SizedBox(width: 8.0),
        
                // publisher name & publish time
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
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
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
        
            SizedBox(height: 12.0),
            Divider(color: const Color.fromARGB(255, 230, 230, 230), thickness: 1, height: 1),
        
            // item pic - only show image for "Lost" type posts
            if (pic.isNotEmpty && type == "Lost")
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
                    ),
                  ),
                ),
              ),
            SizedBox(height: 12.0),
        
            // title
            Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: const Color.fromARGB(255, 67, 17, 87),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6.0),
        
            // Show description - only for "Lost" type or if current user is the publisher
            if (type == "Lost" || isCurrentUser)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  desc,
                  style: TextStyle(fontSize: 14.0, height: 1.3),
                ),
              ),
            const SizedBox(height: 16.0),
        
            // details row
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // post date
                buildDetail(
                  Icons.calendar_today_outlined, 
                  "Date:", DateFormats.formatLostDate(lostDate),
                ),
                // item location
                buildDetail(
                  Icons.location_on_outlined, 
                  "Location:", location,
                ),
                // item status
                buildDetail(
                  Icons.task_alt_outlined, 
                  "Status:", statusText, 
                  valueColor: statusColor,
                ),
                // category
                buildDetail(
                  Icons.sell_outlined, "Category:", 
                  category,
                ),
              ],
            ),
            Spacer(),

            // chat button
            if (!isCurrentUser && status == false) 
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AppButton(
                text: "Chat",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ChatPage(receiverID: pubID),
                  ),
                )
              ),
            ),
          ],
        ),
      ),
    );
  }
}


Widget buildAvatar(String avatar) {
  if (avatar.isNotEmpty) {
    return CircleAvatar(radius: 22, backgroundImage: NetworkImage(avatar));
  } else {
    return const Icon(Icons.account_circle, size: 22*2, color: Colors.grey);
  }
}

Widget buildDetail(IconData icon, String label, String value, {Color? valueColor}){
  return Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Row(
      children: [
        Icon(icon, color: const Color(0xFFD0B1DB), size: 24.0),
        const SizedBox(width: 8.0),
        Text(
          label, 
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.grey[800],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 6.0),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.0, 
            color: valueColor ?? Colors.grey[800],
          ),
        ),
      ],
    ),
  );
}
