import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_project/components/my_button.dart';
import 'package:flutter_project/components/my_textfield.dart';
import '../../components/round_title.dart';
import '../main_screens/main_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  void signUserIn(BuildContext context) async {
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

    // 로딩 상태를 true로 설정
    setState(() {
      isLoading = true;
    });

    // API 요청 보내기
    try {
      final response = await http.post(
        Uri.parse('http://52.79.236.191:3000/api/workout/getAll'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'user_id': '00001'}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainPage(data: data), // 데이터 전달
          ),
        );
      } else {
        showErrorDialog('Failed to load data: ${response.reasonPhrase}');
      }
    } catch (error) {
      showErrorDialog('Error: $error');
    } finally {
      // 로딩 상태를 false로 설정
      setState(() {
        isLoading = false;
      });
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('오류'),
          content: Text(message),
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
            child: isLoading
                ? CircularProgressIndicator() // 로딩 중일 때 표시할 위젯
                : Column(
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
