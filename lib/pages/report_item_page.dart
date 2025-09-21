import 'package:flutter/material.dart';
import 'package:unifind/Components/my_AppBar.dart';

class ReportItemPage extends StatefulWidget {
  const ReportItemPage({super.key});

  @override
  State<ReportItemPage> createState() => _ReportItemPageState();
}

class _ReportItemPageState extends State<ReportItemPage> {
  String type = "Lost"; // this will track the selected type

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
                constraints: const BoxConstraints(minWidth: 90, minHeight: 45),
                children: const [
                  Text(
                    "Lost",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    "Found",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
