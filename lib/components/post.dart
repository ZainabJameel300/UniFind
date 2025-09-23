import 'package:flutter/material.dart';
import 'package:unifind/components/post_detail.dart';
import 'package:unifind/pages/chat_page.dart';
import '../helpers/timestamp_format.dart';

class Post extends StatelessWidget {
  final bool isCurrentUser;
  final String publisherAvatar;
  final String publisherName;
  final String publisherID; 
  final DateTime createdAt;
  final String type;
  final String pic;
  final String title;
  final String description;
  final String date;
  final String location;
  final bool status;

  const Post({
    super.key,
    required this.isCurrentUser,
    required this.publisherAvatar,
    required this.publisherName,
    required this.publisherID,
    required this.createdAt,
    required this.type,
    required this.pic,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.status, 
  });

  @override
  Widget build(BuildContext context) {
    final name = isCurrentUser ? "You" : publisherName;
    final statusText = status ? "Claimed" : "Unclaimed";
    final statusColor = status ? Colors.green[700] : Colors.red[700];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0), 
        border: Border.all(
          color: const Color.fromARGB(255, 119, 31, 153), 
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
              buildAvatar(publisherAvatar), 
              const SizedBox(width: 8.0),

              // publisher name & publish time
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
                                    ChatPage(receiverID: publisherID),
                              ),
                            );
                          },
                          child: Icon(Icons.chat_rounded, color: Color(0xFFD0B1DB), size: 18),
                        ),
                    ],
                  ),
                  Text(
                    TimestampFormat.getFormat(createdAt),
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
          if (pic.isNotEmpty)
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
            
          // description - less lines with pic
          Text(
            description,
            maxLines: pic.isNotEmpty ? 1 : 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13.0, height: 1.3),
          ),
      
          // details row
          Padding(
            padding: const EdgeInsets.only(top: 15, right: 10, left: 10, bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // post date
                PostDetail(
                  icon: Icons.calendar_today_outlined, 
                  text: date,
                ),
                  
                // item location
                PostDetail(
                  icon: Icons.location_on_outlined, 
                  text: location,
                ),
                  
                // item status
                PostDetail(
                  icon: Icons.task_alt_outlined, 
                  text: statusText,
                  textColor: statusColor,
                ),
              ],
            ),
          ),
        ],
      ),),
    );
  }
}

Widget buildAvatar(String avatar) {
  if (avatar.isNotEmpty) {
    // Show uploaded picture
    return CircleAvatar(radius: 24, backgroundImage: NetworkImage(avatar));
  } else {
    // Show default avatar
    return const Icon(Icons.account_circle, size: 40, color: Colors.grey);
  }
}



