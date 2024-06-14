import 'package:flutter/material.dart';

class StyledButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  StyledButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xff6AC7F0),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 9),
        textStyle: TextStyle(
          fontSize: 15,

        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(60),
        ),
        shadowColor: Colors.black.withOpacity(0.9), // 그림자 색상 설정
        elevation: 5, // 그림자 높이 설정
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
