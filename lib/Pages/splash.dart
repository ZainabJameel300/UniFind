import 'package:flutter/material.dart';
import 'package:unifind/components/my_button.dart';

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
            SizedBox(height: 15),

            //2-Logo Image
            Image(
              image: AssetImage('assets/logo_recolored.png'),
              height: 300,
              width: 300,
            ),
            SizedBox(height: 50),

            //3-Register Button
            MyButton(
              text: 'SignUp',
              onTap: () {
                Navigator.pushNamed(context, 'signuppage');
              },
            ),
            SizedBox(height: 50),

            //4- Login Button
            MyButton(
              text: 'Login',
              onTap: () {
                Navigator.pushNamed(context, 'loginpage');
              },
            ),
          ],
        ),
      ),
    );
  }
}
