import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_project/components/my_button.dart';
import 'package:flutter_project/components/my_textfield.dart';
import 'package:flutter_project/components/round_title.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  // text editing controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  // sign user in method
  void signUserIn () {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0077FF),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
              // 메인 로고
              Image.asset(
                'assets/images/vv_logo_white.png',
                height: 100,
              ),

              const SizedBox(height: 50),
              // text
              Text(
                '당신의 근성장을 응원합니다!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 25),
              // id textfield
              MyTextField(
                controller: usernameController,
                hintText: '이메일',
                obscureText: false,
              ),

              const SizedBox(height: 20),
              // pw textfield
              MyTextField(
                controller: passwordController,
                hintText: '비밀번호',
                obscureText: true,
              ),

              const SizedBox(height: 20),

              // sign in button
              MyButton(
                onTap: signUserIn,
              ),

              const SizedBox(height: 20),

              // forgot pw
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '비밀번호를 모르겠어요',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Or continue with
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[200],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Text(
                          '또는',
                        style: TextStyle(
                          color: Colors.grey[200],
                        ),
                      ),
                    ),

                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[200],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // google, naver, kakao login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  // google button
                  RoundTitle(imagePath: 'assets/images/google.png'),

                  const SizedBox(width: 10),
                  // apple button
                  RoundTitle(imagePath: 'assets/images/apple.png'),
                ],
              ),

              const SizedBox(height: 20),
              // 계정이 없으신가요? 가입하기
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '계정이 없으신가요?',
                    style: TextStyle(color: Colors.grey[200]),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    '가입하기',
                    style: TextStyle(
                      color: Color(0xffFFE9B5),
                      fontWeight: FontWeight.bold,
                    )
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
