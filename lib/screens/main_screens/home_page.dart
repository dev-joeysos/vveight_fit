import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../provider/workout_save_success.dart';

class HomePage extends StatefulWidget {
  final dynamic initialData;

  const HomePage({super.key, required this.initialData});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime? _selectedDay;
  DateTime _focusedDay = DateTime.now();
  String _imageAsset = '';
  final Map<DateTime, List<dynamic>> _events = {};
  Map<String, dynamic>? _workoutDetails;
  dynamic _data;
  WorkoutSaveProvider? _workoutSaveProvider;

  @override
  void initState() {
    super.initState();
    _data = widget.initialData;
    print('초기 데이터: ${List.from(_data.reversed)}'); // 역순 출력
    _selectedDay = DateTime.now();
    _updateImageBasedOnStatus(_selectedDay!);
    _prepareEventMap();
    print('데이터 업데이트: ${List.from(_data.reversed)}'); // 역순 출력
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<WorkoutSaveProvider>(context);
    if (_workoutSaveProvider != provider) {
      _workoutSaveProvider?.removeListener(_handleSaveStatusChange);
      _workoutSaveProvider = provider;
      _workoutSaveProvider?.addListener(_handleSaveStatusChange);
    }
  }

  @override
  void dispose() {
    _workoutSaveProvider?.removeListener(_handleSaveStatusChange);
    super.dispose();
  }

  void _handleSaveStatusChange() async {
    final isSaved = _workoutSaveProvider?.isSaved ?? false;
    if (isSaved) {
      print('Old Data: ${List.from(_data.reversed)}');
      await _fetchNewData();
      print('New Data: ${List.from(_data.reversed)}');
      _prepareEventMap();
      print('Prepared events: $_events'); // 추가된 이벤트 출력
      _workoutSaveProvider?.setSaved(false);
    }
  }

