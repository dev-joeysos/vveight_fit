import 'package:flutter/material.dart';
import '../setting_screens/workout_selection_page.dart';
import 'home_page.dart';
import 'my_page.dart';

class MainPage extends StatefulWidget {
  final dynamic data;

  const MainPage({super.key, required this.data});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  List<Widget> _pages(dynamic data) {
    return [
      HomePage(initialData: data),
      HomePage(initialData: data),
      MyPage(),
      MyPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _pages(widget.data)[_currentIndex],
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                height: 60,
                width: 300,
                child: FloatingActionButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SelectPage()),
                    );
                  },
                  backgroundColor: Color(0xff6BBEE2),
                  child: Text(
                    '운동 시작하기',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 0.5,
            color: Color(0xff404040),
          ),
          Container(
            height: 60, // Adjust height as needed
            color: Colors.white, // Add background color to the Container
            child: BottomAppBar(
              color: Colors.white,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _currentIndex = 0;
                        });
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.home, size: 30, color: Colors.black),
                        ],
                      ),
                    ),
                  ),
                  // 주석 처리된 부분을 포함하거나 필요에 따라 다른 아이콘을 추가할 수 있습니다.
                  // Expanded(
                  //   child: InkWell(
                  //     onTap: () {
                  //       setState(() {
                  //         _currentIndex = 1;
                  //       });
                  //     },
                  //     child: Column(
                  //       mainAxisSize: MainAxisSize.min,
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         Icon(Icons.search, size: 30, color: Colors.black),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  // Expanded(
                  //   child: InkWell(
                  //     onTap: () {
                  //       setState(() {
                  //         _currentIndex = 2;
                  //       });
                  //     },
                  //     child: Column(
                  //       mainAxisSize: MainAxisSize.min,
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         Icon(Icons.bar_chart, size: 30, color: Colors.black),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _currentIndex = 3;
                        });
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.account_circle_outlined,
                              size: 30, color: Colors.black),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
