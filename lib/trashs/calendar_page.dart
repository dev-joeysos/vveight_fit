import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              // 달력 위젯
              Container(
                padding: EdgeInsets.all(8.0), // 컨테이너 내부에 패딩 추가
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey), // 테두리 색상 지정
                  borderRadius: BorderRadius.circular(10.0), // 테두리 둥근 처리
                ),
                child: SizedBox(
                  width: 360.0,
                  height: 350.0, // 달력 내용이 충분히 표시될 수 있는 세로 크기
                  child: TableCalendar(
                    focusedDay: DateTime.now(),
                    firstDay: DateTime(2020),
                    lastDay: DateTime(2030),
                    // TableCalendar의 다른 설정들...
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