  Future<void> _fetchNewData() async {
    const url = 'http://52.79.236.191:3000/api/workout/getAll';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'user_id': '00001'}),
      );

      if (response.statusCode == 200) {
        final newData = json.decode(response.body);
        setState(() {
          _data = newData;
          _prepareEventMap();  // 새로운 데이터로 이벤트 맵 갱신
        });
      } else {
        print('Failed to fetch new data: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error fetching new data: $error');
    }
  }

  void _prepareEventMap() {
    _events.clear();
    for (var workout in _data) {
      DateTime workoutDate = DateTime.parse(workout['date']).toLocal();
      workoutDate = DateTime(workoutDate.year, workoutDate.month, workoutDate.day);
      if (_events[workoutDate] == null) {
        _events[workoutDate] = [];
      }
      _events[workoutDate]!.add(workout);
    }

    // 날짜별로 이벤트를 정렬하고 가장 큰 workout_id를 가진 이벤트만 남김
    _events.forEach((key, value) {
      value.sort((a, b) => b['workout_id'].compareTo(a['workout_id'])); // workout_id 기준으로 정렬
      _events[key] = [value.first]; // 가장 큰 workout_id를 가진 이벤트를 선택
    });

    print('Prepared events: $_events'); // 추가된 이벤트 출력
  }


  Future<void> _fetchWorkoutDetails(int workoutId) async {
    const url = 'http://52.79.236.191:3000/api/workout/getDetails';
    final body = json.encode({
      'user_id': '00001',
      'workout_id': workoutId,
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _workoutDetails = responseData as Map<String, dynamic>?;
        });
        print('Received workout details: $responseData');
      } else {
        print('Failed to fetch workout details: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error fetching workout details: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: Container(
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipOval(
                            child: Image.asset(
                              'assets/images/puang_done.jpeg',
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 16),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '안녕하세요 푸앙님!',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
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
                const SizedBox(height: 5),
                if (_workoutDetails != null)
                  SizedBox(
                    height: 300, // Adjust the height as needed
                    child: PageView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Image.asset(
                            _imageAsset,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              if (_workoutDetails?['routine_id'] == null)
                                Text(
                                  _getExerciseName(_workoutDetails?['test_regression']?['exercise_id']) ?? 'LV 프로필',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              else
                                Text(
                                  _getExerciseName(_workoutDetails?['exercise_id']) ?? 'No Exercise ID',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                              SizedBox(height: 12),
                              SizedBox(
                                  height: 210,
                                  width: 300,
                                  child: LineChart(
                                    LineChartData(
                                      minY: 0,
                                      maxY: 1.0,
                                      lineBarsData: [
                                        if (_workoutDetails!['workout_regression'] != false)
                                          LineChartBarData(
                                            spots: _getLineSpots(_workoutDetails!['workout_regression']),
                                            isCurved: false,
                                            color: Color(0xff143365),
                                            barWidth: 5,
                                            isStrokeCapRound: false,
                                            belowBarData: BarAreaData(show: false),
                                            dotData: FlDotData(show: false),
                                          ),
                                        LineChartBarData(
                                          spots: _getLineSpots(_workoutDetails!['test_regression']),
                                          isCurved: false,
                                          color: Color(0xff6BBEE2),
                                          barWidth: 5,
                                          dashArray: [10, 8],
                                          isStrokeCapRound: false,
                                          belowBarData: BarAreaData(show: false),
                                          dotData: FlDotData(show: false),
                                        ),
                                      ],
                                      titlesData: FlTitlesData(
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            interval: 0.2,
                                            getTitlesWidget: (value, meta) {
                                              if (value == 0) {
                                                return Container(); // Hide the left bottom 0.0 value
                                              }
                                              return Padding(
                                                padding: const EdgeInsets.only(right: 4.0),
                                                child: Text(
                                                  value.toStringAsFixed(1),
                                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            interval: 5, // Set interval to 5
                                            getTitlesWidget: (value, meta) {
                                              return Padding(
                                                padding: const EdgeInsets.only(top: 4.0),
                                                child: Text(
                                                  '${value.toInt()}kg',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        rightTitles: AxisTitles(
                                          sideTitles: SideTitles(showTitles: false),
                                        ),
                                        topTitles: AxisTitles(
                                          sideTitles: SideTitles(showTitles: false),
                                        ),
                                      ),
                                      gridData: FlGridData(
                                        show: true,
                                        horizontalInterval: 0.2,
                                        drawVerticalLine: false,
                                      ),
                                      borderData: FlBorderData(
                                        show: true,
                                        border: Border.all(
                                          color: Colors.grey,
                                          width: 1,
                                        ),
                                      ),
                                      clipData: FlClipData.all(),
                                    ),
                                  )

                              ),
                            ],
                          ),
                        ),
                        if (_imageAsset.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Container(
                              child: Image.asset(
                                _imageAsset,
                                height: 150,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: SizedBox(
                    child: TableCalendar(
                      locale: 'ko_KR',
                      focusedDay: _focusedDay,
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
                        ),
                        weekendStyle: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          height: 0,
                        ),
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
                          shape: BoxShape.circle,
                          color: Colors.black, // 검은색 원으로 선택된 날짜 표시
                        ),
                      ),
                      rowHeight: 36.0,
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                          _updateImageBasedOnStatus(selectedDay);
                        });
                        _showWorkoutInfo(selectedDay);
                      },
                      calendarBuilders: CalendarBuilders(
                        defaultBuilder: (context, day, focusedDay) {
                          bool isEventDay = _events[
                          DateTime(day.year, day.month, day.day)] !=
                              null &&
                              _events[DateTime(day.year, day.month, day.day)]!
                                  .isNotEmpty;
                          return Center(
                            child: Text(
                              '${day.day}',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color:
                                isEventDay ? Color(0xff6AC7F0) : Color(0xff3168A3),
                              ),
                            ),
                          );
                        },
                        todayBuilder: (context, day, focusedDay) {
                          return Center(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xff1A3263),
                              ),
                              padding: const EdgeInsets.all(6.0),
                              child: Text(
                                '${day.day}',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff6AC7F0),
                                ),
                              ),
                            ),
                          );
                        },
                        selectedBuilder: (context, day, focusedDay) {
                          return Center(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black, // 검은색 원으로 선택된 날짜 표시
                              ),
                              padding: const EdgeInsets.all(6.0),
                              child: Text(
                                '${day.day}',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.white,
                                ),
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
                      eventLoader: (day) {
                        return _events[
                        DateTime(day.year, day.month, day.day)] ??
                            [];
                      },
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
  List<FlSpot> _getLineSpots(Map<String, dynamic> regressionData) {
    double slope = double.parse(regressionData['slope'].toString());
    double yIntercept = double.parse(regressionData['y_intercept'].toString());
    double maxX = double.parse(_workoutDetails?['test_regression']?['one_rep_max']?.toString() ?? '80.0');
    maxX = (maxX / 10).ceil() * 10; // Round up to the nearest 10
    List<FlSpot> spots = [];
    for (double x = maxX; x >= maxX - 20; x -= 5) {
      double y = slope * x + yIntercept;
      spots.add(FlSpot(x, y));
    }
    return spots;
  }

  void _updateImageBasedOnStatus(DateTime selectedDay) {
    DateTime dateOnly =
    DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    if (_events[dateOnly] != null && _events[dateOnly]!.isNotEmpty) {
      var status = _events[dateOnly]![0]['status'];
      switch (status) {
        case 'ready':
          _imageAsset = 'assets/images/p_training/ready.jpeg';
          break;
        case 'burning':
          _imageAsset = 'assets/images/p_training/burning.jpeg';
          break;
        case 'exhausted':
          _imageAsset = 'assets/images/p_training/exhausted.jpeg';
          break;
        default:
          _imageAsset = 'assets/images/p_training/ready.jpeg';
      }
    } else {
      _imageAsset = 'assets/images/p_default.png';
    }
  }

  void _showWorkoutInfo(DateTime selectedDay) {
    DateTime dateOnly =
    DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    if (_events[dateOnly] != null && _events[dateOnly]!.isNotEmpty) {
      var workout = _events[dateOnly]!.first; // 가장 최근의 운동 정보를 사용
      print(
          'Date: $dateOnly, Workout ID: ${workout['workout_id']}, Status: ${workout['status']}');
      _fetchWorkoutDetails(workout['workout_id']);
    } else {
      print('No workouts on this date.');
    }
  }
}

String? _getExerciseName(String? exerciseId) {
  switch (exerciseId) {
    case '00001':
      return '벤치 프레스 LV';
    case '00004':
      return '데드리프트 LV';
    case '00009':
      return '오버헤드 프레스 LV';
    case '00010':
      return '스쿼트 LV';
    default:
      return null;
  }
}
