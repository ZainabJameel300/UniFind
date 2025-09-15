import 'package:flutter/material.dart';
import 'package:unifind/components/post_detail.dart';

class Post extends StatelessWidget {
  // final String avatar;
  // final String username;
  final String uid; // for chat
  final String createdAt;
  final String pic;
  final String title;
  final String description;
  final String date;
  final String location;
  final bool status;

  const Post({
    super.key,
    // required this.avatar,
    // required this.username,
    required this.uid,
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
              // user avatar
              // buildAvatar(avatar), 
              Icon(Icons.account_circle, size: 40, color: Colors.grey),

              SizedBox(width: 8.0),
            
              // user name
              Text(
                "Bessie Cooper", 
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              SizedBox(width: 10.0),
              
              // post time
              Text(
                "9:29",
                style: TextStyle(
                  color: Colors.black45, 
                  fontSize: 13.0,
                  fontWeight: FontWeight.w400
                ),
              ),
                    
              Spacer(),
            
              // chat button
              Icon(Icons.chat_bubble, color: Color(0xFFD0B1DB), size: 20.0,),
              SizedBox(width: 3.0),
              Text("Chat", style: TextStyle(fontSize: 16.0,)),
            ],
          ),

          SizedBox(height: 10.0),
          Divider(color: Color(0xFF8C8C8C), thickness: 1, height: 1),
                  
          // item pic 
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: ClipRRect(
              child: pic.isEmpty ? SizedBox(height: 3.0) :
              Image.asset(
                'lib/images/brownWatch.jpg',
                fit: BoxFit.cover,
                width: double.infinity,
                height: 180,
              ),
            ),
          ),
            
          // title
          Row(
            children: [
              Text(
                title, 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0),
              ),
            ],
          ),
          const SizedBox(height: 5.0),
            
          // description 
          Text(
            description,
            style: TextStyle(fontSize: 13.0), 
          ),
      
          // details row
          Padding(
            padding: const EdgeInsets.all(15.0),
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
