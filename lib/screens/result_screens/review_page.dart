import 'dart:io';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../provider/workout_data.dart';
import '../../provider/workout_manager.dart';
import '../../provider/workout_save_success.dart';

class ReviewPage extends StatefulWidget {
  final int workoutDuration; // 운동 시간을 초 단위로 받습니다.
  final WorkoutData workoutData; // 운동 데이터 추가
  final Map<String, dynamic> compareData;

  // 그래프 그리기용 샘플 데이터
  final List<FlSpot>? testRegressionSpots = [
    FlSpot(45, 0.89),
    FlSpot(55, 0.65),
    FlSpot(60, 0.38),
  ];

  final List<FlSpot>? workoutRegressionSpots = [
    FlSpot(40, 1.0),
    FlSpot(50, 0.8),
    FlSpot(60, 0.6),
  ];

  ReviewPage({
    Key? key,
    required this.workoutDuration,
    required this.workoutData,
    required this.compareData,
  }) : super(key: key);

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  String _compareResult = '';

  @override
  void initState() {
    super.initState();
    print('Received compareData: ${widget.compareData}');
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  void _showPickOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('사진 추가'),
        content: Text('사진을 찍거나 갤러리에서 선택하세요.'),
        actions: <Widget>[
          TextButton(
            child: Text('카메라'),
            onPressed: () {
              _pickImage(ImageSource.camera);
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('갤러리'),
            onPressed: () {
              _pickImage(ImageSource.gallery);
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('취소'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _sendCompareData() async {
    const url = 'http://52.79.236.191:3000/api/workout/compare';
    try {
      final body = json.encode(widget.compareData);
      print('Request body: $body');
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      print('R: $body');
      if (response.statusCode == 200) {
        print('Data sent successfully');
        setState(() {
          _compareResult = response.body;
        });
        print(_compareResult);
      } else {
        print('Failed to send data: ${response.reasonPhrase}');
        setState(() {
          _compareResult = 'Failed to send data: ${response.reasonPhrase}\nResponse body: ${response.body}';
        });
      }
    } catch (error) {
      print('Error sending data: $error');
      setState(() {
        _compareResult = 'Error sending data: $error';
      });
    }
  }

  Future<void> _saveWorkoutData() async {
    const url = 'http://52.79.236.191:3000/api/workout/save';
    try {
      final compareResultMap = json.decode(_compareResult);
      final workoutRegressionData = compareResultMap['workout_regression'];
      final status = compareResultMap['status'];

      final body = json.encode({
        'user_id': '00001',
        'exercise_id': '00001',
        'exercise_name': 'Bench Press',
        'test_regression_id': compareResultMap['test_regression']['id'], // 여기서 test_regression_id 값을 가져옵니다.
        'workout_regression_data': workoutRegressionData,
        'status': status,
        'routine_id': widget.compareData['routine_id'],
      });
      print(widget.compareData['routine_id']);
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        print('Workout data saved successfully');
        print('workout_id: ${response.body}');
        // 응답 데이터 출력하기
        Provider.of<WorkoutSaveProvider>(context, listen: false).setSaved(true); // Update isSaved to true
      } else {
        print('Failed to save workout data: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error saving workout data: $error');
    }
  }

  List<FlSpot> _getLineSpots(Map<String, dynamic> regressionData) {
    double slope = double.parse(regressionData['slope'].toString());
    double yIntercept = double.parse(regressionData['y_intercept'].toString());
    List<FlSpot> spots = [];
    for (int i = 40; i <= 80; i += 5) {
      double x = i.toDouble();
      double y = slope * x + yIntercept;
      spots.add(FlSpot(x, y));
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> exerciseDetailsWidgets = widget.workoutData.exerciseDetails.entries.map((entry) {
      return ListTile(
        title: Text(entry.key),
        subtitle: Text('Sessions: ${entry.value.sessionCounts.join(", ")}, '
            'Weights: ${entry.value.weights.map((w) => w.toStringAsFixed(1)).join(", ")} kg'),
      );
    }).toList();

    String formattedDuration = formatDuration(widget.workoutDuration);
    Map<String, dynamic>? compareResultMap;
    List<FlSpot>? testRegressionSpots;
    List<FlSpot>? workoutRegressionSpots;
    String? status;

    if (_compareResult.isNotEmpty) {
      compareResultMap = json.decode(_compareResult);
      if (compareResultMap != null) {
        status = compareResultMap['status'];
        if (compareResultMap['test_regression'] != null) {
          testRegressionSpots = _getLineSpots(compareResultMap['test_regression']);
        }
        if (compareResultMap['workout_regression'] != null) {
          workoutRegressionSpots = _getLineSpots(compareResultMap['workout_regression']);
        }
      }
    }
    // 상태에 따른 이미지 설정
    String statusImageAsset;
    switch (status) {
      case 'burning':
        statusImageAsset = 'assets/images/p_training/burning.jpeg';
        break;
      case 'ready':
        statusImageAsset = 'assets/images/p_training/ready.jpeg';
        break;
      case 'normal':
        statusImageAsset = 'assets/images/p_good.png';
        break;
      case 'testrequired':
        statusImageAsset = 'assets/images/p_default.png';
        break;
      case 'exhausted':
        statusImageAsset = 'assets/images/p_training/exhausted.jpeg';
        break;
      default:
        statusImageAsset = 'assets/images/p_default.png';
        break;
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0077FF), // Background color as blue
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 90),
                    const Text(
                      '수고하셨어요!', // Main greeting text
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 30),
                            decoration: BoxDecoration(
                              color: const Color(0xffEEB3D1), // Light pink background
                              borderRadius: BorderRadius.circular(16), // Rounded corners
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(6), // Icon padding
                                  decoration: BoxDecoration(
                                    color: Color(0xff6AC7F0), // Container background color
                                    borderRadius: BorderRadius.circular(12), // Container corner radius
                                  ),
                                  child: Icon(Icons.timer, color: Colors.white), // Icon
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  formattedDuration,
                                  style: TextStyle(
                                    color: Color(0xff003376),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () => _showPickOptionsDialog(context),
                            child: Container(
                              height: 105,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Color(0xffEEB3D1), // 배경색
                              ),
                              child: Center(
                                child: _imageFile != null
                                    ? Image.file(File(_imageFile!.path),
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover)
                                    : Image.asset( // Display status image in place of camera icon
                                  statusImageAsset,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Todo: 그래프 완성 > 실제 운동 무게 가져와서 넣기
                    Container(
                        width: 640,
                        height: 360,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 240,
                                width: 300,
                                child: LineChart(
                                  LineChartData(
                                    minX: 40, // X축 최소값 설정
                                    maxX: 80, // X축 최대값 설정
                                    minY: 0, // Y축 최소값 설정
                                    maxY: 1.0, // Y축 최대값 설정
                                    lineBarsData: [
                                      if (workoutRegressionSpots != null)
                                        LineChartBarData(
                                          spots: workoutRegressionSpots,
                                          isCurved: false,
                                          color: Color(0xff143365),
                                          barWidth: 5,
                                          isStrokeCapRound: false,
                                          belowBarData: BarAreaData(show: false),
                                          dotData: FlDotData(show: false),
                                        ),
                                      if (testRegressionSpots != null)
                                        LineChartBarData(
                                          spots: testRegressionSpots,
                                          isCurved: false,
                                          color: Color(0xff6BBEE2),
                                          barWidth: 5,
                                          dashArray: [10, 8],
                                          isStrokeCapRound: false,
                                          belowBarData: BarAreaData(show: false),
                                          dotData: FlDotData(show: true), // Dot data를 보이도록 설정
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
                                              padding: const EdgeInsets.only(right: 0.0),
                                              child: Text(
                                                value.toStringAsFixed(1),
                                                style: TextStyle(fontSize: 15, color: Colors.grey),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
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
                                      show: false,
                                    ),
                                    lineTouchData: LineTouchData(
                                      touchTooltipData: LineTouchTooltipData(
                                        getTooltipItems: (touchedSpots) {
                                          return touchedSpots.map((touchedSpot) {
                                            return LineTooltipItem(
                                              '${touchedSpot.x}kg, ${touchedSpot.y.toStringAsFixed(2)}m/s',
                                              const TextStyle(color: Colors.black),
                                            );
                                          }).toList();
                                        },
                                      ),
                                    ),
                                    clipData: FlClipData.all(), // 경계선을 넘지 않도록 설정
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  'Mean Velocity',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                '45kg-0.89m/s, 55kg-0.65m/s, 60kg-0.38m/s',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      maxLines: null, // 여러 줄 입력 허용
                      onChanged: (value) {
                        // 텍스트 필드 값이 변경될 때마다 Provider를 통해 업데이트
                        Provider.of<WorkoutManager>(context, listen: false).updateReview(value);
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        // 배경색을 흰색으로 설정
                        hintText: '운동 후기 작성하기',
                        // 힌트 텍스트
                        contentPadding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                        // 내부 패딩 추가
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12), // 경계선 둥글게 처리
                          borderSide: BorderSide.none, // 경계선 없음
                        ),
                      ),
                    ),
                    // Todo: 오운완 사진 업로드
                    // IconButton(
                    //   icon: Icon(Icons.camera_alt, color: Colors.white),
                    //   onPressed: () => _showPickOptionsDialog(context),
                    // ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff6AC7F0),
                        foregroundColor: Colors.black,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        // Provider를 통해 상태 업데이트
                        Provider.of<WorkoutManager>(context, listen: false).updateWorkoutData(widget.workoutData);
                        if (_imageFile != null) {
                          Provider.of<WorkoutManager>(context, listen: false).updateImageFile(_imageFile!);
                        }
                        Provider.of<WorkoutManager>(context, listen: false).updateWorkoutDuration(widget.workoutDuration);
                        await _saveWorkoutData(); // API 호출 추가
                        await _saveWorkoutData(); // API 호출 추가
                        // 이제 상태가 업데이트 되었으므로 페이지를 닫습니다.
                        Navigator.pop(context);
                      },
                      child: const Text('홈 화면 바로가기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff6AC7F0),
                        foregroundColor: Colors.black,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _sendCompareData,
                      child: const Text('데이터 비교 실행', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 20),
                    if (_compareResult.isNotEmpty)
                      Text(
                        _compareResult,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String formatDuration(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;
    String formattedDuration = '';
    if (hours > 0) {
      formattedDuration += '${hours}H ';
    }
    if (minutes > 0) {
      formattedDuration += '${minutes}M ';
    }
    if (seconds > 0) {
      formattedDuration += '${seconds}S';
    }
    return formattedDuration.trim();
  }
}
