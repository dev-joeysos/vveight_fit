import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/workout_data.dart';
import 'package:image_picker/image_picker.dart';

import '../../provider/workout_manager.dart';

class ReviewPage extends StatefulWidget {
  final int workoutDuration;  // 운동 시간을 초 단위로 받습니다.
  final WorkoutData workoutData;  // 운동 데이터 추가

  ReviewPage({Key? key, required this.workoutDuration, required this.workoutData}) : super(key: key);

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

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

  @override
  Widget build(BuildContext context) {
    List<Widget> exerciseDetailsWidgets = widget.workoutData.exerciseDetails.entries.map((entry) {
      return ListTile(
        title: Text(entry.key),
        subtitle: Text(
            'Sessions: ${entry.value.sessionCounts.join(", ")}, '
                'Weights: ${entry.value.weights.map((w) => w.toStringAsFixed(1)).join(", ")} kg'
        ),
      );
    }).toList();

    String formattedDuration = formatDuration(widget.workoutDuration);

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
                    const SizedBox(height: 220),
                    const Text(
                      '수고하셨습니다!', // Main greeting text
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
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
                                  padding: EdgeInsets.all(6),  // Icon padding
                                  decoration: BoxDecoration(
                                    color: Color(0xff6AC7F0),  // Container background color
                                    borderRadius: BorderRadius.circular(12),  // Container corner radius
                                  ),
                                  child: Icon(Icons.timer, color: Colors.white),  // Icon
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  formattedDuration,
                                  style: TextStyle(color: Color(0xff003376), fontWeight: FontWeight.bold, fontSize: 30),
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
                                child: _imageFile != null ? Image.file(File(_imageFile!.path), width: 60, height: 60, fit: BoxFit.cover) :
                                Icon(
                                  Icons.camera_alt, // 카메라 아이콘
                                  size: 40,
                                  color: Color(0xff003376), // 아이콘 색상
                                ),
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      maxLines: null,  // 여러 줄 입력 허용
                      onChanged: (value) {
                        // 텍스트 필드 값이 변경될 때마다 Provider를 통해 업데이트
                        Provider.of<WorkoutManager>(context, listen: false).updateReview(value);
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,  // 배경색을 흰색으로 설정
                        hintText: '운동 후기 작성하기',  // 힌트 텍스트
                        contentPadding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),  // 내부 패딩 추가
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),  // 경계선 둥글게 처리
                          borderSide: BorderSide.none,  // 경계선 없음
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // ...exerciseDetailsWidgets,
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff6AC7F0),
                        foregroundColor: Colors.black,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        // Provider를 통해 상태 업데이트
                        Provider.of<WorkoutManager>(context, listen: false).updateWorkoutData(widget.workoutData);
                        if (_imageFile != null) {
                          Provider.of<WorkoutManager>(context, listen: false).updateImageFile(_imageFile!);
                        }
                        Provider.of<WorkoutManager>(context, listen: false).updateWorkoutDuration(widget.workoutDuration);

                        // 이제 상태가 업데이트 되었으므로 페이지를 닫습니다.
                        Navigator.pop(context);
                      },
                      child: const Text('홈 화면 바로가기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
