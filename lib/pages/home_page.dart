import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unifind/Components/filters_tabs.dart';
import 'package:unifind/components/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unifind/providers/filter_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // all posts
  // final Stream<QuerySnapshot> _postStream = FirebaseFirestore.instance
  //     .collection('posts')
  //     .orderBy('createdAt', descending: true)
  //     .snapshots();

  // get filtered posts
  Stream<QuerySnapshot> _getFilteredPosts() {
    final filterProvider = Provider.of<FilterProvider>(context);

    Query query = FirebaseFirestore.instance
        .collection('posts')
        .orderBy('createdAt', descending: true);

    // type filter
    final String? selectedtype = filterProvider.postType;
    if (selectedtype != null && selectedtype != "All") {
      query = query.where('type', isEqualTo: selectedtype);
    }
    // claim statuses filter
    final bool? statusBool = filterProvider.getBooleanStatus;
    if (statusBool != null) {
      query = query.where('claim_status', isEqualTo: statusBool);
    }
    // categories filter
    final Set<String> categories = filterProvider.selectedCategories;
    if (categories.isNotEmpty && categories.length != 7 ) {
      query = query.where('category', whereIn: categories.toList());
    }

    return query.snapshots();
  }

  // to get post publisher data
  CollectionReference publishers = FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Column(
                children: [
                  // search & notifications
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            color: const Color(0xFFF1F1F1),
                          ),
                          child: const Row(
                            children: [
                              // search
                              Icon(Icons.search),
                              SizedBox(width: 5.0),
                              Text(
                                "Search Items",
                                style: TextStyle(fontSize: 16.0),
                              ),
                              Spacer(),
                              // AI search (camera)
                              Icon(Icons.photo_camera_outlined),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),

                      // notifications 
                      Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          color: const Color(0xFFF1F1F1),
                        ),
                        child: const Icon(Icons.notifications_outlined),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4.0),

                  // filters 
                  Row(
                    children: [
                      // post type toggle ( All, found, lost )
                      const FiltersTabs(),
                      const Spacer(),
                      // drawer button to filter by status & categorey
                      Builder(
                        builder: (context) {
                          return GestureDetector(
                            onTap: () {
                              Scaffold.of(context).openEndDrawer();
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(Icons.filter_alt_outlined),
                                Icon(Icons.density_medium, size: 18.0,),
                              ],
                            ),
                          );
                        }
                      ),                 
                    ],
                  ),                    
                  SizedBox(height: 4.0),
                ],
              ),
            ),
            Divider(color: Color(0xFF8C8C8C), thickness: 1, height: 1,),
      
            // posts
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0,),
                // read posts data
                child: StreamBuilder(
                  stream: _getFilteredPosts(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: const Text("Error"));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: const CircularProgressIndicator());
                    }
                    // no post found
                    final posts = snapshot.data!.docs;
                    if (posts.isEmpty) {
                      bool hasAnyFilter = Provider.of<FilterProvider>(context, listen: false).hasAnyFilter;
                      return Center(
                        child: Text(
                          hasAnyFilter ? "No results for current filters" : "No posts yet",
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot postData = snapshot.data!.docs.elementAt(index);
                        bool isCurrentUser = postData['uid'] == FirebaseAuth.instance.currentUser!.uid;
                        String uid = postData["uid"];

                        // read the publisher data for each post
                        return FutureBuilder<DocumentSnapshot>(
                          future: publishers.doc(uid).get(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(child: Text("Error"));
                            }

                            if (snapshot.connectionState == ConnectionState.done) {
                              Map<String, dynamic> publisherData = snapshot.data!.data() as Map<String, dynamic>;
                              
                              return Post(
                                isCurrentUser: isCurrentUser,
                                publisherAvatar: publisherData["avatar"],
                                publisherName: publisherData["username"],
                                publisherID: postData["uid"],
                                createdAt: postData["createdAt"].toDate(),
                                type: postData["type"],
                                pic: postData["picture"],
                                title: postData["title"],
                                description: postData["description"],
                                date: postData["date"],
                                location: postData["location"],
                                status: postData["claim_status"],
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
