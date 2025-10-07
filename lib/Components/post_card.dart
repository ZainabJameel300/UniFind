import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unifind/Pages/view_post.dart';
import 'package:unifind/components/post_detail.dart';
import '../utils/date_formats.dart';

class PostCard extends StatelessWidget {
  final Map<String, dynamic> publisherData;
  final DocumentSnapshot<Object?> postData;

  const PostCard({
    super.key,
    required this.publisherData,
    required this.postData,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCurrentUser = postData['uid'] == FirebaseAuth.instance.currentUser!.uid;
    final String name = isCurrentUser ? "You" : publisherData["username"];
    final String avatar = publisherData["avatar"];
    final String type = postData["type"];
    final DateTime createdAt = postData["createdAt"].toDate();
    final String pic = postData["picture"];
    final String title = postData["title"];
    final String desc = postData["description"];
    final Timestamp lostDate = postData["date"];
    final String location = postData["location"];

    // go to view post page
    void viewPost(){         
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ViewPost(
            publisherData: publisherData,
            postData: postData,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => viewPost(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0), 
          border: Border.all(
            color: const Color(0xFF771F98), 
            width: 1.5,
          ),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8.0,), 
        child: Padding(
        padding: const EdgeInsets.all(15.0),
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
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormats.formatPublishTime(createdAt),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                const Spacer(),
      
                // post type - lost or found
                Container(
                  width: 55,
                  height: 22,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Center(
                    child: Text(
                      type,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                ),
              ],
            ),
      
            SizedBox(height: 10.0),
            Divider(color: Colors.grey[400], thickness: 1, height: 1),
                    
            // item pic 
            if (pic.isNotEmpty && type == "Found")
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: ClipRRect( 
                borderRadius: BorderRadius.circular(8.0,),
                child: Image.network(
                  pic,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 180,
                ),   
              ),
            ),
            SizedBox(height: 10.0),
              
            // title
            Row(
              children: [
                Text(
                  title, 
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 16, 
                    color: const Color.fromARGB(255, 67, 17, 87),
                    ),
                ),
              ],
            ),
            const SizedBox(height: 5.0),
              
            // description 
            if(type == "Found")
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Text(
                desc,
                maxLines: pic.isNotEmpty ? 2 : 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13.0, height: 1.3),
              ),
            ),
        
            // details row
            Padding(
              padding: const EdgeInsets.only(top: 6, right: 10, left: 10, bottom: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // post date
                  PostDetail(
                    icon: Icons.calendar_today_outlined, 
                    text: DateFormats.formatLostDate(lostDate),
                  ),
                    
                  // item location
                  PostDetail(
                    icon: Icons.location_on_outlined, 
                    text: location,
                  ),

                  GestureDetector(
                    onTap: () => viewPost(),
                    child: PostDetail(
                      icon: Icons.arrow_forward,
                      text: "View Post",
                      textColor: const Color.fromARGB(255, 67, 17, 87),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),),
      ),
    );
  }
}

Widget buildAvatar(String avatar) {
  if (avatar.isNotEmpty) {
    return CircleAvatar(radius: 20, backgroundImage: NetworkImage(avatar));
  } else {
    return const Icon(Icons.account_circle, size: 20*2, color: Colors.grey);
  }
}



