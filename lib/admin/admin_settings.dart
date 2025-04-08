import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSettingsPage extends StatefulWidget {
  @override
  _AdminSettingsPageState createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  User? user;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    _loadAdminData();
  }

  void _loadAdminData() async {
    if (user != null) {
      DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(user!.uid).get();
      setState(() {
        _nameController.text = userDoc['name'];
        _emailController.text = userDoc['email'];
      });
    }
  }

  Future<void> _updateProfile() async {
    try {
      await _firestore.collection('users').doc(user!.uid).update({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
      });

      await user!.updateEmail(_emailController.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _changePassword() async {
    try {
      await _auth.sendPasswordResetEmail(email: user!.email!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset link sent to email.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background color set to white
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black), // Black icon color
        title: Row(
          children: [
            Image.asset("lib/assets/logo.jpeg", height: 40), // Logo added to title
            const SizedBox(width: 0),
            const Text(
              "Admin Settings",
              style: TextStyle(
                fontFamily: 'SFProRounded',
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              style: const TextStyle(
                fontFamily: 'SFProRounded', // Font applied to input text
                color: Colors.black,
              ),
              decoration: InputDecoration(
                labelText: "Name",
                labelStyle: const TextStyle(
                  fontFamily: 'SFProRounded', // Font applied to label text
                  color: Colors.black,
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(40)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              style: const TextStyle(
                fontFamily: 'SFProRounded', // Font applied to input text
                color: Colors.black,
              ),
              decoration: InputDecoration(
                labelText: "Email",
                labelStyle: const TextStyle(
                  fontFamily: 'SFProRounded', // Font applied to label text
                  color: Colors.black,
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(40)),
              ),
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                Center(
                  child: ElevatedButton(
                    onPressed: _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(60),
                      ),
                      elevation: 3,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      minimumSize: const Size(0, 40),
                    ),
                    child: const Text(
                      "Update Profile",
                      style: TextStyle(
                        fontFamily: 'SFProRounded',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: ElevatedButton(
                    onPressed: _changePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(60),
                      ),
                      elevation: 3,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      minimumSize: const Size(0, 40),
                    ),
                    child: const Text(
                      "Change Password",
                      style: TextStyle(
                        fontFamily: 'SFProRounded',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
