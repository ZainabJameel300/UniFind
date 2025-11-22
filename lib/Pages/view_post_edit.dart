import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:material_symbols_icons/symbols.dart';
import 'package:unifind/Components/app_button.dart';
import 'package:unifind/Components/fullscreen_image.dart';
import 'package:unifind/Components/my_appbar.dart';
import 'package:unifind/Components/post_actions.dart';
import 'package:unifind/Pages/potenialmatch.dart';
import 'package:unifind/utils/date_formats.dart';

class ViewPostEdit extends StatelessWidget {
  final String postID;

  const ViewPostEdit({super.key, required this.postID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MyAppbar(title: "View Post"),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .doc(postID)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("Error loading post", style: TextStyle(fontSize: 16)),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final postData = snapshot.data!;
          final String publisherID = postData['uid'];

          return FutureBuilder(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(publisherID)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text("Error loading publisher"));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final publisherData =
                  snapshot.data!.data() as Map<String, dynamic>;

              final bool isCurrentUser =
                  postData['uid'] == FirebaseAuth.instance.currentUser!.uid;

              // final String pubID = publisherData["uid"];
              final String name = isCurrentUser
                  ? "You"
                  : publisherData["username"];
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 25,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildAvatar(avatar),
                        const SizedBox(width: 8.0),

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
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),

                        Row(
                          children: [
                            Container(
                              width: 64,
                              height: 26,
                              decoration: BoxDecoration(
                                color: type == "Lost"
                                    ? Colors.red[400]
                                    : Colors.teal[400],
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Center(
                                child: Text(
                                  type,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 6),

                            // Menu
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                              icon: const Icon(
                                Icons.more_vert,
                                color: Color(0xFF771F98),
                                size: 28,
                              ),
                              onPressed: () {
                                PostActions.show(
                                  isClaimed: status,
                                  context: context,
                                  onToggleClaim: () async {
                                    final currentStatus =
                                        postData['claim_status'] as bool;

                                    await FirebaseFirestore.instance
                                        .collection('posts')
                                        .doc(postID)
                                        .update({
                                          'claim_status': !currentStatus,
                                        });
                                  },
                                  onViewMatches: () async {
                                    try {
                                      final List<dynamic>? textEmb =
                                          postData["embedding_text"];
                                      final List<dynamic>? imageEmb =
                                          postData["embedding_image"];
                                      final List<dynamic>? combinedEmb =
                                          postData["embedding_combined"];

                                      final String postType =
                                          postData["type"]; // "Lost" or "Found"

                                      // Does THIS post have an image saved?
                                      final bool postHasImage =
                                          imageEmb != null &&
                                          imageEmb.isNotEmpty;

                                      List<double>? embeddingToSend;
                                      bool hasImageFlag;

                                      // 🔹 If this is a FOUND post → we will match against LOST posts.
                                      //    We want TEXT vs TEXT (because some Lost posts have no image).
                                      if (postType == "Found") {
                                        if (textEmb == null) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Text embedding missing.",
                                              ),
                                            ),
                                          );
                                          return;
                                        }

                                        embeddingToSend = textEmb
                                            .cast<double>();
                                        hasImageFlag =
                                            false; // force server to treat caller as "no image"
                                      } else {
                                        // 🔹 For LOST posts:
                                        // If this Lost post has an image → use combined (text+image) vs combined.
                                        // If no image → use text vs text.
                                        if (postHasImage) {
                                          if (combinedEmb == null) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Combined embedding missing.",
                                                ),
                                              ),
                                            );
                                            return;
                                          }
                                          embeddingToSend = combinedEmb
                                              .cast<double>();
                                          hasImageFlag = true;
                                        } else {
                                          if (textEmb == null) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Text embedding missing.",
                                                ),
                                              ),
                                            );
                                            return;
                                          }
                                          embeddingToSend = textEmb
                                              .cast<double>();
                                          hasImageFlag = false;
                                        }
                                      }

                                      if (embeddingToSend.isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text("Embedding is empty"),
                                          ),
                                        );
                                        return;
                                      }

                                      // 2) Prepare payload for Flask ---
                                      final user =
                                          FirebaseAuth.instance.currentUser!;
                                      final Timestamp lostTS = postData["date"];

                                      final payload = {
                                        "embedding": embeddingToSend,
                                        "has_image": hasImageFlag,
                                        "uid": user.uid,
                                        "type": postData["type"],
                                        "postID": postID,
                                        "location": postData["location"],
                                        "date": {
                                          "_seconds": lostTS.seconds,
                                          "_nanoseconds": lostTS.nanoseconds,
                                        },
                                      };

                                      // 3) Send request to Flask server
                                      final String baseUrl = Platform.isAndroid
                                          ? 'http://10.0.2.2:5001'
                                          : 'http://192.168.1.3:5001';

                                      final response = await http.post(
                                        Uri.parse('$baseUrl/find_matches'),
                                        headers: {
                                          "Content-Type": "application/json",
                                        },
                                        body: jsonEncode(payload),
                                      );

                                      print("STATUS: ${response.statusCode}");
                                      print("BODY: ${response.body}");

                                      if (response.statusCode != 200) {
                                        print("Error: ${response.body}");
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Failed to fetch matches.",
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      //  4) Parse matches (recive respone from json and decode into a dart list )
                                      final data = jsonDecode(response.body);
                                      List matches = data["matches"] ?? [];

                                      final List<MatchItem> matchItems = matches
                                          .map((m) => MatchItem.fromJson(m))
                                          .toList();

                                      //  5) Navigate to PotentialMatch page to show the results
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => Potenialmatch(
                                            matchItems: matchItems,
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      print("Error fetching matches: $e");
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Something went wrong.",
                                          ),
                                        ),
                                      );
                                    }
                                  },

                                  onDeletePost: () {
                                    showDialog(
                                      context: context,
                                      builder: (dialogContext) => AlertDialog(
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        title: Row(
                                          children: const [
                                            Icon(
                                              Symbols.help_outline,
                                              color: Color(0xFF771F98),
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              "Delete this post?",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        content: const Text(
                                          "This action cannot be undone.",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        actions: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  dialogContext,
                                                ),
                                                child: const Text("Cancel"),
                                              ),

                                              SizedBox(width: 15),

                                              TextButton(
                                                onPressed: () async {
                                                  //  Close dialog
                                                  Navigator.pop(dialogContext);

                                                  // Immediately navigate back to AccountPage to avoid bad state
                                                  Navigator.pushReplacementNamed(
                                                    context,
                                                    'AccountPage',
                                                  );

                                                  // After navigation finishes, delete the post , delay a little bit!
                                                  Future.delayed(
                                                    Duration(milliseconds: 250),
                                                    () async {
                                                      try {
                                                        if (pic.isNotEmpty) {
                                                          final ref =
                                                              FirebaseStorage
                                                                  .instance
                                                                  .refFromURL(
                                                                    pic,
                                                                  );
                                                          await ref.delete();
                                                        }

                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection("posts")
                                                            .doc(postID)
                                                            .delete();
                                                      } catch (e) {
                                                        print(
                                                          "Error deleting post: $e",
                                                        );
                                                      }
                                                    },
                                                  );
                                                },
                                                style: TextButton.styleFrom(
                                                  foregroundColor: Colors.white,
                                                  backgroundColor: Color(
                                                    0xFF771F98,
                                                  ),
                                                ),
                                                child: const Text("Delete"),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12.0),
                    Divider(
                      color: const Color.fromARGB(255, 230, 230, 230),
                      thickness: 1,
                      height: 1,
                    ),

                    if (pic.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FullScreenImage(imageUrl: pic),
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

                    const SizedBox(height: 12.0),

                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color.fromARGB(255, 67, 17, 87),
                      ),
                    ),
                    const SizedBox(height: 6.0),

                    if (type == "Lost" || isCurrentUser)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          desc,
                          style: const TextStyle(fontSize: 14, height: 1.3),
                        ),
                      ),

                    const SizedBox(height: 16.0),

                    Column(
                      children: [
                        buildDetail(
                          Symbols.calendar_today,
                          "Date:",
                          DateFormats.formatLostDate(lostDate),
                        ),
                        buildDetail(Symbols.location_on, "Location:", location),
                        buildDetail(
                          Symbols.task_alt,
                          "Status:",
                          statusText,
                          valueColor: statusColor,
                        ),
                        buildDetail(Symbols.sell, "Category:", category),
                      ],
                    ),

                    const Spacer(),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AppButton(
                        text: status ? "Mark as Unclaimed" : "Mark as Claimed",
                        onTap: () async {
                          final currentStatus =
                              postData['claim_status'] as bool;

                          await FirebaseFirestore.instance
                              .collection('posts')
                              .doc(postID)
                              .update({'claim_status': !currentStatus});
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

Widget buildAvatar(String avatar) {
  if (avatar.isNotEmpty) {
    return CircleAvatar(radius: 22, backgroundImage: NetworkImage(avatar));
  } else {
    return const Icon(Icons.account_circle, size: 44, color: Colors.grey);
  }
}

Widget buildDetail(
  IconData icon,
  String label,
  String value, {
  Color? valueColor,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Row(
      children: [
        Icon(icon, color: const Color(0xFFD0B1DB), size: 24),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[800],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: TextStyle(fontSize: 14, color: valueColor ?? Colors.grey[800]),
        ),
      ],
    ),
  );
}
