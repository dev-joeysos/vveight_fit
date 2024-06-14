import 'package:flutter/material.dart';

class StyledContainer extends StatelessWidget {
  final String text;

  const StyledContainer({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320, // 고정된 너비
      height: 50, // 고정된 높이
      alignment: Alignment.center, // 텍스트를 가운데로 정렬
      //padding: EdgeInsets.symmetric(horizontal: 120, vertical: 10), // 패딩 설정
      decoration: BoxDecoration(
        color: Color(0xff143365), // 배경색
        borderRadius: BorderRadius.circular(30), // 둥근 모서리
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), // 그림자 색상
            spreadRadius: 1,
            blurRadius: 5, // 그림자 흐림
            offset: Offset(0, 3), // 그림자 오프셋
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // 두 번째 그림자 색상
            spreadRadius: 1,
            blurRadius: 10, // 그림자 흐림
            offset: Offset(0, 6), // 그림자 오프셋
          ),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center, // 텍스트를 가운데 정렬
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.white, // 텍스트 색상
        ),
      ),
    );
  }
}
