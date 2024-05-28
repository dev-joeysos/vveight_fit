import 'dart:math';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime? _selectedDay;
  final Random _random = Random();
  String _imageAsset = '';

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _updateScoreImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //     children: [
      //       Text(
      //         '베이트핏',
      //         style: TextStyle(color: Colors.white),
      //       ),
      //     ],
      //   ),
      //   actions: <Widget>[
      //     IconButton(
      //       icon: Icon(
      //         Icons.settings,
      //         color: Colors.white,
      //       ),
      //       onPressed: () {
      //         // 설정 아이콘 클릭 시 수행할 작업
      //       },
      //     ),
      //   ],
      //   backgroundColor: Colors.blue,
      // ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 15),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: Container(
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipOval(
                            child: Image.asset(
                              'assets/images/puang_done.jpeg',
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 15),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '안녕하세요 푸앙님',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '운동 31일째',
                                  style: TextStyle(
                                    color: Color(0xff6AC7F0),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                if (_imageAsset.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1.0),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Image.asset(
                        _imageAsset,
                        height: 200,
                      ),
                    ),
                  ),
                const SizedBox(height: 30),
                Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: SizedBox(
                    child: TableCalendar(
                      locale: 'ko_KR',
                      focusedDay: DateTime.now(),
                      firstDay: DateTime(2020),
                      lastDay: DateTime(2030),
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleTextStyle: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff3168A3),
                        ),
                        titleCentered: true,
                      ),
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          height: 0,
                        ), // Set height to 0 to hide the text
                        weekendStyle: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          height: 0,
                        ), // Set height to 0 to hide the text
                      ),
                      calendarStyle: CalendarStyle(
                        defaultTextStyle: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff3168A3),
                        ),
                        selectedTextStyle: TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                        ),
                        todayTextStyle: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff6AC7F0),
                        ),
                        weekendTextStyle: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff3168A3),
                        ),
                        todayDecoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xff1A3263),
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Color(0xff6AC7F0),
                        ),
                      ),
                      rowHeight: 36.0,
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _updateScoreImage();
                        });
                      },
                      calendarBuilders: CalendarBuilders(
                        defaultBuilder: (context, day, focusedDay) {
                          return Center(
                            child: Text(
                              '${day.day}',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff3168A3),
                              ),
                            ),
                          );
                        },
                        todayBuilder: (context, day, focusedDay) {
                          return Center(
                            child: Text(
                              '${day.day}',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff6AC7F0),
                              ),
                            ),
                          );
                        },
                        selectedBuilder: (context, day, focusedDay) {
                          return Center(
                            child: Text(
                              '${day.day}',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                        outsideBuilder: (context, day, focusedDay) {
                          return Center(
                            child: Text(
                              '${day.day}',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _updateScoreImage() {
    int randomScore = _random.nextInt(100);
    if (randomScore < 50) {
      _imageAsset = 'assets/images/p_worst.png';
    } else if (randomScore >= 50 && randomScore < 70) {
      _imageAsset = 'assets/images/p_default.png';
    } else {
      _imageAsset = 'assets/images/p_good.png';
    }
  }
}
