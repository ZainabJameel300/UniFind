import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unifind/Components/empty_state_widget.dart';
import 'package:unifind/Components/fullscreen_image.dart';
import 'package:unifind/Components/my_appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:unifind/Pages/view_post.dart';
import 'package:unifind/utils/date_formats.dart';

class MatchItem {
  final String postID;
  final String title;
  final String type;
  final String location;
  final String picture;
  final double similarity;

  MatchItem({
    required this.postID,
    required this.title,
    required this.type,
    required this.location,
    required this.picture,
    required this.similarity,
  });

  factory MatchItem.fromJson(Map<String, dynamic> json) {
    return MatchItem(
      postID: json['postID'],
      title: json['title'],
      type: json['type'],
      location: json['location'] ?? "",
      picture: json['picture'] ?? "",
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

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection("posts")
                        .doc(match.postID)
                        .get(),
                    builder: (context, postSnapshot) {
                      if (!postSnapshot.hasData || !postSnapshot.data!.exists) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final postData =
                          postSnapshot.data!.data() as Map<String, dynamic>;
                      final uid = postData["uid"];

                      return FutureBuilder<Map<String, dynamic>>(
                        future: _getUserData(uid),
                        builder: (context, userSnapshot) {
                          if (!userSnapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final user = userSnapshot.data!;
                          final name = user["username"] ?? "Unknown";
                          final avatar = user["avatar"] ?? "";
                          final date = DateFormats.formatLostDate(
                            postData["date"],
                          );
                          final location = postData["location"] ?? "";

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
                                        avatar.isNotEmpty
                                            ? CircleAvatar(
                                                radius: 16,
                                                backgroundImage: NetworkImage(
                                                  avatar,
                                                ),
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
                                  // Thin divider under avatar and username
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
                                  // Image (clickable to view fullscreen)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 5,
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                FullScreenImage(
                                                  imageUrl: match.picture,
                                                ),
                                          ),
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: Image.network(
                                          match.picture,
                                          width: double.infinity,
                                          height: 100, // smaller height
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
                                  // Date & Location side by side
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
                                          weight: 800,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          date,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: const Color.fromARGB(
                                              255,
                                              62,
                                              62,
                                              62,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Icon(
                                          Symbols.location_on,
                                          size: 14,
                                          color: Color(0xFFD0B1DB),
                                          weight: 800,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            location,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: const Color.fromARGB(
                                                255,
                                                62,
                                                62,
                                                62,
                                              ),
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
