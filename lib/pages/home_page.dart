import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sharazie_license/pages/profile_page.dart';
import 'home_screen.dart';
import 'profile_page.dart'; // ✅ Import ProfileScreen
import '../widget/navbar.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _currentIndex = 0;

  // ✅ List of screens with ProfileScreen included
  final List<Widget> _screens = [
    HomeScreen(),
    ProfileScreen(), // ✅ Replace placeholder with ProfileScreen
    Center(child: Text('Sign Out')), // Placeholder for sign-out action
  ];

  // Handle tab navigation
  void _onTabTapped(int index) async {
    if (index == 2) {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/login'); // Redirect to login screen
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex], // ✅ Display the selected screen
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTabTapped: _onTabTapped,
      ),
    );
  }
}
