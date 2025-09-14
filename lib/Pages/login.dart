import 'package:flutter/material.dart';
import 'package:unifind/components/my_button.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],

      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //Logo
              Image(
                image: AssetImage('assets/logo-small.png'),
                height: 160,
                width: 160,
              ),
              SizedBox(height: 25),

              //Login Message
              Text(
                "Login",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
              ),
              SizedBox(height: 10),

              //Welcoming Text Message
              Text(
                "Please fill in the details to login!",
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20),

              //Emial TextField
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  height: 55,
                  width: 380,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Email',
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 18),

              //Password TextField
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  height: 55,
                  width: 380,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Password',
                      ),
                    ),
                  ),
                ),
              ),
              // Forgot Password? link
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  children: [
                    Spacer(),
                    TextButton(
                      onPressed: () {
                        //Later
                      },
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: Color.fromARGB(255, 119, 31, 153),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 25),

              //Login Button
              MyButton(text: 'Login', onTap: () {}),
              SizedBox(height: 18),

              //Don't have an account ? SignUp!
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, 'signuppage');
                      },
                      child: Text(
                        "SignUp",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 119, 31, 153),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
