import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SystemConfigPage extends StatefulWidget {
  @override
  _SystemConfigPageState createState() => _SystemConfigPageState();
}

class _SystemConfigPageState extends State<SystemConfigPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _feeController = TextEditingController();
  final TextEditingController _expirationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    DocumentSnapshot doc = await _firestore.collection('settings').doc('license_config').get();
    if (doc.exists) {
      _feeController.text = doc['license_fee'].toString();
      _expirationController.text = doc['license_expiration'].toString();
    }
  }

  Future<void> _saveSettings() async {
    await _firestore.collection('settings').doc('license_config').set({
      'license_fee': double.parse(_feeController.text),
      'license_expiration': int.parse(_expirationController.text),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Settings updated!", style: TextStyle(fontFamily: 'SFProRounded'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Image.asset('lib/assets/logo.jpeg', height: 40),
            SizedBox(width: 0),
            Text("System Configurations", style: TextStyle(fontFamily: 'SFProRounded', fontSize: 25, color: Colors.black)),
          ],
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(50),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _feeController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: "License Fee",
                  labelStyle: TextStyle(fontFamily: 'SFProRounded'),
                ),
                style: TextStyle(fontFamily: 'SFProRounded'),
              ),
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(50),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _expirationController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: "License Expiration (Days)",
                  labelStyle: TextStyle(fontFamily: 'SFProRounded'),
                ),
                style: TextStyle(fontFamily: 'SFProRounded'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveSettings,
        backgroundColor: Colors.blue,
        child: Icon(Icons.save, color: Colors.white),
      ),
    );
  }
}
