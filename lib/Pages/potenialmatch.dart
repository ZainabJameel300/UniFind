import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unifind/Components/empty_state_widget.dart';
import 'package:unifind/Components/fullscreen_image.dart';
import 'package:unifind/Components/my_appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:material_symbols_icons/symbols.dart';
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

      // Wrap body with a Stack so we can overlay the floating message
      body: Stack(
        children: [
          widget.matchItems.isEmpty
              ? const EmptyStateWidget(
                  icon: Symbols.empty_dashboard,
                  title: "No Items found",
                  subtitle:
                      "You'll get notified when any of your items get matched!",
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 30,
                  ),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
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
                                  postSnapshot.data!.data()
                                      as Map<String, dynamic>;
                              final Timestamp ts = postData["date"];
                              final formattedDate = DateFormats.formatLostDate(
                                ts,
                              );

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
                                      color: Color(0xFFE6E6E6),
                                      width: 1.7,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(
                                          0xFF771F98,
                                        ).withValues(alpha: 0.1),
                                        blurRadius: 20,
                                        offset: const Offset(1, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                            avatar.isNotEmpty
                                                ? CircleAvatar(
                                                    radius: 16,
                                                    backgroundImage:
                                                        NetworkImage(avatar),
                                                  )
                                                : const Icon(
                                                    Icons.account_circle,
                                                    size: 32,
                                                    color: Colors.grey,
                                                  ),
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
                                          onTap: () {
                                            if (match.picture.isNotEmpty) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      FullScreenImage(
                                                        imageUrl: match.picture,
                                                      ),
                                                ),
                                              );
                                            }
                                          },
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            child: match.picture.isNotEmpty
                                                ? Image.network(
                                                    match.picture,
                                                    width: double.infinity,
                                                    height: 100,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Image.asset(
                                                    "assets/no-pictures.png",
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
                                          left: 10,
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

                                      // Date
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          8,
                                          10,
                                          8,
                                          4,
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Symbols.calendar_today,
                                              size: 14,
                                              color: Color(0xFFD0B1DB),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              formattedDate,
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 5),

                                      // Location
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          8,
                                          0,
                                          8,
                                          8,
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Symbols.location_on,
                                              size: 14,
                                              color: Color(0xFFD0B1DB),
                                            ),
                                            const SizedBox(width: 6),
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

          //Message "Not what you're looking for?"
          if (widget.matchItems.isNotEmpty)
            Positioned(
              left: 16,
              right: 16,
              bottom: 182,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Not what you're looking for?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF771F98),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "You'll get notified when new matches are found.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
