import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  // controller = access to textfield input
  final controller;
  final String hintText;
  final bool obscureText;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          labelStyle: TextStyle(color: Colors.blue), // 라벨 텍스트 색상 지정
          fillColor: Colors.grey.shade200, // textField 배경 색상 지정
          filled: true,
          hintText: hintText,
          hintStyle: TextStyle(color: Color(0xff7C7C8A)),
        ),
      ),
    );
  }
}
