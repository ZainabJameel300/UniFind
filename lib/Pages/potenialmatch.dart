import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unifind/Components/my_appbar.dart';

class Potenialmatch extends StatefulWidget {
  const Potenialmatch({super.key});

  @override
  State<Potenialmatch> createState() => _PotenialmatchState();
}

class _PotenialmatchState extends State<Potenialmatch> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MyAppbar(
        title: "Potential Matches",
        onBack: () {
          Navigator.pushReplacementNamed(context, 'bottomnavBar');
        },
      ),
    );
  }
}
