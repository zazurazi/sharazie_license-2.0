import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../auth/auth_page.dart';// Redirect to AuthPage after logout

class UserDashboard extends StatelessWidget {
  const UserDashboard({Key? key}) : super(key: key);

  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AuthPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Dashboard"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 100, color: Colors.teal),
            SizedBox(height: 20),
            Text(
              "Welcome, User!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Add user functionalities here
              },
              child: Text("View License"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Add more user-specific features here
              },
              child: Text("Update Profile"),
            ),
          ],
        ),
      ),
    );
  }
}
