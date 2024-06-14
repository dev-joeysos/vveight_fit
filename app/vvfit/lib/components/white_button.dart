import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class whiteButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  whiteButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white, // 배경색을 흰색으로 설정
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 9),
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        side: BorderSide(
          color: Colors.black, // 보더 색상 설정
          width: 1, // 보더 두께 설정
        ),
        shadowColor: Colors.black.withOpacity(0.5), // 그림자 색상 설정
        elevation: 5, // 그림자 높이 설정
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.black, // 텍스트 색상을 검은색으로 설정
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
