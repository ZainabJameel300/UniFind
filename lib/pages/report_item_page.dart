import 'dart:io';
import 'package:flutter/material.dart';
import 'package:unifind/Components/label.dart';
import 'package:unifind/Components/my_AppBar.dart';
import 'package:unifind/Components/my_button.dart';
import 'package:unifind/Components/report_item_textfield.dart';
import 'package:image_picker/image_picker.dart';

class ReportItemPage extends StatefulWidget {
  const ReportItemPage({super.key});

  @override
  State<ReportItemPage> createState() => _ReportItemPageState();
}

class _ReportItemPageState extends State<ReportItemPage> {
  String type = "Lost"; // this will track the selected type
  final TextEditingController titlecontroller = TextEditingController();
  final TextEditingController desccontroller = TextEditingController();

  final List<String> categories = [
    "Electronics",
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
    "S20-A",
    "S20-B",
    "S20-C",
    "S22-BTC",
    "S3-Central Library",
    "S37-Registeration",
    "S39-Law College",
    "S4- Food Court",
    "S40-IT College",
    "S41-Science College",
    "S47-Sciance and IT Library",
    "S48-Class Rooms",
    "S50-Khunji Hall",
    "S51-Food Court",
    "S6-Mosque",
  ];

  String? selectedCategory;
  String? selectedlocation;
  DateTime? selectedDate;

  void _showDatePicker() {
    showDatePicker(
      context: context,
      firstDate: DateTime(2010),
      lastDate: DateTime(2030),
    ).then((value) {
      setState(() {
        selectedDate = value;
      });
    });
  }

  File? _image;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery, // or ImageSource.camera
      maxWidth: 800,
      maxHeight: 800,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MyAppbar(
        title: "Report Item",
        onBack: () {
          Navigator.pushReplacementNamed(context, 'bottomnavBar');
        },
      ),
      body: SafeArea(
        child: ListView(
          children: [
            Column(
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

                // title label
                Label(text: "Title :"),
                SizedBox(height: 5),

                //title textfield
                ReportItemTextfield(
                  hintText: "",
                  obscureText: false,
                  controller: titlecontroller,
                  height: 50,
                ),
                SizedBox(height: 20),

                // descreption label
                Label(text: "Descreption :"),
                SizedBox(height: 5),

                //descreption textfield
                ReportItemTextfield(
                  hintText: "",
                  obscureText: false,
                  controller: desccontroller,
                  height: 120,
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
                    height: 50,
                    width: 380,
                    padding: const EdgeInsets.only(left: 20, right: 10),
                    child: DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                        color: Colors.black87,
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
                    height: 50,
                    width: 380,
                    padding: const EdgeInsets.only(left: 20, right: 10),
                    child: DropdownButtonFormField<String>(
                      initialValue: selectedlocation,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                        color: Colors.black87,
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
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFF771F98),
                      width: 2.5,
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  height: 50,
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
                        Icons.calendar_month_rounded,
                        color: Color(0xFF771F98),
                      ),
                    ),
                    onTap: _showDatePicker,
                  ),
                ),
                SizedBox(height: 20),

                //Upload a photo label
                Label(text: "Uplaod a Photo :"),
                SizedBox(height: 5),

                // Upload Photo
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
                    height: 170,
                    width: 380,
                    child: GestureDetector(
                      onTap:
                          _pickImage, // this will call the function when tapped
                      child: _image == null
                          ? const Center(
                              child: Icon(
                                Icons.camera_alt_outlined,
                                color: Color(0xFF771F98),
                                size: 40,
                              ),
                            ) // this purpose of ClipRRect is to fit it in the container
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

                SizedBox(height: 45),

                //Submit Button
                MyButton(text: "Submit", onTap: () {}),

                SizedBox(height: 50),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
