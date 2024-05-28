import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';

import '../../provider/workout_data.dart';

class WorkCamPage extends StatefulWidget {
  final List<double> weights;
  final int reps;
  final String exerciseName;

  const WorkCamPage({Key? key, required this.weights, required this.reps, required this.exerciseName})
      : super(key: key);

  @override
  _WorkCamPageState createState() => _WorkCamPageState();
}

class _WorkCamPageState extends State<WorkCamPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  double _currentSpeed = 0.0;
  final double _standardSpeed = 0.5; // 기준 속도
  final double _stopSpeed = 0.425; // 중단 속도 (기준속도의 85%)
  int _measureCount = 0; // 측정 횟수를 저장하는 변수
  int _sessionIndex = 0; // 현재 측정 세션 인덱스
  List<int> _sessionCounts = [0, 0, 0]; // 각 세션의 측정 횟수를 저장하는 리스트
  bool _isFrontCamera = false; // 전면 카메라 여부

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.firstWhere((camera) => camera.lensDirection == (_isFrontCamera ? CameraLensDirection.front : CameraLensDirection.back), orElse: () => cameras.first);
    _controller = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    if (_controller.value.isInitialized) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _toggleCamera() {
    setState(() {
      _isFrontCamera = !_isFrontCamera;
      _initializeController();
    });
  }

  void _measureSpeed() {
    if (_sessionIndex == 3) return; // 세션 인덱스가 3일 때 함수 종료

    setState(() {
      _currentSpeed = Random().nextDouble() * 1.6;
      _measureCount++;
      _sessionCounts[_sessionIndex] = _measureCount;

      if (_measureCount >= widget.reps) {
        _measureCount = 0;
        _sessionIndex++;
      }

      if (_currentSpeed <= _stopSpeed) {
        _measureCount = 0;
        _sessionIndex++;
        _showStopDialog(); // 중단 다이얼로그 표시
      }
    });
  }

  void _showStopDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("운동 중단 알림"),
          content: Text("속도가 $_stopSpeed m/s 이하로 떨어졌습니다. 운동을 중단하세요."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("확인"),
            ),
          ],
        );
      },
    );
  }

  void _completeAndReturn() {
    Navigator.of(context).pop({
      'exerciseName': widget.exerciseName,
      'sessionCounts': _sessionCounts,
      'weights': widget.weights,
    });
  }

  void completeMeasurement() {
    // 사용자 측정 데이터
    String exerciseName =  widget.exerciseName;
    List<int> sessionCounts = _sessionCounts;  // 예시 데이터
    List<double> weights = widget.weights;  // 예시 데이터

    // 데이터 업데이트
    Provider.of<WorkoutData>(context, listen: false).updateData(exerciseName, sessionCounts, weights);

    // RoutinePage로 돌아가기
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Workout Camera"),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                Positioned.fill(
                  child: CameraPreview(_controller),
                ),
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.black45,
                    padding: EdgeInsets.all(8),
                    child: Column(
                      children: [
                        for (int i = 0; i < _sessionCounts.length; i++)
                          Text('[${i + 1}회차 ${widget.weights[i].toStringAsFixed(0)}kg] 측정 횟수: ${_sessionCounts[i]} / ${widget.reps} reps', style: TextStyle(fontSize: 16, color: Colors.white)),
                        SizedBox(height: 4),
                        Text("현재 속도: ${_currentSpeed.toStringAsFixed(2)} m/s",  style: TextStyle(fontSize: 16, color: Colors.blue)),
                        Text('측정 횟수: $_measureCount 회', style: TextStyle(fontSize: 20, color: Colors.white)),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _sessionIndex < 3  ? _measureSpeed : completeMeasurement,
                          child: Text(_sessionIndex < 3 ? "측정" : "완료"),
                        ),
                      ],
                    ),

                  ),
                ),
                Positioned(
                  top: 20,
                  right: 20,
                  child: IconButton(
                    icon: Icon(Icons.flip_camera_ios),
                    onPressed: _toggleCamera,
                    color: Colors.white,
                  ),
                ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
