import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:unifind/Components/item_card.dart';
import 'package:unifind/Components/my_AppBar.dart';
import 'package:unifind/Pages/profile_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  User? currentUser;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser!.uid)
          .get();

      if (snapshot.exists) {
        setState(() {
          userData = snapshot.data() as Map<String, dynamic>;
        });
      }
    }
  }

  //Stream for user posts of type lost
  Stream<QuerySnapshot> getLostPosts() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('posts')
        .where('uid', isEqualTo: uid)
        .where('type', isEqualTo: "Lost")
        .snapshots();
  }

  //Stream for user posts of type found
  Stream<QuerySnapshot> getFoundPosts() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('posts')
        .where('uid', isEqualTo: uid)
        .where('type', isEqualTo: "Found")
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final avatar = userData?["avatar"] ?? "";
    final username = userData?["username"] ?? "";
    final email = userData?["email"] ?? "";

    return Scaffold(
      appBar: MyAppbar(title: "My Account", showBack: false),
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Skeletonizer(
            enabled: userData == null,
            child: ListView(
              children: [
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(
                          avatar: avatar,
                          username: username,
                          email: email,
                        ),
                      ),
                    );

                    //When the user returns from the profile, reload the updated data
                    _loadUserData();
                  },
                  // User Detail Card
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.09),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(
                      minHeight: 115,
                      maxWidth: 650,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Avatar
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF771F98),
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: SizedBox(
                              width: 65,
                              height: 65,
                              child: avatar.isNotEmpty
                                  ? Image.network(avatar, fit: BoxFit.cover)
                                  : const Icon(
                                      Icons.account_circle,
                                      size: 65,
                                      color: Colors.grey,
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 20),

                        // Username and email
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                username,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF771F98),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                email,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Purple Arrow
                        const Icon(
                          Symbols.chevron_right_rounded,
                          color: Color(0xFF771F98),
                          size: 35,
                          weight: 400,
                        ),
                      ],
                    ),
                  ),
                ),

                //My Reported Item Text
                SizedBox(height: 45),
                Text(
                  "My Reported Items",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w300),
                ),
                SizedBox(height: 20),
                //------------------------Lost Items------------------
                //----------------------------------------------------
                //Lost Items
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    "Lost",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                ),
                SizedBox(height: 8),

                StreamBuilder<QuerySnapshot>(
                  stream: getLostPosts(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox.shrink();
                    }

                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48.0),
                        child: Column(
                          children: [
                            SizedBox(height: 30),
                            Icon(
                              Symbols.camera_alt_rounded,
                              size: 50,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Something went wrong, please try again later!",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF771F98),
                              ),
                            ),
                            SizedBox(height: 30),
                          ],
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48.0),
                        child: Column(
                          children: [
                            SizedBox(height: 30),
                            Icon(
                              Symbols.camera_alt_rounded,
                              size: 50,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              "No Lost items reported yet!",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF771F98),
                              ),
                            ),
                            SizedBox(height: 30),
                          ],
                        ),
                      );
                    }

                    final docs = snapshot.data!.docs;

                    // Use a regular GridView
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.72,
                          ),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;

                        final imageUrl = (data['picture'] ?? "").toString();
                        final title = data['title'] ?? "";

                        final bool claimStatus =
                            (data['claim_status'] ?? false) == true;
                        final statusText = claimStatus
                            ? "Claimed"
                            : "Unclaimed";

                        DateTime createdAt;
                        if (data['createdAt'] is Timestamp) {
                          createdAt = (data['createdAt'] as Timestamp).toDate();
                        } else {
                          createdAt = DateTime.now();
                        }
                        final formattedDate =
                            "${createdAt.day}/${createdAt.month}/${createdAt.year}";

                        return ItemCard(
                          imageUrl: imageUrl,
                          title: title,
                          date: formattedDate,
                          status: statusText,
                          postID: data['postID'],
                        );
                      },
                    );
                  },
                ),
                SizedBox(height: 20),
                //------------------------Found Items------------------
                //----------------------------------------------------
                //Found Items
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    "Found",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                ),
                SizedBox(height: 8),

                StreamBuilder<QuerySnapshot>(
                  stream: getFoundPosts(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox.shrink();
                    }

                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48.0),
                        child: Column(
                          children: [
                            SizedBox(height: 30),
                            Icon(
                              Symbols.camera_alt_rounded,
                              size: 50,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Something went wrong , please try again later!",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF771F98),
                              ),
                            ),
                            SizedBox(height: 30),
                          ],
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48.0),
                        child: Column(
                          children: [
                            SizedBox(height: 30),
                            Icon(
                              Symbols.camera_alt_rounded,
                              size: 50,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              "No Found items reported yet!",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF771F98),
                              ),
                            ),
                            SizedBox(height: 30),
                          ],
                        ),
                      );
                    }

                    final docs = snapshot.data!.docs;

                    // Use regular GridView for Found items as well
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.72,
                          ),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;

                        final imageUrl = (data['picture'] ?? "").toString();
                        final title = data['title'] ?? "";

                        final bool claimStatus =
                            (data['claim_status'] ?? false) == true;
                        final statusText = claimStatus
                            ? "Claimed"
                            : "Unclaimed";

                        DateTime createdAt;
                        if (data['createdAt'] is Timestamp) {
                          createdAt = (data['createdAt'] as Timestamp).toDate();
                        } else {
                          createdAt = DateTime.now();
                        }
                        final formattedDate =
                            "${createdAt.day}/${createdAt.month}/${createdAt.year}";

                        return ItemCard(
                          imageUrl: imageUrl,
                          title: title,
                          date: formattedDate,
                          status: statusText,
                          postID: data['postID'],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
