import 'package:flutter/material.dart';
import 'package:roadfix/screens/auth_screens/login_screen.dart';
import 'package:roadfix/screens/auth_screens/signup_screen.dart';
import 'package:roadfix/screens/module_screens/profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RoadFix',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
