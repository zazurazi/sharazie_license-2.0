import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sharazie_license/pages/home_page.dart';
import 'package:sharazie_license/pages/register_page.dart';
import '../admin/admin_dashboard.dart';
import 'otp_verification.dart'; // Import OTP Verification Page
import 'smtp_service.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback showRegisterPage;
  const LoginPage({Key? key, required this.showRegisterPage}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String userId = userCredential.user!.uid;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        _showError("User data not found.");
        return;
      }

      String role = userDoc['role'] ?? "";
      bool isOtpVerified = userDoc.data().toString().contains('isOtpVerified')
          ? userDoc['isOtpVerified']
          : false;



      // Generate OTP
      String otp = _generateOtp();
      print("Generated OTP: $otp");  // Debugging

      // Store OTP in otp_verification collection
      await FirebaseFirestore.instance
          .collection('otp_verification')
          .doc(userId)
          .set({
        'otp': otp,
        'timestamp': FieldValue.serverTimestamp(),
      }).then((_) {
        print("OTP successfully stored in Firestore");  // Debugging
      }).catchError((error) {
        print("Error storing OTP in Firestore: $error");  // Debugging
      });



      // Create an instance of SmtpService
      SmtpService smtpService = SmtpService();

      // Send OTP via email
      bool emailSent = await smtpService.sendOTP(_emailController.text.trim(), otp);
      if (emailSent) {
        print("OTP email sent successfully");
      } else {
        print("Failed to send OTP email");
      }

      // Redirect to OTP Verification Page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationPage(
            userId: userId,
            email: _emailController.text.trim(),
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Login failed.");
    } finally {
      setState(() => _isLoading = false);
    }
  }


// Function to generate a 6-digit OTP
  String _generateOtp() {
    return (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontFamily: 'SFProRounded'),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Welcome to Sharazie',
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'SFProRounded',
                    color: Colors.black,
                    shadows: [
                      Shadow(
                        color: Colors.black45,
                        offset: Offset(1, 1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Image.asset('lib/assets/logo2.jpeg', width: 100),
                const SizedBox(height: 1),

                // Email Input
                _buildInputField(
                  controller: _emailController,
                  hintText: "Email",
                  obscureText: false,
                ),
                const SizedBox(height: 18),

                // Password Input
                _buildInputField(
                  controller: _passwordController,
                  hintText: "Password",
                  obscureText: !_isPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.white, // ✅ white icon
                    ),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                ),
                const SizedBox(height: 20),

                // Login Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : const Text("Log In",
                      style: TextStyle(fontSize: 18, color: Colors.black, fontFamily: 'SFProRounded')),
                ),

                const SizedBox(height: 15),

                // Register Link
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegisterPage(
                          showLoginPage: () {
                            Navigator.pop(context); // Go back to Login Page
                          },
                        ),
                      ),
                    );
                  },
                  child: const Text.rich(
                    TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'SFProRounded',
                        color: Colors.black,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(0, 0),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      children: [
                        TextSpan(
                          text: "Register Now",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'SFProRounded',
                            shadows: [
                              Shadow(
                                color: Colors.black38,
                                offset: Offset(0, 0),
                                blurRadius: 3,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              spreadRadius: 5,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(
            color: Colors.white, // ✅ Make input text white
            fontFamily: 'SFProRounded',
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              fontFamily: 'SFProRounded',
              color: Colors.white, // ✅ Make hint text lighter white
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.black,
            suffixIcon: suffixIcon,
          ),
        ),
      ),
    );
  }
}