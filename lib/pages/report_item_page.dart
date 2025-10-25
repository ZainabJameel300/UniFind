import 'dart:convert';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:material_symbols_icons/symbols.dart';
import 'package:unifind/Components/label.dart';
import 'package:unifind/Components/my_appbar.dart';
import 'package:unifind/Components/my_button.dart';
import 'package:unifind/Components/report_item_textfield.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:unifind/Components/show_snackbar.dart';
import 'package:unifind/Pages/potenialmatch.dart';
import 'package:unifind/utils/EmbeddingService.dart';

class ReportItemPage extends StatefulWidget {
  const ReportItemPage({super.key});

  @override
  State<ReportItemPage> createState() => _ReportItemPageState();
}

class _ReportItemPageState extends State<ReportItemPage> {
  String type = "Lost"; // this will track the selected type
  final TextEditingController titlecontroller = TextEditingController();
  final TextEditingController desccontroller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    titlecontroller.dispose();
    desccontroller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
  }

  final List<String> categories = [
    "Electronics",
    "Charger",
    "Cards",
    "Wallet",
    "Keys",
    "Bags",
    "Accessories",
    "Books",
    "Other",
  ];

  final List<String> locations = [
    "S1-Buissness College",
    "S1-Art College",
    "S18-All Purpose Hall",
    "S20-English Language Center",
    "S20-A",
    "S20-B",
    "S20-C",
    "S22-BTC",
    "S3-Central Library",
    "S37-Registeration",
    "S39-Law College",
    "S4-Food Court",
    "S40-IT College",
    "S41-Science College",
    "S47-Sciance and IT Library",
    "S48-Class Rooms",
    "S50-Khunji Hall",
    "S51-Food Court",
    "S6-Mosque",
    "S27-College of Engineering",
    "College of Health and Sciences",
  ];

  String? selectedCategory;
  String? selectedlocation;
  DateTime? selectedDate;

  String? _locationError;
  String? _categoryError;
  String? _dateError;
  String? _imageError;

  void _showDatePicker() {
    showDatePicker(
      context: context,
      firstDate: DateTime(2010),
      lastDate: DateTime(2030),
    ).then((value) {
      setState(() {
        selectedDate = value;
        _dateError = null;
      });
    });
  }

  File? _image;

  final ImagePicker _picker =
      ImagePicker(); // this line baiscally builds an instance of the image picker

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery, // or ImageSource.camera
      maxWidth: 800,
      maxHeight: 800,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _imageError = null;
      });
    }
  }

  //This method is used to save the entered data to the database

  Future<void> _savePost() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Color(0xFF771F98)),
        ),
      );

      // Get current user ID
      final user = FirebaseAuth.instance.currentUser!;

      // Create Firestore document reference (auto-generated ID)
      final docRef = FirebaseFirestore.instance.collection('posts').doc();

      // Upload image to Cloud Storage
      String imageUrl = "";
      if (_image != null) {
        final storageRef = FirebaseStorage.instance.ref().child(
          'post_images/${docRef.id}.jpg',
        );
        await storageRef.putFile(_image!);
        imageUrl = await storageRef.getDownloadURL();
      }

      // This will convert selectedDate to Timestamp (time = 12:00:00 AM)
      Timestamp dateTimestamp = Timestamp.fromDate(
        DateTime(
          selectedDate!.year,
          selectedDate!.month,
          selectedDate!.day,
          0, // hour
          0, // minute
          0, // second
        ),
      );

      // Create Firestore document data
      //  request embedding from Flask using descreption + image
      List<double>? embedding;
      try {
        embedding = await EmbeddingService.fetchEmbeddingFromServer(
          description: desccontroller.text.trim(),
          imageUrl: imageUrl,
        );
      } catch (e) {
        // If embedding fetch fails, you can decide:
        // - proceed without embedding (set null),
        // - or show error and stop submission.
        // I'll proceed without embedding but log the error.
        print('Embedding fetch error: $e');
        embedding = null;
      }

      // Create postData; include embedding if available
      final postData = {
        "category": selectedCategory,
        "claim_status": false,
        "createdAt": Timestamp.now(),
        "date": dateTimestamp,
        "description": desccontroller.text.trim(),
        "location": selectedlocation,
        "picture": imageUrl,
        "postID": docRef.id,
        "title": titlecontroller.text.trim(),
        "type": type,
        "uid": user.uid,
        "embedding": embedding,
      };

      // Save post to Firestore
      await docRef.set(postData);

      //  Send embedding to Flask ---
      List<MatchItem> matchItems = [];
      if (embedding != null) {
        try {
          // Decide the server URL based on the platform
          final String baseUrl = Platform.isAndroid
              ? 'http://10.0.2.2:5001' // Android Emulator
              : 'http://192.168.1.3:5001'; // IOS Emulator

          final response = await http.post(
            Uri.parse('$baseUrl/find_matches'),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "embedding": embedding,
              "uid": user.uid,
              "type": type,
              "postID": docRef.id,
              "location": selectedlocation,
              "date": {
                "_seconds": dateTimestamp.seconds,
                "_nanoseconds": dateTimestamp.nanoseconds,
              },
            }),
          );

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            List matches = data['matches'];
            matchItems = matches.map((m) => MatchItem.fromJson(m)).toList();
          } else {
            print("Error fetching matches: ${response.body}");
          }
        } catch (e) {
          print("HTTP request error: $e");
        }
      }

      // Close loading dialog
      Navigator.pop(context);

      // Navigate to Potenialmatch page with fetched matches
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Potenialmatch(matchItems: matchItems),
        ),
      );

      showSnackBar(context, "Item Reported Successfully!");

      // Clear form fields
      setState(() {
        titlecontroller.clear();
        desccontroller.clear();
        selectedCategory = null;
        selectedlocation = null;
        selectedDate = null;
        _image = null;
      });
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error uploading post: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MyAppbar(title: "Report Item", showBack: false),
      body: SafeArea(
        child: ListView(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: 30),

                  //The toggle buttons
                  Center(
                    child: ToggleButtons(
                      isSelected: [type == "Lost", type == "Found"],
                      onPressed: (index) {
                        setState(() {
                          type = index == 0 ? "Lost" : "Found";
                        });
                      },
                      borderRadius: BorderRadius.circular(15),
                      borderColor: const Color(0xFF771F98),
                      selectedBorderColor: const Color(0xFF771F98),
                      fillColor: const Color(0xFF771F98),
                      color: Colors.black54,
                      selectedColor: Colors.white,
                      splashColor: Colors.transparent,
                      constraints: const BoxConstraints(
                        minWidth: 180,
                        minHeight: 40,
                      ),
                      children: const [
                        Text(
                          "Lost",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "Found",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 25),

                  // title label + red info icon for the found items only
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Label(text: "Title :"),
                      if (type == "Found")
                        Positioned(
                          left: 115,
                          top: 0,
                          child: Tooltip(
                            message:
                                "This field will be public, don't reveal any descriptive information!",
                            child: const Icon(
                              Symbols.info,
                              color: Colors.red,
                              size: 25,
                            ),
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: 5),

                  //title textfield
                  ReportItemTextfield(
                    hintText: "Enter a short title (e.g. Lost student ID card)",
                    obscureText: false,
                    controller: titlecontroller,
                    height: 55,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Title is required";
                      }
                      if (value.length > 50) {
                        return "Title cannot exceed 50 characters";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),

                  // Descreption label + red info icon for the found items only
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Label(text: "Descreption :"),
                      if (type == "Found")
                        Positioned(
                          left: 175,
                          top: 0,
                          child: Tooltip(
                            message:
                                "This field is hidden from the public for confidentiality!",
                            child: const Icon(
                              Symbols.info,
                              color: Colors.red,
                              size: 25,
                            ),
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: 5),

                  //description textfield
                  ReportItemTextfield(
                    hintText: "Describe the item (e.g. color, size, brand..)",
                    obscureText: false,
                    controller: desccontroller,
                    height: 120,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Descreption is required";
                      }
                      if (value.length > 500) {
                        return "You exceeded the 500 character limit!";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),

                  //category label
                  Label(text: "Category :"),
                  SizedBox(height: 5),

                  //category drop down list
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: const Color(0xFF771F98),
                          width: 2.5,
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      height: 57,
                      width: 380,
                      padding: const EdgeInsets.only(left: 20, right: 10),
                      child: DropdownButtonFormField<String>(
                        value: selectedCategory,
                        hint: const Text(
                          "Select a Category...",
                          style: TextStyle(
                            color: Color.fromARGB(255, 198, 196, 196),
                          ),
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          errorText: _categoryError,
                          errorStyle: const TextStyle(
                            color: Color(0xFFB71C1C),
                            fontSize: 13,
                          ),
                          contentPadding: const EdgeInsets.only(bottom: 5),
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        icon: const Icon(
                          Symbols.expand_more,
                          fill: 1,
                          color: Color(0xFF771F98),
                        ),
                        items: categories
                            .map(
                              (category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value;
                            _categoryError = null;
                          });
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  //Location Label
                  Label(text: "Location :"),
                  SizedBox(height: 5),

                  //Location DropDownList
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: const Color(0xFF771F98),
                          width: 2.5,
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      height: 57,
                      width: 380,
                      padding: const EdgeInsets.only(left: 20, right: 10),
                      child: DropdownButtonFormField<String>(
                        value: selectedlocation,
                        hint: const Text(
                          "Select a Location...",
                          style: TextStyle(
                            color: Color.fromARGB(255, 198, 196, 196),
                          ),
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          errorText: _locationError,
                          errorStyle: const TextStyle(
                            color: Color(0xFFB71C1C),
                            fontSize: 13,
                          ),
                          contentPadding: const EdgeInsets.only(bottom: 5),
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        icon: const Icon(
                          Symbols.expand_more,
                          fill: 1,
                          color: Color(0xFF771F98),
                        ),
                        items: locations
                            .map(
                              (location) => DropdownMenuItem(
                                value: location,
                                child: Text(location),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedlocation = value;
                            _locationError = null;
                          });
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  //Date Label
                  Label(text: "Date :"),
                  SizedBox(height: 5),

                  //Date Picker
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: const Color(0xFF771F98),
                              width: 2.5,
                            ),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          height: 55,
                          width: 380,
                          child: TextFormField(
                            readOnly: true,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: selectedDate == null
                                  ? ""
                                  : "${selectedDate!.day.toString().padLeft(2, '0')}/"
                                        "${selectedDate!.month.toString().padLeft(2, '0')}/"
                                        "${selectedDate!.year}",
                              contentPadding: EdgeInsets.only(
                                top: 10,
                                bottom: 10,
                                left: 20,
                                right: 10,
                              ),
                              suffixIcon: Icon(
                                Symbols.calendar_month,
                                fill: 1,
                                color: Color(0xFF771F98),
                              ),
                            ),
                            onTap: _showDatePicker,
                          ),
                        ),
                        if (_dateError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 5, left: 15),
                            child: Text(
                              _dateError!,
                              style: const TextStyle(
                                color: Color(0xFFB71C1C),
                                fontSize: 13,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  //Upload a photo label
                  Label(text: "Uplaod a Photo :"),
                  SizedBox(height: 5),

                  // Upload Photo
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: DottedBorder(
                            options: RoundedRectDottedBorderOptions(
                              radius: const Radius.circular(25),
                              padding: const EdgeInsets.all(8),
                              color: const Color(0xFF771F98),
                              strokeWidth: 2.5,
                              dashPattern: [10, 5],
                            ),
                            child: Container(
                              color: Colors.white,
                              height: 185,
                              width: 380,
                              child: _image == null
                                  ? const Center(
                                      child: Icon(
                                        Symbols.photo_camera,
                                        color: Color(0xFF771F98),
                                        size: 40,
                                      ),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(25),
                                      child: Image.file(
                                        _image!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        // Button to remove the image
                        if (_image != null)
                          Positioned(
                            bottom: 20,
                            right: 20,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _image = null;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFFF3F3F3),
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(6),
                                child: Icon(
                                  Icons.clear,
                                  color: Colors.red[400],
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                        if (_imageError != null)
                          Positioned(
                            bottom: 8,
                            left: 15,
                            child: Text(
                              _imageError!,
                              style: const TextStyle(
                                color: Color(0xFFB71C1C),
                                fontSize: 13,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  SizedBox(height: 45),

                  //Submit Button
                  MyButton(
                    text: "Submit",
                    onTap: () {
                      bool isValid = _formKey.currentState!.validate();
                      setState(() {
                        _categoryError = selectedCategory == null
                            ? "Category is required!"
                            : null;
                        _locationError = selectedlocation == null
                            ? "Location is required!"
                            : null;
                        if (selectedDate == null) {
                          _dateError = "Date is required!";
                        } else if (selectedDate!.isAfter(DateTime.now())) {
                          _dateError = "The Date cannot be in the future!";
                        } else {
                          _dateError = null;
                        }

                        // Image error logic
                        if (type == "Found" && _image == null) {
                          setState(() {
                            _imageError = "Image is required for Found items!";
                          });
                        } else {
                          setState(() {
                            _imageError = null;
                          });
                        }
                      });

                      if (isValid &&
                          _categoryError == null &&
                          _locationError == null &&
                          _dateError == null &&
                          _imageError == null) {
                        // LOGIC AFTER THE FORM IS VALIDATED
                        _savePost();
                      }
                    },
                  ),

                  SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
