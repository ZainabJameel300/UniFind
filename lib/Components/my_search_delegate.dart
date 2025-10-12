import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unifind/components/post_card.dart';

class MySearchDelegate extends SearchDelegate<void> {
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
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  // Suggestions: matching titles 
  @override
  Widget buildSuggestions(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .snapshots(),

      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final matched = snapshot.data!.docs.where((post) {
          return post['title'].toLowerCase().contains(query.toLowerCase());
        }).toList();

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
    
    final postsStream = FirebaseFirestore.instance
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots();

    return StreamBuilder(
      stream: postsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading results'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        // match only whole words in description
        final regex = RegExp(r'\b' + RegExp.escape(query) + r'\b', caseSensitive: false);

        // match with title always, description only if (lost) because found description is hidden
        final matchedPosts = snapshot.data!.docs.where((post) {
          final title = (post['title'] ?? '').toLowerCase();
          final description = (post['description'] ?? '').toLowerCase();
          final type = (post['type'] ?? '');
          return title.contains(query.toLowerCase()) || (type == 'Lost' && regex.hasMatch(description));
        }).toList();

        if (matchedPosts.isEmpty) {
          return const Center(child: Text('No results found'));
        }
    
        return Container(
          color: const Color.fromARGB(77, 223, 218, 236),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            itemCount: matchedPosts.length,
            itemBuilder: (context, index) {
              DocumentSnapshot postData = matchedPosts[index];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(postData['uid'])
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return const SizedBox.shrink();
                  if (!snapshot.hasData) return const SizedBox.shrink();
                      
                  Map<String, dynamic> publisherData = snapshot.data!.data() as Map<String, dynamic>;
                  return PostCard(
                    publisherData: publisherData,
                    postData: postData,
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

