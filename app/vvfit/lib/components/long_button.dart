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
    return SizedBox(
      width: 320, // 고정된 너비 설정
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Color(0xff6BBEE2), // 버튼 배경색
          shadowColor: Colors.grey.withOpacity(0.7), // 그림자 색상
          elevation: 10, // 그림자 높이
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // 둥근 모서리
          ),
          padding: EdgeInsets.symmetric(vertical: 15), // 버튼 패딩, horizontal 제거
        ),
        onPressed: onPressed,
        child: Text(
          text,
          textAlign: TextAlign.center, // 텍스트 가운데 정렬
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
