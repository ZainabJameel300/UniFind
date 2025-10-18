import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:unifind/Components/empty_state_widget.dart';
import 'package:unifind/Components/filters_tabs.dart';
import 'package:unifind/Components/my_search_delegate.dart';
import 'package:unifind/Components/post_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unifind/Pages/notifications_page.dart';
import 'package:unifind/providers/filter_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // get filtered posts
  Stream<QuerySnapshot> _getFilteredPosts() {
    final filterProvider = Provider.of<FilterProvider>(context, listen: false);
    Query query = FirebaseFirestore.instance
        .collection('posts')
        .orderBy('createdAt', descending: true);

    // type filter
    final String selectedtype = filterProvider.postType;
    if (selectedtype != "All") {
      query = query.where('type', isEqualTo: selectedtype);
    }

    // drawer filters
    if (filterProvider.hasAnyFilter) {
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
            start = DateTime(now.year, now.month, now.day - (now.weekday % 7));
            end = start.add(const Duration(days: 7));
            break;

          case "This month":
            start = DateTime(now.year, now.month, 1);
            end = DateTime(now.year, now.month + 1, 1);
            break;

          case "Last 3 months":
            start = DateTime(now.year, now.month - 3, now.day);
            end = now.add(const Duration(days: 1));
            break;

          case "Last 6 months":
            start = DateTime(now.year, now.month - 6, now.day);
            end = now.add(const Duration(days: 1));
            break;
        }

        query = query
            .where('date', isGreaterThanOrEqualTo: start)
            .where('date', isLessThan: end);
      }
    }

    return query.snapshots();
  }

  // to get post publisher data
  CollectionReference publishers = FirebaseFirestore.instance.collection(
    'users',
  );

  // get notifications count
  Stream<int> unreadNotificationsCount() {
    return FirebaseFirestore.instance
        .collection('notifications')
        .where('toUserID', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  @override
  Widget build(BuildContext context) {
    bool hasAnyFilter = Provider.of<FilterProvider>(context).hasAnyFilter;

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
                              delegate: MySearchDelegate(),
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
                                Icon(Symbols.search),
                                SizedBox(width: 5.0),
                                Text(
                                  "Search",
                                  style: TextStyle(fontSize: 16.0),
                                ),
                                Spacer(),
                                // AI search (camera)
                                Icon(Symbols.photo_camera, size: 24),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),

                      // notifications
                      StreamBuilder<int>(
                        stream: unreadNotificationsCount(),
                        builder: (context, snapshot) {
                          final int count = snapshot.data ?? 0;

                          return GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NotificationsPage(),
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.0),
                                color: const Color(0xFFF1F1F1),
                              ),
                              child: Badge(
                                backgroundColor: const Color(0xFF771F98),
                                label: Text(
                                  count.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                ),
                                isLabelVisible: count > 0,
                                alignment: Alignment.topRight,
                                offset: const Offset(5, -2),
                                child: const Icon(
                                  Symbols.notifications,
                                  size: 24,
                                ),
                              ),
                            ),
                          );
                        },
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
                                Icon(
                                  Symbols.filter_alt,
                                  color: hasAnyFilter
                                      ? const Color(0xFF771F98)
                                      : Colors.black,
                                ),
                                Icon(
                                  Symbols.density_medium,
                                  size: 18.0,
                                  color: hasAnyFilter
                                      ? const Color(0xFF771F98)
                                      : Colors.black,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 4.0),
                ],
              ),
            ),
            const Divider(
              color: Color.fromARGB(255, 110, 110, 110),
              thickness: 1,
              height: 1,
            ),

            // posts
            Expanded(
              child: StreamBuilder(
                stream: _getFilteredPosts(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: const Text(
                        "Error",
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: const CircularProgressIndicator());
                  }
                  // no post found
                  final posts = snapshot.data!.docs;
                  if (posts.isEmpty) {
                    return EmptyStateWidget(
                      icon: hasAnyFilter
                          ? Symbols.filter_alt_off
                          : Symbols.post_add,
                      title: hasAnyFilter ? "No posts found" : "No posts yet",
                      subtitle: hasAnyFilter
                          ? "No items match your current filters."
                          : "Items will show when other users report new items",
                    );
                  }

                  return Container(
                    color: const Color.fromARGB(77, 223, 218, 236),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 15,
                      ),
                      physics: const ClampingScrollPhysics(),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot postData = snapshot.data!.docs
                            .elementAt(index);
                        String uid = postData["uid"];

                        // read the publisher data for each post
                        return FutureBuilder<DocumentSnapshot>(
                          future: publishers.doc(uid).get(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) return Text("Error");

                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              Map<String, dynamic> publisherData =
                                  snapshot.data!.data() as Map<String, dynamic>;
                              return PostCard(
                                publisherData: publisherData,
                                postData: postData,
                              );
                            }

                            return SizedBox.shrink();
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
