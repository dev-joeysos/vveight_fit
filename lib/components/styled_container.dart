import 'package:flutter/material.dart';

class StyledContainer extends StatelessWidget {
  final String text;
  final double paddingVertical;
  final double paddingHorizontal;

  const StyledContainer({
    Key? key,
    required this.text,
    this.paddingVertical = 24.0,
    this.paddingHorizontal = 120.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: paddingVertical, horizontal: paddingHorizontal),
      decoration: BoxDecoration(
        color: Color(0xff143365), // 배경색을 검은색으로 설정
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: Colors.white), // 텍스트 색상을 흰색으로 설정
      ),
    );
  }
}
