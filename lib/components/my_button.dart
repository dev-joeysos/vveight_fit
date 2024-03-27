import 'package:flutter/material.dart';
import 'package:flutter_project/screens/home_page.dart';

class MyButton extends StatelessWidget {

  final Function()? onTap;

  const MyButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 버튼의 재사용성을 높이는 방법은 없는가? 이거 버튼 하나 만들어 놓고 다른데서 쓰고 싶은데 어캐함
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.symmetric(horizontal: 35.0),
        decoration: BoxDecoration(
          color: Color(0xff6AC7F0),
          borderRadius: BorderRadius.circular(6)),
        child: const Center(
          child: Text(
            "로그인",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
