import 'package:flutter/material.dart';
import 'package:unifind/Components/my_button.dart';

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 249, 249, 249),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 150),
          child: Column(
            children: [
              //1-Welcome Message
              Text(
                "Welcome to UniFind",
                style: TextStyle(
                  fontWeight: FontWeight.bold,

                  fontSize: 35,
                  color: Colors.black,
                ),
              ),

              //2-Logo Image
              Padding(padding: EdgeInsetsGeometry.only(top: 60)),
              Image(
                image: AssetImage('assets/logo_recolored.png'),
                height: 300,
                width: 300,
              ),

              //3-Register Button
              Padding(padding: EdgeInsetsGeometry.only(top: 100)),
              MyButton(
                text: 'SignUp',
                onTap: () {
                  Navigator.pushNamed(context, 'signuppage');
                },
              ),

              //4- Login Button
              Padding(padding: EdgeInsetsGeometry.only(top: 50)),
              MyButton(
                text: 'Login',
                onTap: () {
                  Navigator.pushNamed(context, 'loginpage');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
