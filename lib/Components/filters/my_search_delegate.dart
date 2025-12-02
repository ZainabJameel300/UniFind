import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:unifind/Components/post/post_card.dart';
import 'package:unifind/services/post_service.dart';

class MySearchDelegate extends SearchDelegate<void> {
  MySearchDelegate() : super(searchFieldLabel: 'Search items');
  final PostService _postService = PostService();

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: const AppBarTheme(
        elevation: 8,
        shadowColor: Color.fromARGB(51, 0, 0, 0),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.grey),
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Symbols.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Symbols.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  // Suggestions: matching titles
  @override
  Widget buildSuggestions(BuildContext context) {
    return StreamBuilder(
      stream: _postService.searchPosts(),

      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final matched = snapshot.data!.docs
            .where((post) {
              return post['title'].toLowerCase().contains(
                query.trim().toLowerCase(),
              );
            })
            .take(7)
            .toList();

        return Container(
          color: Colors.white,
          child: ListView.builder(
            itemCount: matched.length,
            itemBuilder: (context, index) {
              final title = matched[index]['title'] ?? '';
              return ListTile(
                title: Text(title),
                onTap: () {
                  query = title;
                  showResults(context);
                },
              );
            },
          ),
        );
      },
    );
  }

  // Results: posts with matched title or description
  @override
  Widget buildResults(BuildContext context) {
    // if search is cleared, go back to suggestions
    if (query.isEmpty) {
      return buildSuggestions(context);
    }

    return StreamBuilder(
      stream: _postService.searchPosts(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading results'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: 6,
            itemBuilder: (context, index) {
              return Skeletonizer(
                enabled: true,
                child: PostCard(
                  postData: dummyPostData,
                  publisherData: dummyPublisherData,
                  isLoading: true,
                ),
              );
            },
          );
        }

        // match only whole words in description
        final regex = RegExp(
          r'\b' + RegExp.escape(query.trim()) + r'\b',
          caseSensitive: false,
        );

        // match with title always, description only if (lost) because found description is hidden
        final matchedPosts = snapshot.data!.docs.where((post) {
          final title = (post['title'] ?? '').toLowerCase();
          final description = (post['description'] ?? '').toLowerCase();
          final type = (post['type'] ?? '');
          return title.contains(query.trim().toLowerCase()) ||
              (type == 'Lost' && regex.hasMatch(description));
        }).toList();

        if (matchedPosts.isEmpty) {
          return const Center(child: Text('No results found'));
        }

        return Container(
          color: const Color(0xFFF7F7F7),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            itemCount: matchedPosts.length,
            itemBuilder: (context, index) {
              DocumentSnapshot postData = matchedPosts[index];
              String uid = postData["uid"];

              return FutureBuilder<DocumentSnapshot>(
                future: _postService.getPublisherByID(uid),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Text("Error");

                  bool isLoading =
                      snapshot.connectionState != ConnectionState.done;

                  Map<String, dynamic> publisherData = isLoading
                      ? dummyPublisherData
                      : snapshot.data!.data() as Map<String, dynamic>;

                  return Skeletonizer(
                    enabled: isLoading ? true : false,
                    child: PostCard(
                      publisherData: publisherData,
                      postData: isLoading ? dummyPostData : postData,
                      isLoading: isLoading,
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

final Map<String, dynamic> dummyPublisherData = {
  "username": BoneMock.words(2),
  "avatar": BoneMock.words(1),
};

final Map<String, dynamic> dummyPostData = {
  "postID": BoneMock.words(1),
  "uid": BoneMock.words(1),
  "type": "All",
  "createdAt": Timestamp.fromDate(DateTime.now()),
  "picture": BoneMock.words(1),
  "title": BoneMock.words(2),
  "description": BoneMock.words(40),
  "date": Timestamp.fromDate(DateTime.now()),
  "location": BoneMock.words(2),
  "category": BoneMock.words(2),
};
