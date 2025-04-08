import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Uint8List? _image;
  File? selectedImage;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController icController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProfileData(); // Load user profile data from Firestore
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min, // Makes the Row take only as much space as needed
          children: [
            Image.asset(
              'lib/assets/logo.jpeg',
              width: 35, // Adjust the width if necessary
              height: 35,
            ),
            const SizedBox(width: 1), // Reduced space
            const Text(
              "Profile",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'SFProRounded',
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Stack(
                children: [
                  // Profile image with border
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey, width: 4),
                    ),
                    child: _image != null
                        ? CircleAvatar(radius: 80, backgroundImage: MemoryImage(_image!))
                        : const CircleAvatar(
                      radius: 70,
                      backgroundImage: NetworkImage(
                          "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png"),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 10,
                    child: IconButton(
                      onPressed: () {
                        showImagePickerOption(context);
                      },
                      icon: const Icon(Icons.add_a_photo, size: 30, color: Colors.blue),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 30),

              // Form fields
              buildTextField("Full Name", nameController),
              buildTextField("IC Number", icController),
              buildTextField("Email", emailController),
              buildTextField("Phone Number", phoneController),
              buildTextField("Gender", genderController),
              buildTextField("Date of Birth", dobController),

              const SizedBox(height: 20),

              // Save button
              ElevatedButton(
                onPressed: saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  elevation: 10,
                ),
                child: const Text(
                  "Save",
                  style: TextStyle(fontSize: 18, color: Colors.black, fontFamily: 'SFProRounded'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontFamily: 'SFProRounded'),
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.black, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.black, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.black, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        style: const TextStyle(fontFamily: 'SFProRounded'),
      ),
    );
  }

  void showImagePickerOption(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.grey[200],
      context: context,
      builder: (builder) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: _pickImageFromGallery,
                  child: Column(mainAxisSize: MainAxisSize.min, children: const [
                    Icon(Icons.image, size: 80),
                    Text("Gallery", style: TextStyle(fontFamily: 'SFProRounded')),
                  ]),
                ),
                InkWell(
                  onTap: _pickImageFromCamera,
                  child: Column(mainAxisSize: MainAxisSize.min, children: const [
                    Icon(Icons.camera_alt_outlined, size: 80),
                    Text("Camera", style: TextStyle(fontFamily: 'SFProRounded')),
                  ]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future _pickImageFromGallery() async {
    final returnImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnImage == null) return;
    setState(() {
      selectedImage = File(returnImage.path);
      _image = File(returnImage.path).readAsBytesSync();
    });
    saveImage(_image!);
    Navigator.of(context).pop();
  }

  Future _pickImageFromCamera() async {
    final returnImage = await ImagePicker().pickImage(source: ImageSource.camera);
    if (returnImage == null) return;
    setState(() {
      selectedImage = File(returnImage.path);
      _image = File(returnImage.path).readAsBytesSync();
    });
    saveImage(_image!);
    Navigator.of(context).pop();
  }

  Future<void> saveProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'name': nameController.text,
      'id': icController.text,
      'email': emailController.text,
      'phone': phoneController.text,
      'gender': genderController.text,
      'dob': dobController.text,
      'profileImage': _image != null ? base64Encode(_image!) : "",
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile Saved Successfully!", style: TextStyle(fontFamily: 'SFProRounded'))));
  }

  Future<void> saveImage(Uint8List imageBytes) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String base64Image = base64Encode(imageBytes);
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'profileImage': base64Image});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile Image Updated Successfully!", style: TextStyle(fontFamily: 'SFProRounded'))));
  }

  Future<void> loadProfileData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    if (userDoc.exists) {
      setState(() {
        nameController.text = userDoc['name'] ?? "";
        icController.text = userDoc['id'] ?? "";
        emailController.text = userDoc['email'] ?? "";
        phoneController.text = userDoc['phone'] ?? "";
        genderController.text = userDoc['gender'] ?? "";
        dobController.text = userDoc['dob'] ?? "";
        String? profileImageUrl = userDoc['profileImage'];
        if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
          _image = base64Decode(profileImageUrl);
        }
      });
    }
  }
}
