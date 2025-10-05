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
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    titlecontroller.dispose();
    desccontroller.dispose();
    super.dispose();
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

  String? _locationError;
  String? _categoryError;
  String? _dateError;

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
                              Icons.info_outline,
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
                              Icons.info_outline,
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
                          padding: const EdgeInsets.only(left: 20, right: 10),
                          child: DropdownButtonFormField<String>(
                            value: selectedCategory,
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
                                _categoryError = null;
                              });
                            },
                          ),
                        ),
                        if (_categoryError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 5, left: 15),
                            child: Text(
                              _categoryError!,
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

                  //Location Label
                  Label(text: "Location :"),
                  SizedBox(height: 5),

                  //Location DropDownList
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
                          padding: const EdgeInsets.only(left: 20, right: 10),
                          child: DropdownButtonFormField<String>(
                            value: selectedlocation,
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
                                _locationError = null;
                              });
                            },
                          ),
                        ),
                        if (_locationError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 5, left: 15),
                            child: Text(
                              _locationError!,
                              style: const TextStyle(color: Color(0xFFB71C1C)),
                            ),
                          ),
                      ],
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
                                Icons.calendar_month_rounded,
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
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: const Color(0xFF771F98),
                          width: 2.5,
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      height: 185,
                      width: 380,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: _image == null
                            ? const Center(
                                child: Icon(
                                  Icons.camera_alt_outlined,
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

                  // Remove image button
                  if (_image != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10, right: 35),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                225,
                                224,
                                224,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _image = null;
                              });
                            },
                            icon: Icon(
                              Icons.clear,
                              color: Colors.red[700],
                              size: 22,
                            ),
                            label: Text(
                              "Remove Image",
                              style: TextStyle(
                                color: Color(0xFF771F98),
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
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
                      });

                      if (isValid &&
                          _categoryError == null &&
                          _locationError == null &&
                          _dateError == null) {
                        // LOGIC AFTER THE FORM IS VALIDATED !!!!!

                        //----------------!!-----------------------
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
