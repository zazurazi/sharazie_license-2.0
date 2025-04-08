import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextStyle textStyle;
  final Widget? suffixIcon;

  const MyTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.textStyle,
    this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
      child: Material(
        elevation: 6, // Floating effect
        shadowColor: Colors.black26,
        borderRadius: BorderRadius.circular(30),
        child: TextField(
          obscureText: obscureText,
          controller: controller,
          style: textStyle.copyWith(fontFamily: 'SFProRounded'),
          decoration: InputDecoration(
            labelText: hintText,
            labelStyle: const TextStyle(
              fontFamily: 'SFProRounded',
              color: Colors.black87,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none, // No harsh border
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: const BorderSide(color: Colors.black, width: 1.2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: const BorderSide(color: Colors.grey, width: 1.0),
            ),
            filled: true,
            fillColor: Colors.white, // Ensures clean floating look
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Colors.black45,
              fontFamily: 'SFProRounded',
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            suffixIcon: suffixIcon, // Allows optional icons
          ),
        ),
      ),
    );
  }
}
