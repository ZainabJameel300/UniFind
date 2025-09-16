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
            children: [     
              // publisher avatar
              buildAvatar(publisherAvatar), 
              const SizedBox(width: 8.0),

              // publisher name & publish time
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                  ),
                  Text(
                    TimestampFormat.getFormat(createdAt),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12.0),
                  ),
                ],
              ),

              const Spacer(),
                    
              // chat button
              if (!isCurrentUser) 
                GestureDetector( 
                  onTap: () { 
                    // go to publisher chat page 
                    Navigator.push(
                      context, 
                      MaterialPageRoute( 
                        builder: (context) => ChatPage(
                          receiverID: publisherID, 
                        ),
                      ),
                    ); 
                  },
                  child: Row(
                    children: [
                      Icon(Icons.chat_bubble, color: Color(0xFFD0B1DB), size: 20.0),
                      const SizedBox(width: 3),
                      Text("Chat", style: TextStyle(fontSize: 13.0)),
                    ],
                  ),
                ),
            ],
          ),

          SizedBox(height: 12.0),
          Divider(color: Color(0xFF8C8C8C), thickness: 1, height: 1),
                  
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
          SizedBox(height: 12.0),
            
          // title
          Row(
            children: [
              Text(
                title, 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
              ),
            ],
          ),
          const SizedBox(height: 5.0),
            
          // description 
          Text(
            description,
            style: TextStyle(fontSize: 14.0), 
          ),
      
          // details row
          Padding(
            padding: const EdgeInsets.only(top: 15, right: 10, left: 10, bottom: 10),
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



