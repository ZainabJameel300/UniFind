import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unifind/Components/fullscreen_image.dart';
import 'package:unifind/Pages/view_post.dart';
import 'package:unifind/components/post_detail.dart';
import 'package:unifind/utils/date_formats.dart';

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
    final String category = postData["category"];

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
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 10), 
        child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [     
                // publisher avatar
                _buildAvatar(avatar), 
                const SizedBox(width: 8.0),
      
                // publisher name & publish time
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    Text(
                      DateFormats.formatPublishTime(createdAt),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                const Spacer(),
      
                // post type - lost or found
                Container(
                  width: 56,
                  height: 22,
                  decoration: BoxDecoration(
                    color: type == "Lost" ? Colors.red[400] : Colors.teal[400],
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Center(
                    child: Text(
                      type,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.0),
          
            if (type == "Found" || (pic.isEmpty && type == "Lost"))
            Divider(color: const Color.fromARGB(255, 230, 230, 230), thickness: 1, height: 1),
                    
            // item pic 
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
            SizedBox(height: 8.0),
              
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
            const SizedBox(height: 4.0),
              
            // description 
            if(type == "Lost")
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
              padding: const EdgeInsets.only(top: 4, right: 6, left: 6, bottom: 6),
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
                  
                  // item category
                  PostDetail(
                    icon: Icons.sell_outlined,
                    text: category,
                  ),
                ],
              ),
            ),
          ],
        ),),
      ),
    );
  }
  Widget _buildAvatar(String avatar) {
    if (avatar.isNotEmpty) {
      return CircleAvatar(radius: 20, backgroundImage: NetworkImage(avatar));
    } else {
      return const Icon(Icons.account_circle, size: 20*2, color: Colors.grey);
    }
  }
}



