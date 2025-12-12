import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:unifind/Components/item_card.dart';
import 'package:unifind/Components/my_AppBar.dart';
import 'package:unifind/Components/user_avatar.dart';
import 'package:unifind/Pages/profile_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  User? currentUser;
  Map<String, dynamic>? userData;
  bool isLoadingUser = true;

  Map<String, dynamic> dummyUserData = {
    "uid": BoneMock.words(1),
    "username": BoneMock.words(2),
    "avatar": "",
    "email": "loading@stu.uob.edu.com",
  };

  final List<Map<String, dynamic>> dummyPostData = List.generate(
    2,
    (index) => {
      "postID": BoneMock.words(1),
      "uid": BoneMock.words(1),
      "type": BoneMock.words(1),
      "createdAt": Timestamp.fromDate(DateTime.now()),
      "picture": "",
      "title": BoneMock.words(2),
      "description": BoneMock.words(40),
      "date": Timestamp.fromDate(DateTime.now()),
      "location": BoneMock.words(2),
      "category": BoneMock.words(2),
    },
  );

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
          userData = snapshot.data();
          isLoadingUser = false;
        });
      } else {
        setState(() => isLoadingUser = false);
      }
    } else {
      setState(() => isLoadingUser = false);
    }
  }

  Stream<QuerySnapshot> getLostPosts() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('posts')
        .where('uid', isEqualTo: uid)
        .where('type', isEqualTo: "Lost")
        .snapshots();
  }

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
    final avatar = isLoadingUser ? "" : (userData?["avatar"] ?? "");
    final username = isLoadingUser
        ? dummyUserData["username"]
        : (userData?["username"] ?? "");
    final email = isLoadingUser
        ? dummyUserData["email"]
        : (userData?["email"] ?? "");

    return Scaffold(
      appBar: MyAppbar(title: "My Account", showBack: false),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 15),
          child: ListView(
            children: [
              const SizedBox(height: 10),
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
                  _loadUserData();
                },
                child: Skeletonizer(
                  enabled: isLoadingUser,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.09),
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
                              width: 55,
                              height: 55,
                              child: UserAvatar(avatarUrl: avatar, radius: 28),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
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
                        Skeleton.shade(
                          child: const Icon(
                            Symbols.chevron_right_rounded,
                            color: Color(0xFF771F98),
                            size: 35,
                            weight: 400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 45),
              const Text(
                "My Reported Items",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w300),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  "Lost",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 8),
              StreamBuilder<QuerySnapshot>(
                stream: getLostPosts(),
                builder: (context, snapshot) {
                  final bool isWaiting =
                      snapshot.connectionState == ConnectionState.waiting;
                  if (snapshot.hasError && !isWaiting) {
                    return _buildErrorPlaceholder(
                      "Something went wrong, please try again later!",
                    );
                  }
                  if (!isWaiting &&
                      (!snapshot.hasData || snapshot.data!.docs.isEmpty)) {
                    return _buildNoItemsPlaceholder(
                      "No Lost items reported yet!",
                    );
                  }
                  return _buildPosts(isWaiting, snapshot);
                },
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  "Found",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 8),
              StreamBuilder<QuerySnapshot>(
                stream: getFoundPosts(),
                builder: (context, snapshot) {
                  final bool isWaiting =
                      snapshot.connectionState == ConnectionState.waiting;
                  if (snapshot.hasError && !isWaiting) {
                    return _buildErrorPlaceholder(
                      "Something went wrong, please try again later!",
                    );
                  }
                  if (!isWaiting &&
                      (!snapshot.hasData || snapshot.data!.docs.isEmpty)) {
                    return _buildNoItemsPlaceholder(
                      "No Found items reported yet!",
                    );
                  }
                  return _buildPosts(isWaiting, snapshot);
                },
              ),
              SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48.0),
      child: Column(
        children: [
          const SizedBox(height: 30),
          const Icon(Symbols.camera_alt_rounded, size: 50, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFF771F98),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildPosts(bool isWaiting, AsyncSnapshot snapshot) {
    return Skeletonizer(
      enabled: userData == null || isWaiting,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.84,
        ),
        itemCount: isWaiting
            ? dummyPostData.length
            : (snapshot.data?.docs.length ?? 0),
        itemBuilder: (context, index) {
          final Map<String, dynamic> data = isWaiting
              ? dummyPostData[index]
              : (snapshot.data!.docs[index].data() as Map<String, dynamic>);
          final imageUrl = (data['picture'] ?? "").toString();
          final title = (data['title'] ?? "").toString();
          final bool claimStatus = (data['claim_status'] ?? false) == true;
          final statusText = claimStatus ? "Claimed" : "Unclaimed";
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
      ),
    );
  }

  Widget _buildNoItemsPlaceholder(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48.0),
      child: Column(
        children: [
          const SizedBox(height: 30),
          const Icon(Symbols.camera_alt_rounded, size: 50, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFF771F98),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
