import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:unifind/Pages/forgotpassword.dart';
import 'package:unifind/Pages/login.dart';
import 'package:unifind/Pages/signup.dart';
import 'package:unifind/Pages/splash.dart';
import 'package:unifind/auth/mainPage.dart';
import 'package:unifind/firebase_options.dart';
import 'package:unifind/pages/bottom_navbar.dart';
import 'package:unifind/providers/filter_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (context) => FilterProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Mainpage(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(255, 86, 69, 139),
        ),
      ),
      routes: {
        'splashpage': (context) => Splash(),
        'loginpage': (context) => Login(),
        'signuppage': (context) => Signup(),
        'forgotpasswordpage': (context) => Forgotpassword(),
        'bottomnavBar': (context) => BottomNavBar(),
      },
    );
  }
}
