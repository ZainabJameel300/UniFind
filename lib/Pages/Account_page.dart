import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
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
          child: ListView(
            children: [
              SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(
                        avatar: avatar,
                        username: username,
                        email: email,
                      ),
                    ),
                  );
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

              // const SizedBox(height: 45),
              // //Dvider line
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 60),
              //   child: Divider(
              //     color: Color.fromARGB(255, 215, 214, 214),
              //     height: 1,
              //   ),
              // ),

              //My Reported Item Text
              SizedBox(height: 45),
              Text(
                "My Reported Items",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w300),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
