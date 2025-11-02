import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unifind/Components/my_appbar.dart';

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

  @override
  void initState() {
    super.initState();
    currentAvatar = widget.avatar; // safely initialize from widget
  }

  //  Pick image from gallery, upload to Firebase Storage, and update Firestore
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

      //  Upload to Firebase Storage (folder: avatar)
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

      //Update local UI
      setState(() {
        currentAvatar = imageUrl;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating avatar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarToShow = currentAvatar ?? ""; // ensure it's never null

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MyAppbar(
        title: "Profile",
        showBack: true,
        onBack: () => Navigator.pop(context),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 50),

            // Avatar
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF771F98), width: 2.5),
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

            const SizedBox(height: 20),

            //  Edit button
            TextButton(
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

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
