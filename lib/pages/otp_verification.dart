import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/main_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';

Future<void> saveOtpVerifiedStatus(bool status) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('otp_verified', status);
}

class OtpVerificationPage extends StatefulWidget {
  final String userId;
  final String email;

  const OtpVerificationPage({Key? key, required this.userId, required this.email}) : super(key: key);

  @override
  _OtpVerificationPageState createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _otpController = TextEditingController();
  bool _isVerifying = false;
  bool _canResendOTP = false;
  Timer? _resendTimer;
  int _secondsLeft = 90;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    setState(() => _canResendOTP = false);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        setState(() => _canResendOTP = true);
        _resendTimer?.cancel();
      }
    });
  }

  Future<void> _verifyOTP() async {
    setState(() => _isVerifying = true);
    try {
      print("Fetching OTP for userId: ${widget.userId}");
      final doc = await FirebaseFirestore.instance.collection('otp_verification').doc(widget.userId).get();

      if (doc.exists) {
        final data = doc.data();
        print("Fetched OTP document data: $data");
        final storedOTP = data?['otp'];
        final enteredOTP = _otpController.text.trim();

        print("Stored OTP: $storedOTP, Entered OTP: $enteredOTP");

        if (enteredOTP == storedOTP) {
          await FirebaseFirestore.instance.collection('users').doc(widget.userId).set({'isOtpVerified': true}, SetOptions(merge: true));
          await saveOtpVerifiedStatus(true);
          await FirebaseFirestore.instance.collection('otp_verification').doc(widget.userId).delete();
          print("OTP verification successful. Redirecting to main page.");
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainPage()));
        } else {
          print("Incorrect OTP entered.");
          _showError("Incorrect OTP. Try again.");
        }
      } else {
        print("OTP document does not exist. Possibly expired.");
        _showError("OTP expired. Please log in again.");
      }
    } catch (e) {
      print("Error verifying OTP: $e");
      _showError("Error verifying OTP. Please try again.");
    }
    setState(() => _isVerifying = false);
  }

  Future<void> _resendOTP() async {
    try {
      print("Requesting OTP resend for: ${widget.email}");
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('sendOtpEmail');
      await callable.call({'email': widget.email});
      _secondsLeft = 90;
      _startResendTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("OTP has been resent to ${widget.email}"), duration: Duration(seconds: 2)),
      );
    } catch (e) {
      print("Failed to resend OTP: $e");
      _showError("Failed to resend OTP. Please try again.");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(2, 4))
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Enter OTP",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueGrey[800]),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "We've sent an OTP to ${widget.email}. Please enter it below:",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.blueGrey[600]),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 6,
                      style: const TextStyle(fontSize: 20, letterSpacing: 4),
                      decoration: InputDecoration(
                        hintText: "XXXXXX",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isVerifying ? null : _verifyOTP,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey[800],
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 36),
                      ),
                      child: _isVerifying
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Verify OTP", style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                    const SizedBox(height: 12),
                    _canResendOTP
                        ? TextButton(
                      onPressed: _resendOTP,
                      child: const Text("Resend OTP", style: TextStyle(fontSize: 14, color: Colors.blueGrey)),
                    )
                        : Text(
                      "Resend in $_secondsLeft seconds",
                      style: const TextStyle(fontSize: 14, color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
