import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:unifind/Pages/login.dart';
import 'package:unifind/Pages/signup.dart';
import 'package:unifind/Pages/splash.dart';
import 'package:unifind/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Splash(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(255, 86, 69, 139),
        ),
      ),
      routes: {
        'splashpage': (context) => Splash(),
        'loginpage': (context) => Login(),
        'signuppage': (context) => Signup(),
      },
    );
  }
}
