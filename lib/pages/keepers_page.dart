import 'package:flutter/material.dart';
import 'package:unifind/Components/keepers_container.dart';
import 'package:unifind/Components/keepers_label.dart';
import 'package:unifind/Components/my_AppBar.dart';

class KeepersPage extends StatelessWidget {
  const KeepersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MyAppbar(
        title: "Keepers",
        onBack: () {
          Navigator.pushReplacementNamed(context, 'bottomnavBar');
        },
      ),
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
                code: "S40",
                title: "College of IT - 1078",
                circleColor: Color(0xFF771F98),
              ),
              SizedBox(height: 15),
              KeepersContainer(
                code: "S41",
                title: "College of Science - 2017",
                circleColor: Color(0xFF771F98),
              ),
              SizedBox(height: 15),
              KeepersContainer(
                code: "S41",
                title: "College of Science - 2017",
                circleColor: Color(0xFF771F98),
              ),
              SizedBox(height: 15),
              KeepersContainer(
                code: "S41",
                title: "College of Science - 2017",
                circleColor: Color(0xFF771F98),
              ),
              SizedBox(height: 15),
              KeepersContainer(
                code: "S41",
                title: "College of Science - 2017",
                circleColor: Color(0xFF771F98),
              ),
              SizedBox(height: 15),
              KeepersContainer(
                code: "S41",
                title: "College of Science - 2017",
                circleColor: Color(0xFF771F98),
              ),
              SizedBox(height: 15),
              KeepersContainer(
                code: "S41",
                title: "College of Science - 2017",
                circleColor: Color(0xFF771F98),
              ),
              SizedBox(height: 15),
              KeepersContainer(
                code: "S41",
                title: "College of Science - 2017",
                circleColor: Color(0xFF771F98),
              ),
              SizedBox(height: 15),
              KeepersContainer(
                code: "S41",
                title: "College of Science - 2017",
                circleColor: Color(0xFF771F98),
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
                code: "S40",
                title: "College of IT - 1078",
                circleColor: Color(0xFF771F98),
              ),
              SizedBox(height: 15),
              KeepersContainer(
                code: "S41",
                title: "College of Science - 2017",
                circleColor: Color(0xFF771F98),
              ),
              SizedBox(height: 15),
              KeepersContainer(
                code: "S41",
                title: "College of Science - 2017",
                circleColor: Color(0xFF771F98),
              ),
              SizedBox(height: 15),
              KeepersContainer(
                code: "S41",
                title: "College of Science - 2017",
                circleColor: Color(0xFF771F98),
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
                code: "S40",
                title: "College of IT - 1078",
                circleColor: Color(0xFF771F98),
              ),
              SizedBox(height: 100),
            ],
          ),
        ],
      ),
    );
  }
}
