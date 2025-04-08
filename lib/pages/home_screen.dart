import 'package:flutter/material.dart';
import 'certificate_page.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity, // Full width
        height: double.infinity, // Full height
        color: Colors.white, // Set white background for the whole page
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // Align content to top
          children: [
            const SizedBox(height: 150), // Space from top
            Text(
              "Sharazie",
              style: TextStyle(
                fontFamily: "SFProRounded",
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Innovating The Way You Get Licensed",
              style: TextStyle(
                fontFamily: "SFProRounded",
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),// Space between text and image
            Center(
              child: SizedBox(
                height: 360,
                width: 360,
                child: Image.asset(
                  "lib/assets/homewallpaper.jpeg",
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(23.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CertificatePage()),
              );
            },
            child: Image.asset(
              'lib/assets/logo.jpeg',
              height: 90,
            ),
          ),
        ),
      ),
    );
  }
}
