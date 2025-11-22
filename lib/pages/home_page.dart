import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:unifind/Components/badge_icon.dart';
import 'package:unifind/Components/empty_state_widget.dart';
import 'package:unifind/Components/filters/filters_tabs.dart';
import 'package:unifind/Components/filters/my_search_delegate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unifind/Components/post/post_card_loading.dart';
import 'package:unifind/Pages/notifications_page.dart';
import 'package:unifind/components/post/post_card.dart';
import 'package:unifind/providers/filter_provider.dart';
import 'package:unifind/services/notifications_service.dart';
import 'package:unifind/services/post_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PostService _postService = PostService();
  final NotificationService notificationService = NotificationService();
  
  @override
  Widget build(BuildContext context) {
    final filterProvider = Provider.of<FilterProvider>(context);
    final hasAnyFilter = filterProvider.hasAnyFilter;

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  children: [
                    // search 
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
                                borderRadius: BorderRadius.circular(18.0),
                                color: const Color(0xFFF1F1F1),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Symbols.search),
                                  SizedBox(width: 5.0),
                                  Text(
                                    "Search items",
                                    style: TextStyle(fontSize: 16.0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
      
                        // notifications
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NotificationsPage(),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18.0),
                              color: const Color(0xFFF1F1F1),
                            ),
                            child: 
                            BadgeIcon(
                              badgeStream: notificationService.unreadNotificationsCount(),
                              icon: const Icon(Symbols.notifications, size: 24),
                            ),
                          ),
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
                  stream: _postService.getFilteredPosts(context),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: const Text("Error"));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return ListView.builder(
                        padding: const EdgeInsets.all(15),
                        itemCount: 5,
                        itemBuilder: (context, _) => const PostCardLoading(),
                      );
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
                      color: const Color(0xFFF7F7F7),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 15,
                        ),
                        physics: const ClampingScrollPhysics(),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot postData = snapshot.data!.docs.elementAt(index);
                          String uid = postData["uid"];
      
                          // read the publisher data for each post
                          return FutureBuilder<DocumentSnapshot>(
                            future: _postService.getPublisherByID(uid),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) return Text("Error");
      
                              if (snapshot.connectionState == ConnectionState.done) {
                                Map<String, dynamic> publisherData = snapshot.data!.data() as Map<String, dynamic>;
                                
                                return PostCard(
                                  publisherData: publisherData,
                                  postData: postData,
                                );
                              }
      
                              return const PostCardLoading();
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
      ),
    );
  }
}
