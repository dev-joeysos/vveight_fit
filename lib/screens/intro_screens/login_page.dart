import 'package:flutter/material.dart';
import 'package:flutter_project/components/my_button.dart';
import 'package:flutter_project/components/my_textfield.dart';
import '../../components/round_title.dart';
import '../main_screens/main_page.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  void signUserIn(BuildContext context) {
    // 사용자 입력 값 검증 예시 (실제로는 여기서 백엔드 인증 API를 호출해야 함)
    String username = usernameController.text;
    String password = passwordController.text;

    // 로그인 에러시 에러 메시지를 보여주는 대화상자 표시
    if (username.isEmpty || password.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('오류'),
            content: Text('이메일과 비밀번호를 입력해주세요.'),
            actions: <Widget>[
              TextButton(
                child: Text('확인'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    // 입력 값이 유효하다고 가정하고 Main Page로 이동
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xff0077FF),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 100),
                Image.asset('assets/images/vv_logo_white.png', height: 100),
                const SizedBox(height: 30),
                Text('당신의 근성장을 응원합니다',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                MyTextField(
                    controller: usernameController,
                    hintText: '이메일',
                    obscureText: false),
                const SizedBox(height: 20),
                MyTextField(
                    controller: passwordController,
                    hintText: '비밀번호',
                    obscureText: true),
                const SizedBox(height: 20),
                MyButton(
                  onTap: () => signUserIn(context),
                  text: "로그인",
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 35.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('회원가입',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                        Text('비밀번호를 모르겠어요',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                      ]),
                ),
                const SizedBox(height: 100),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    RoundTitle(imagePath: 'assets/images/google.png'),
                    SizedBox(width: 15),
                    RoundTitle(imagePath: 'assets/images/apple.png'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
