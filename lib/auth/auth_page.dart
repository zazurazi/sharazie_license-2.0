import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sharazie_license/pages/loginScreen.dart';
import 'package:sharazie_license/pages/register_page.dart';
import 'package:sharazie_license/admin/admin_dashboard.dart'; // Admin Page
import 'package:sharazie_license/pages/home_page.dart'; // User Page
import '../pages/otp_verification.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool showLoginPage = true;
  bool isLoading = true;
  String? role; // Stores the user role

  @override
  void initState() {
    super.initState();
    checkUserRole(); // Check the user's role on startup
  }

  void toggleScreens() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  Future<void> checkUserRole() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => isLoading = false); // No user logged in, show login/register
      return;
    }

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        setState(() => isLoading = false);
        return;
      }

      String role = userDoc['role'] ?? "";
      bool isOtpVerified = userDoc['isOtpVerified'] ?? false;

      if (!isOtpVerified) {
        // Redirect to OTP Page if not verified
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationPage(
              userId: user.uid,
              email: user.email!,
            ),
          ),
        );
      } else if (role == "admin") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminDashboard()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Homepage()),
        );
      }
    } catch (e) {
      print("Error checking user role: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()), // Show loading spinner
      );
    }

    if (role == "admin") {
      return AdminDashboard(); // Redirect to admin dashboard
    } else if (role == "user") {
      return Homepage(); // Redirect to user dashboard
    } else {
      return showLoginPage
          ? LoginPage(showRegisterPage: toggleScreens)
          : RegisterPage(showLoginPage: toggleScreens);
    }
  }
}
