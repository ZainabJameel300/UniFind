import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unifind/Components/app_button.dart';
import 'package:unifind/Components/my_AppBar.dart';
import 'package:unifind/helpers/timestamp_format.dart';
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
    bool isCurrentUser = postData['uid'] == FirebaseAuth.instance.currentUser!.uid;
    final name = isCurrentUser ? "You" : publisherData["username"];
    final statusText = postData["claim_status"] ? "Claimed" : "Unclaimed";
    final statusColor = postData["claim_status"] ? Colors.green[700] : Colors.red[700];

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
                buildAvatar(publisherData["avatar"]),
                const SizedBox(width: 8.0),
        
                // publisher name & publish time
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // chat button
                        if (!isCurrentUser)
                          GestureDetector(
                            onTap: () {
                              // go to publisher chat page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ChatPage(receiverID: publisherData["uid"]),
                                ),
                              );
                            },
                            child: Icon(
                              Icons.chat_rounded,
                              color: Color(0xFFD0B1DB),
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                    Text(
                      TimestampFormat.getFormat(postData["createdAt"].toDate()),
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
                const Spacer(),
        
                // post type - lost or found
                Container(
                  width: 60,
                  height: 25,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Center(
                    child: Text(
                      postData["type"],
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ),
                ),
              ],
            ),
        
            SizedBox(height: 14.0),
            Divider(color: Colors.grey[400], thickness: 1, height: 1),
        
            // item pic
            if (postData["picture"].isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    postData["picture"],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 180,
                  ),
                ),
              ),
            SizedBox(height: 14.0),
        
            // title
            Row(
              children: [
                Text(
                  postData["title"],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: const Color.fromARGB(255, 67, 17, 87),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6.0),
        
            // description
            Text(
              postData["description"],
              style: TextStyle(fontSize: 14.0, height: 1.3),
            ),
            const SizedBox(height: 26.0),
        
            // details row
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // post date
                buildDetail(Icons.calendar_today_outlined, "Date:", postData["date"]),
                // item location
                buildDetail(Icons.location_on_outlined, "Location:", postData["location"]),
                // item status
                buildDetail(Icons.task_alt_outlined, "Status:", statusText, valueColor: statusColor),
                // category
                buildDetail(Icons.sell_outlined, "Category:", postData["category"]),
              ],
            ),
            Spacer(),

            // user item? -> verify owner 
            if(!isCurrentUser && postData["type"] == "Found")
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AppButton(
                text: "Verify",
                onTap: () {},
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
