import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unifind/Components/my_appbar.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MyAppbar(
        title: "Potential Matches",
        onBack: () {
          Navigator.pushReplacementNamed(context, 'bottomnavBar');
        },
      ),
      body: ListView.builder(
        itemCount: widget.matchItems.length,
        itemBuilder: (context, index) {
          final match = widget.matchItems[index];
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              leading: match.picture.isNotEmpty
                  ? Image.network(
                      match.picture,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                  : Icon(Icons.image_not_supported),
              title: Text(match.title),
              subtitle: Text("${match.type} • ${match.location}"),
              trailing: Text("${(match.similarity * 100).toStringAsFixed(1)}%"),
              onTap: () {
                // Optional: navigate to a detailed page
              },
            ),
          );
        },
      ),
    );
  }
}
