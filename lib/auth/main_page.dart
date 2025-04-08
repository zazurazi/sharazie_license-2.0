import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../biometric/biometric_auth.dart';
import '../pages/home_page.dart';
import '../admin/admin_dashboard.dart';
import '../pages/otp_verification.dart';
import 'auth_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final BiometricAuth _biometricAuth = BiometricAuth();
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();

    /// Authenticate user using biometrics before proceeding
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticateUser();
    });
  }

  Future<void> _authenticateUser() async {
    bool isAuthenticated = await _biometricAuth.authenticate();
    if (!mounted) return;

    setState(() {
      _isAuthenticated = isAuthenticated;
    });

    if (!isAuthenticated) {
      _showAuthFailedDialog();
    }
  }

  Future<bool> _isOtpVerified() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('otp_verified') ?? false;
  }

  void _showAuthFailedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Authentication Failed'),
        content: const Text('Biometric authentication failed. Please try again.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _authenticateUser();
            },
            child: const Text('Retry'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('otp_verification')
            .doc(user.uid)
            .delete();

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove('otp_verified');

        await _auth.signOut();

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => AuthPage()),
              (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      print("Error during logout: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const AuthPage();
          }

          return FutureBuilder<bool>(
            future: _isOtpVerified(),
            builder: (context, otpSnapshot) {
              if (otpSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (otpSnapshot.data == false) {
                return OtpVerificationPage(
                  userId: snapshot.data!.uid,
                  email: snapshot.data!.email!,
                );
              }

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(snapshot.data!.uid)
                    .get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                    return const AuthPage();
                  }

                  final userRole = userSnapshot.data!.get('role');
                  if (userRole == 'admin') {
                    return const AdminDashboard();
                  }

                  return const Homepage();
                },
              );
            },
          );
        },
      ),
    );
  }
}
