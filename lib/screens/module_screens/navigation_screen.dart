import 'package:flutter/material.dart';
import 'package:roadfix/screens/module_screens/report_type_screen.dart';
import 'home_screen.dart';

// Give alias to prevent ProfileScreen conflict
import 'report_screen.dart';
import 'profile_screen.dart' as profile;

import 'package:roadfix/widgets/bottom_navbar_widgets/navigation_widget.dart';
import 'package:roadfix/widgets/themes.dart'; // includes `primary`, `secondary`, etc.

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ReportTypeScreen(),
    const ReportScreen(), // Make sure this class exists!
    const profile.ProfileScreen(), // Use alias to avoid conflict
  ];

  void _onItemTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: primary, // prevent white background
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.transparent,
        body: _screens[_currentIndex],
        bottomNavigationBar: NavigationWidget(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
