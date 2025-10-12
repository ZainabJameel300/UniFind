import 'package:flutter/material.dart';
import 'package:unifind/Components/keepers_container.dart';
import 'package:unifind/Components/keepers_label.dart';
import 'package:unifind/Components/my_AppBar.dart';

// Sakhir Campus Colors
const sakhirFill = Color(0xFFEADDEF);
const sakhirBorder = Color(0xFF771F98);
const sakhirCircle = Color(0xFF771F98);

// Isa Town Campus Colors
const isaFill = Color(0xFFF8E6F2);
const isaBorder = Color(0xFFD13FC6);
const isaCircle = Color(0xFFD13FC6);

// Salminya Campus Colors
const salminyaFill = Color(0xFFE5E8FB);
const salminyaBorder = Color(0xFF4B4AEF);
const salminyaCircle = Color(0xFF4B4AEF);

class KeepersPage extends StatelessWidget {
  const KeepersPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MyAppbar(title: "Keepers", showBack: false),
      body: ListView(
        children: [
          Column(
            children: [
              SizedBox(height: 20),
              //Skahir Campus Name
              KeepersLabel(text: "Sahkir Campus "),
              SizedBox(height: 15),

              //Skahir Room Containers
              KeepersContainer(
                code: "S1",
                title: "College of Business - 1078",
                circleColor: sakhirCircle,
                fillColor: sakhirFill,
                borderColor: sakhirBorder,
              ),
              SizedBox(height: 15),
              KeepersContainer(
                code: "S1",
                title: "College of Art - 2017",
                circleColor: sakhirCircle,
                fillColor: sakhirFill,
                borderColor: sakhirBorder,
              ),
              SizedBox(height: 15),
              KeepersContainer(
                code: "S20",
                title: "English Language Center - 2017",
                circleColor: sakhirCircle,
                fillColor: sakhirFill,
                borderColor: sakhirBorder,
              ),
              SizedBox(height: 15),
              KeepersContainer(
                code: "S20",
                title: "S20-A - 2017",
                circleColor: sakhirCircle,
                fillColor: sakhirFill,
                borderColor: sakhirBorder,
              ),
              SizedBox(height: 15),
              KeepersContainer(
                code: "S20",
                title: "S20-B - 2017",
                circleColor: sakhirCircle,
                fillColor: sakhirFill,
                borderColor: sakhirBorder,
              ),
              SizedBox(height: 15),
              KeepersContainer(
                code: "S20",
                title: "S20-C - 2017",
                circleColor: sakhirCircle,
                fillColor: sakhirFill,
                borderColor: sakhirBorder,
              ),
              SizedBox(height: 15),
              KeepersContainer(
                code: "S22",
                title: "BTC - 2017",
                circleColor: sakhirCircle,
                fillColor: sakhirFill,
                borderColor: sakhirBorder,
              ),
              SizedBox(height: 15),
              KeepersContainer(
                code: "S3",
                title: "Centeral Library - 2017",
                circleColor: sakhirCircle,
                fillColor: sakhirFill,
                borderColor: sakhirBorder,
              ),
              SizedBox(height: 15),
              KeepersContainer(
                code: "S37",
                title: "Registration - 2017",
                circleColor: sakhirCircle,
                fillColor: sakhirFill,
                borderColor: sakhirBorder,
              ),
              SizedBox(height: 15),
              KeepersContainer(
                code: "S39",
                title: "College of Law - 2017",
                circleColor: sakhirCircle,
                fillColor: sakhirFill,
                borderColor: sakhirBorder,
              ),
              SizedBox(height: 15),
              KeepersContainer(
                code: "S4",
                title: "Food Court- 2017",
                circleColor: sakhirCircle,
                fillColor: sakhirFill,
                borderColor: sakhirBorder,
              ),
              SizedBox(height: 15),
              KeepersContainer(
                code: "S40",
                title: "College of IT - 2017",
                circleColor: sakhirCircle,
                fillColor: sakhirFill,
                borderColor: sakhirBorder,
              ),
              SizedBox(height: 15),
              KeepersContainer(
                code: "S47",
                title: "Science and IT Liabrary - 2017",
                circleColor: sakhirCircle,
                fillColor: sakhirFill,
                borderColor: sakhirBorder,
              ),
              SizedBox(height: 15),
              KeepersContainer(
                code: "S48",
                title: "Class Rooms - 2017",
                circleColor: sakhirCircle,
                fillColor: sakhirFill,
                borderColor: sakhirBorder,
              ),
              SizedBox(height: 15),
              KeepersContainer(
                code: "S50",
                title: "Khunji Hall - 2017",
                circleColor: sakhirCircle,
                fillColor: sakhirFill,
                borderColor: sakhirBorder,
              ),
              SizedBox(height: 15),
              KeepersContainer(
                code: "S51",
                title: "Food Court - 2017",
                circleColor: sakhirCircle,
                fillColor: sakhirFill,
                borderColor: sakhirBorder,
              ),
              SizedBox(height: 15),
              KeepersContainer(
                code: "S6",
                title: "Mosuqe - 2017",
                circleColor: sakhirCircle,
                fillColor: sakhirFill,
                borderColor: sakhirBorder,
              ),

              //Divider Line
              SizedBox(height: 45),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60),
                child: Divider(
                  color: Color.fromARGB(255, 154, 154, 154),
                  height: 1,
                ),
              ),

              //Isa Town Campus Name
              SizedBox(height: 20),
              KeepersLabel(text: "Isa Town Campus "),
              SizedBox(height: 15),

              //Isa Town Room Containers
              KeepersContainer(
                code: "S13",
                title: "College of Engineering - 1078",
                circleColor: isaCircle,
                fillColor: isaFill,
                borderColor: isaBorder,
              ),
              SizedBox(height: 15),
              KeepersContainer(
                code: "S14",
                title: "College of Engineering - 2017",
                circleColor: isaCircle,
                fillColor: isaFill,
                borderColor: isaBorder,
              ),
              SizedBox(height: 15),
              KeepersContainer(
                code: "S15",
                title: "College of Engineering - 2017",
                circleColor: isaCircle,
                fillColor: isaFill,
                borderColor: isaBorder,
              ),
              SizedBox(height: 15),
              KeepersContainer(
                code: "S27",
                title: "College of Engineering - 2017",
                circleColor: isaCircle,
                fillColor: isaFill,
                borderColor: isaBorder,
              ),

              //Divider Line
              SizedBox(height: 45),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60),
                child: Divider(
                  color: Color.fromARGB(255, 154, 154, 154),
                  height: 1,
                ),
              ),

              //Salminya Campus Name
              SizedBox(height: 20),
              KeepersLabel(text: "Salminya Campus  "),
              SizedBox(height: 15),

              //Salminya Room Containers
              KeepersContainer(
                code: "X",
                title: "College of Health and Sciences - 1078",
                circleColor: salminyaCircle,
                fillColor: salminyaFill,
                borderColor: salminyaBorder,
              ),
              SizedBox(height: 100),
            ],
          ),
        ],
      ),
    );
  }
}
