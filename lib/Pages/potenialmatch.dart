import 'package:flutter/material.dart';
import 'package:unifind/Components/empty_state_widget.dart';
import 'package:unifind/Components/my_appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:unifind/Components/fullscreen_image.dart';
import 'package:unifind/Components/user_avatar.dart';
import 'package:unifind/Pages/view_post.dart';
import 'package:unifind/utils/date_formats.dart';

//this is a model that recives these fields from the report item page, which recived it from flask!!
class MatchItem {
  final String postID;
  final String uid;
  final String title;
  final String type;
  final String location;
  final String picture;
  final String date;
  final double similarity;

  MatchItem({
    required this.postID,
    required this.uid,
    required this.title,
    required this.type,
    required this.location,
    required this.picture,
    required this.date,
    required this.similarity,
  });

  //convert from json to dart map
  factory MatchItem.fromJson(Map<String, dynamic> json) {
    return MatchItem(
      postID: json['postID'],
      uid: json['uid'] ?? "",
      title: json['title'],
      type: json['type'],
      location: json['location'] ?? "",
      picture: json['picture'] ?? "",
      date: json['date']?.toString() ?? "",
      similarity: json['similarity_score']?.toDouble() ?? 0.0,
    );
  }
}

class Potenialmatch extends StatefulWidget {
  final List<MatchItem> matchItems;
  const Potenialmatch({super.key, required this.matchItems});

  @override
  State<Potenialmatch> createState() => _PotenialmatchState();
}

class _PotenialmatchState extends State<Potenialmatch> {
  //this method takes the uid saved in the post to serach for the matched items posters information(avatar,username)
  Future<Map<String, dynamic>> _getUserData(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    return doc.data() ?? {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MyAppbar(
        title: "Potential Matches",
        onBack: () => Navigator.pushReplacementNamed(context, 'bottomnavBar'),
      ),

      //if matchitem map is empty display Empty message else build the grid
      body: widget.matchItems.isEmpty
          ? const EmptyStateWidget(
              icon: Symbols.empty_dashboard,
              title: "No Items found",
              subtitle:
                  "You'll get notified when any of your items get matched!",
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 15,
                  childAspectRatio: 0.80,
                ),
                itemCount: widget.matchItems.length,
                itemBuilder: (context, index) {
                  final match = widget.matchItems[index];

                  return FutureBuilder<Map<String, dynamic>>(
                    future: _getUserData(match.uid),
                    builder: (context, userSnapshot) {
                      if (!userSnapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final user = userSnapshot.data!;
                      final name = user["username"] ?? "Unknown";
                      final avatar = user["avatar"] ?? "";

                      //  Fetch the real post document to get the true Timestamp date
                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection("posts")
                            .doc(match.postID)
                            .get(),
                        builder: (context, postSnapshot) {
                          if (!postSnapshot.hasData ||
                              !postSnapshot.data!.exists) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final postData =
                              postSnapshot.data!.data() as Map<String, dynamic>;
                          final Timestamp ts = postData["date"];
                          final formattedDate = DateFormats.formatLostDate(ts);

                          return GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ViewPost(postID: match.postID),
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: const Color(0xFFE0D9E6),
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 20,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Top bar: avatar + name
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      8,
                                      8,
                                      8,
                                      0,
                                    ),
                                    child: Row(
                                      children: [
                                        UserAvatar(avatarUrl: avatar, radius: 16),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            name,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Divider
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: Divider(
                                      color: Colors.grey[300],
                                      thickness: 1,
                                      height: 8,
                                    ),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: GestureDetector(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => FullScreenImage(
                                            imageUrl: match.picture,
                                          ),
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: Image.network(
                                          match.picture,
                                          width: double.infinity,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Title
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 8,
                                      top: 8,
                                    ),
                                    child: Text(
                                      match.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Color(0xFF771F98),
                                      ),
                                    ),
                                  ),

                                  // Date & Location
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      8,
                                      10,
                                      8,
                                      8,
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Symbols.calendar_today,
                                          size: 14,
                                          color: Color(0xFFD0B1DB),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          formattedDate,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        const SizedBox(width: 12),
                                        const Icon(
                                          Symbols.location_on,
                                          size: 14,
                                          color: Color(0xFFD0B1DB),
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            match.location,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}
