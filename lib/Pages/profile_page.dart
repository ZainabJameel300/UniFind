import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:unifind/Components/change_password_sheet.dart';
import 'package:unifind/Components/edit_bottom_sheet.dart';
import 'package:unifind/Components/fullscreen_image.dart';
import 'package:unifind/Components/my_appbar.dart';
import 'package:unifind/Pages/login.dart';

class ProfilePage extends StatefulWidget {
  final String avatar;
  final String username;
  final String email;

  const ProfilePage({
    super.key,
    required this.avatar,
    required this.username,
    required this.email,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? currentAvatar;
  String? currentUsername;
  String? currentEmail;

  @override
  void initState() {
    super.initState();
    currentAvatar = widget.avatar;
    currentUsername = widget.username;
    currentEmail = widget.email;
  }

  // this will pick image from gallery, upload it to Firebase Storage, and then update Firestore
  Future<void> _pickAndUploadImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile == null) return; // User cancelled image picker

      final user = FirebaseAuth.instance.currentUser!;
      final File imageFile = File(pickedFile.path);

      //  Upload to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child(
        'avatar/${user.uid}.jpg',
      );

      await storageRef.putFile(imageFile);

      //  Get the uploaded image URL
      final imageUrl = await storageRef.getDownloadURL();

      //  Update Firestore 'users' document
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'avatar': imageUrl},
      );

      setState(() {
        currentAvatar = imageUrl;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating avatar: $e')));
    }
  }

  // UOB email validator method for both students and staff/instructors
  bool _isUobEmail(String email) {
    final regex = RegExp(
      r'^((20(1[0-9]|2[0-5])\d{5}@stu\.uob\.edu\.bh)|([a-zA-Z0-9._-]+@uob\.edu\.bh))$',
      caseSensitive: false,
    );
    return regex.hasMatch(email.trim());
  }

  @override
  Widget build(BuildContext context) {
    final avatarToShow = currentAvatar ?? "";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MyAppbar(
        title: "Profile",
        showBack: true,
        onBack: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            24,
            16,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          physics: const BouncingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            const SizedBox(height: 11),

            // Avatar (kept same as before)
            Center(
              child: GestureDetector(
                onTap: () {
                  if (avatarToShow.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            FullScreenImage(imageUrl: avatarToShow),
                      ),
                    );
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF771F98),
                      width: 2.5,
                    ),
                  ),
                  child: ClipOval(
                    child: SizedBox(
                      width: 130,
                      height: 130,
                      child: avatarToShow.isNotEmpty
                          ? Image.network(avatarToShow, fit: BoxFit.cover)
                          : const Icon(
                              Icons.account_circle,
                              size: 130,
                              color: Colors.grey,
                            ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Edit button
            Center(
              child: TextButton(
                onPressed: _pickAndUploadImage,
                child: const Text(
                  "Edit",
                  style: TextStyle(
                    color: Color(0xFF771F98),
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // User Info Card Container (same as before)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 25,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Username
                    Row(
                      children: [
                        const Icon(
                          Symbols.person,
                          color: Color(0xFF771F98),
                          size: 30,
                          weight: 450,
                        ),
                        const SizedBox(width: 25),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Username",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                currentUsername ?? "",
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // edit icon
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: Color(0xFF771F98),
                            size: 25,
                          ),
                          onPressed: () {
                            showEditFieldSheet(
                              context: context,
                              title: "Edit Username",
                              label: "Username",
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Username cannot be empty";
                                }
                                if (value.length > 50) {
                                  return "Username cannot exceed 20 characters";
                                }
                                return null;
                              },
                              currentValue: currentUsername ?? "",
                              onSave: (newValue) async {
                                final user = FirebaseAuth.instance.currentUser!;
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .update({'username': newValue});

                                setState(() {
                                  currentUsername = newValue;
                                });
                              },
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 50),

                    // Email
                    Row(
                      children: [
                        const Icon(
                          Symbols.email,
                          color: Color(0xFF771F98),
                          size: 28,
                          weight: 450,
                        ),
                        const SizedBox(width: 25),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Email",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                currentEmail ?? "",
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),
                        //Arrow icon
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: Color(0xFF771F98),
                            size: 25,
                            weight: 450,
                          ),
                          onPressed: () {
                            showEditFieldSheet(
                              context: context,
                              title: "Edit Email",
                              label: "Email",
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Email cannot be empty";
                                }
                                if (!_isUobEmail(value)) {
                                  return "Enter a valid UOB email";
                                }
                                return null;
                              },
                              currentValue: currentEmail ?? "",
                              onSave: (newValue) async {
                                final user = FirebaseAuth.instance.currentUser!;
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .update({'email': newValue});

                                setState(() {
                                  currentEmail = newValue;
                                });
                              },
                            );
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: 50),
                    // Password
                    Row(
                      children: [
                        Icon(
                          Symbols.lock,
                          color: Color(0xFF771F98),
                          size: 30,
                          weight: 450,
                        ),
                        SizedBox(width: 25),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Password",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                "Change your password",
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // edit icon
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: Color(0xFF771F98),
                            size: 25,
                            weight: 450,
                          ),
                          onPressed: () {
                            showChangePasswordSheet(context);
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: 50),
                    // Log out
                    GestureDetector(
                      onTap: () async {
                        // Sign out the user
                        await FirebaseAuth.instance.signOut();

                        // Navigate to Splash
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const Login(),
                            transitionsBuilder:
                                (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  child,
                                ) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                            transitionDuration: const Duration(
                              milliseconds: 400,
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Icon(
                            Symbols.logout,
                            color: Color(0xFF771F98),
                            size: 30,
                            weight: 450,
                          ),
                          SizedBox(width: 25),
                          Text(
                            "Log Out",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
