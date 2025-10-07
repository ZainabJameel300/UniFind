import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unifind/Components/filters_tabs.dart';
import 'package:unifind/Components/post_card.dart';
import 'package:unifind/Components/post_search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unifind/providers/filter_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // get filtered posts
  Stream<QuerySnapshot> _getFilteredPosts() {
    final filterProvider = Provider.of<FilterProvider>(context);

    Query query = FirebaseFirestore.instance
        .collection('posts')
        .orderBy('createdAt', descending: true);

    // type filter
    final String selectedtype = filterProvider.postType;
    if (selectedtype != "All") {
      query = query.where('type', isEqualTo: selectedtype);
    }

    // categories filter
    final String? selectedCategory = filterProvider.selectedCategory;
    if (selectedCategory != null) {
      query = query.where('category', isEqualTo: selectedCategory);
    }

    // location filter
    final String? selectedLocation = filterProvider.selectedLocation;
    if (selectedLocation != null) {
      query = query.where('location', isEqualTo: selectedLocation);
    }
    
    // date filter
    final String? selectedDate = filterProvider.selectedDate;
    if (selectedDate != null) {
      final now = DateTime.now();
      DateTime? start;
      DateTime? end;

      switch (selectedDate) {
        case "Today":
          start = DateTime(now.year, now.month, now.day);
          end = start.add(const Duration(days: 1));
          break;

        case "This week":
          int daysSinceSunday = now.weekday % 7; 
          start = DateTime(now.year, now.month, now.day - daysSinceSunday);
          end = start.add(const Duration(days: 7));
          break;

        case "This month":
          start = DateTime(now.year, now.month, 1);
          end = DateTime(now.year, now.month + 1, 1);
          break;

        case "Last 3 months":
          start = DateTime(now.year, now.month - 3, now.day);
          end = now;
          break;

        case "Last 6 months":
          start = DateTime(now.year, now.month - 6, now.day);
          end = now;
          break;
      }

      query = query
          .where('date', isGreaterThanOrEqualTo: start)
          .where('date', isLessThan: end);
    }

    return query.snapshots();
  }

  // to get post publisher data
  CollectionReference publishers = FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    bool hasAnyFilter = Provider.of<FilterProvider>(context, listen: false).hasAnyFilter;
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
                        child: GestureDetector(
                          onTap: () {
                            showSearch(
                              context: context,
                              delegate: PostSearch(),
                            );
                          },
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


                  // filters 
                  Row(
                    children: [
                      // post type toggle ( All, found, lost )
                      const FiltersTabs(),
                      const Spacer(),
                      // drawer filter for categorey, location, date
                      Builder(
                        builder: (context) {
                          return GestureDetector(
                            onTap: () {
                              Scaffold.of(context).openEndDrawer();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(Icons.filter_alt_outlined, color: hasAnyFilter
                                      ? const Color(0xFF771F98)
                                      : Colors.black,
                                ),
                                Icon(Icons.density_medium, size: 18.0, color: hasAnyFilter
                                      ? const Color(0xFF771F98)
                                      : Colors.black,
                                ),
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
                      return Center(child: const Text("Error", style: TextStyle(fontSize: 16)));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: const CircularProgressIndicator());
                    }
                    // no post found
                    final posts = snapshot.data!.docs;
                    if (posts.isEmpty) {
                      return Center(
                        child: Text(
                          hasAnyFilter ? "No results for current filters" : "No posts yet",
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot postData = snapshot.data!.docs.elementAt(index);
                        String uid = postData["uid"];

                        // read the publisher data for each post
                        return FutureBuilder<DocumentSnapshot>(
                          future: publishers.doc(uid).get(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(child: Text("Error", style: TextStyle(fontSize: 16)));
                            }

                            if (snapshot.connectionState == ConnectionState.done) {
                              Map<String, dynamic> publisherData = snapshot.data!.data() as Map<String, dynamic>;
                              
                              return PostCard(
                                publisherData: publisherData,
                                postData: postData,
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
