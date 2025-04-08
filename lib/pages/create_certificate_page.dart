import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sharazie_license/pages/home_page.dart';
import 'package:sharazie_license/pages/home_screen.dart';
import 'package:sharazie_license/pages/payment_page.dart';
import 'package:sharazie_license/pages/pdf_generator.dart';
import 'profile_page.dart';

class CreateCertificatePage extends StatefulWidget {
  final String documentId;
  final Map certificateData;

  const CreateCertificatePage({
    Key? key,
    required this.documentId,
    required this.certificateData,
  }) : super(key: key);

  @override
  _CreateCertificatePageState createState() => _CreateCertificatePageState();
}

class _CreateCertificatePageState extends State<CreateCertificatePage> {
  final _formKey = GlobalKey<FormState>();
  final _certificateNumberController = TextEditingController();
  final _referenceNumberController = TextEditingController();
  final _academyName = TextEditingController();
  final _nameController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _courseDateController = TextEditingController();
  final _recognizedByController = TextEditingController();
  bool _isLoading = false;

  Future<void> _saveCertificate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("No user is currently signed in.");
      }

      final certificateData = {
        'certificateNumber': _certificateNumberController.text,
        'referenceNumber': _referenceNumberController.text,
        'academyName': _academyName.text,
        'name': _nameController.text,
        'idNumber': _idNumberController.text,
        'courseDate': _courseDateController.text,
        'recognizedBy': _recognizedByController.text,
        'status': 'pending',
        'createdBy': user.email, // 👈 Save the email here
      };

      await FirebaseFirestore.instance.collection('certificates').add(certificateData);

      // You can leave PDF generation here if required
      await generateCertificatePdf(
        certificateNumber: certificateData['certificateNumber']!,
        referenceNumber: certificateData['referenceNumber']!,
        name: certificateData['name']!,
        idNumber: certificateData['idNumber']!,
        courseDate: certificateData['courseDate']!,
        academyName: certificateData['academyName']!,
        academyEntity: 'Your Academy Entity',
        recognizedBy: certificateData['recognizedBy']!,
        courseName: 'Your Course Name',
        location: 'Your Location',
        instructorName: 'Instructor Name',
        instructorCertificateNumber: 'Instructor Cert No',
      );

      if (mounted) _showSuccessDialog();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving certificate: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'SFProRounded')),
          content: const Text('License submitted to admin for approval.', style: TextStyle(fontFamily: 'SFProRounded')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK', style: TextStyle(fontFamily: 'SFProRounded')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),
              _buildTitle(),
              const SizedBox(height: 15),
              _buildTextField(_certificateNumberController, 'License Number'),
              const SizedBox(height: 20),
              _buildTextField(_referenceNumberController, 'Phone Number'),
              const SizedBox(height: 20),
              _buildTextField(_academyName, 'License Name'),
              const SizedBox(height: 20),
              _buildTextField(_nameController, 'Name'),
              const SizedBox(height: 20),
              _buildTextField(_idNumberController, 'IC Number'),
              const SizedBox(height: 20),
              _buildTextField(_courseDateController, 'Date'),
              const SizedBox(height: 20),
              _buildTextField(_recognizedByController, 'Recognized By'),
              const SizedBox(height: 30),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildTitle() {
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('lib/assets/logo.jpeg', height: 45),
              const SizedBox(width: 0),
              const Text(
                'Create License',
                style: TextStyle(
                  fontSize: 29,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'SFProRounded',
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Fill in the data:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black54, fontFamily: 'SFProRounded'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(fontFamily: 'SFProRounded', fontSize: 20, color: Colors.black),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      style: const TextStyle(fontFamily: 'SFProRounded', fontSize: 16),
      validator: (value) => value!.isEmpty ? 'Required' : null,
    );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          elevation: 5,
        ),
        onPressed: _saveCertificate,
        child: const Text('Submit', style: TextStyle(fontSize: 18, fontFamily: 'SFProRounded')),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(topLeft: Radius.circular(29), topRight: Radius.circular(29)),
      child: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontFamily: 'SFProRounded', fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontFamily: 'SFProRounded'),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home, color: Colors.white), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person, color: Colors.white), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.credit_card_outlined, color: Colors.white), label: 'Payment'),
          BottomNavigationBarItem(icon: Icon(Icons.logout, color: Colors.white), label: 'Exit'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Homepage()));
              break;
            case 1:
              Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
              break;
            case 2:
              Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentPage()));
              break;
            case 3:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Homepage()));
              break;
          }
        },
      ),
    );
  }
}
