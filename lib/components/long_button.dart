import 'package:flutter/material.dart';

class LongButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const LongButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Color(0xff6BBEE2), // 버튼 배경색
        shadowColor: Colors.grey.withOpacity(0.5), // 그림자 색상
        elevation: 10, // 그림자 높이
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // 둥근 모서리
        ),
        padding: EdgeInsets.symmetric(horizontal: 90, vertical: 15), // 버튼 패딩
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
