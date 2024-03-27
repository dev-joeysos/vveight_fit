import 'package:flutter/material.dart';
import 'package:flutter_project/screens/login_page.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {

    // set delay time as 3 sec, Navigate to HomeScreen()
    Future.delayed(Duration(seconds: 0)).then((value) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ), (route) => false);
    });

    return Scaffold(
      body: Stack(
        children: [
          Image.asset('assets/images/background.jpg')
        ],
      ),
    );
  }
}
