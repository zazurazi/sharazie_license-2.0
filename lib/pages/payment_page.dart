import 'package:flutter/material.dart';

class PaymentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Ensures the entire background is white
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'lib/assets/logo.jpeg',
              height: 35,
            ),
            SizedBox(width: 1),
            Text(
              'Payment',
              style: TextStyle(
                fontFamily: 'SFProRounded',
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 1), // Moves everything down
          Text(
            'Scan Here To Pay',
            style: TextStyle(
              fontFamily: 'SFProRounded',
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 30), // Space between text and image
          Center(
            child: Container(
              height: 540, // Adjust size as needed
              width: 340,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20), // Rounds the image
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5), // Lighter shadow
                    blurRadius: 20, // Reduced blur for a softer effect
                    spreadRadius: 3, // Slightly smaller spread
                    offset: Offset(0, 3), // Slightly smaller offset
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20), // Ensures the image corners are rounded
                child: Image.asset(
                  'lib/assets/qr.jpeg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(height: 100), // Adds spacing at the bottom
        ],
      ),
    );
  }
}
