import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_project/trashs/recommend_page.dart';
import 'package:provider/provider.dart';
import '../../provider/target_velocity.dart';
import '../result_screens/set_result_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../result_screens/testing_result.dart';

class Testing extends StatefulWidget {
  final List<CameraDescription> cameras;
  final String exerciseName;
  final String exerciseId;
  final double oneRM;
  final double threeRM;
  final List<double> realWeights;
  final Map<String, dynamic>? rData; // 회귀 데이터 받기

  const Testing({
    Key? key,
    required this.cameras,
    required this.exerciseName,
    required this.exerciseId,
    required this.oneRM,
    required this.threeRM,
    required this.realWeights,
    this.rData,
  }) : super(key: key);

  @override
  _TestingState createState() => _TestingState();
}

class _TestingState extends State<Testing> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  Timer? _timer;
  int _secondsPassed = 0;
  bool _isMeasuring = false;
  String _buttonText = '측정 시작';
  int _buttonPressCount = 0;
  bool _isComplete = false;
  bool _isFrontCamera = false;
  List<double> speedValues = [0.9, 0.7, 0.4]; // mean velocity
  // Todo: 무게 별 속도 중단지점 알려주기 => Target velocity..

  List<double> maxSpeeds = [];

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.cameras.first,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
    _startTimer();
    print('Test weights: ${widget.realWeights}');
    print('Received rData in Testing: ${widget.rData}');
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_isMeasuring) {
          _secondsPassed++;
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _toggleCamera() {
    setState(() {
      _isFrontCamera = !_isFrontCamera;
      _controller = CameraController(
        widget.cameras.firstWhere((camera) =>
        camera.lensDirection ==
            (_isFrontCamera
                ? CameraLensDirection.front
                : CameraLensDirection.back)),
        ResolutionPreset.medium,
      );
      _initializeControllerFuture = _controller.initialize();
    });
  }

  void _showTestingResultPage(BuildContext context, int setNumber, int setTime,
      double weight, double maxSpeed) {
    maxSpeeds.add(maxSpeed);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestingResult(
          setNumber: setNumber,
          exerciseName: widget.exerciseName,
          setTime: setTime,
          realWeights: widget.realWeights,
          speedValues: maxSpeeds,
          rSquared: double.parse(widget.rData?['r_squared'].toString() ?? '0.0'),
          slope: double.parse(widget.rData?['slope'].toString() ?? '0.0'),
          yIntercept: double.parse(widget.rData?['y_intercept'].toString() ?? '0.0'),
          exerciseId: widget.exerciseId,
          oneRM: widget.oneRM,
        ),
      ),
    ).then((_) {
      setState(() {
        _buttonPressCount++;
        if (_buttonPressCount >= widget.realWeights.length) {
          _isComplete = true;
          _buttonText = '결과 보기';
        } else {
          _buttonText = '측정 시작';
          _secondsPassed = 0;
        }
      });
    });
  }

  void _onButtonPressed() async {
    if (_buttonText == '측정 시작') {
      setState(() {
        _isMeasuring = true;
        _buttonText = '측정 완료';
      });
    } else if (_buttonText == '측정 완료') {
      setState(() {
        _isMeasuring = false;
      });
      int setNumber = (_buttonPressCount ~/ 3) + 1;
      int repNumber = (_buttonPressCount % 3) + 1;
      double currentWeight = widget.realWeights[setNumber - 1];
      double currentSpeed =
      speedValues[(_buttonPressCount % 3) % speedValues.length];
      _showTestingResultPage(
          context, repNumber, _secondsPassed, currentWeight, currentSpeed);
    } else if (_buttonText == '결과 보기') {
      // Call the API and handle the response
      var regressionData = await postRegressionData();
      if (regressionData != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TestingResult(
              setNumber: 1,
              exerciseName: widget.exerciseName,
              setTime: _secondsPassed,
              realWeights: widget.realWeights,
              speedValues: maxSpeeds,
              rSquared: double.parse(widget.rData?['r_squared'].toString() ?? '0.0'),
              slope: double.parse(widget.rData?['slope'].toString() ?? '0.0'),
              yIntercept: double.parse(widget.rData?['y_intercept'].toString() ?? '0.0'),
              exerciseId: widget.exerciseId, oneRM: widget.oneRM,
              rData: regressionData,
            ),
          ),
        );
      }
    }
  }

// Function to perform API call and return data
  Future<Map<String, dynamic>?> postRegressionData() async {
    var url = Uri.parse('http://52.79.236.191:3000/api/vbt_core/regression');
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'exercise_id': widget.exerciseId,
        'name': widget.exerciseName,
        'type': 'Test',
        'data': List.generate(
            widget.realWeights.length,
                (index) => {
              'weight': widget.realWeights[index],
              'max_velocity': maxSpeeds[index],
            })
      }),
    );

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      print('Regression Data: $responseData');
      return responseData['regression'];
    } else {
      print('Failed to load regression data');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    int minutes = _secondsPassed ~/ 60;
    int seconds = _secondsPassed % 60;
    double targetVelocity = Provider.of<TargetVelo>(context).targetVelocity;
    return Scaffold(
      appBar: AppBar(title: Text("testing")),
      body: SafeArea(
        child: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Stack(
                alignment: Alignment.center,
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
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(widget.exerciseName,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(height: 20),
                          Text(
                              '수행 무게: ${widget.realWeights[(_buttonPressCount % 3)]} kg',
                              style:
                              TextStyle(color: Colors.white, fontSize: 20)),
                          if (_isMeasuring)
                            Text(
                                "${((_buttonPressCount % 3) + 1)}세트 측정 중입니다.\n평균 속도: ${speedValues[(_buttonPressCount % 3) % speedValues.length].toStringAsFixed(2)} m/s\n중단 속도: ${targetVelocity.toStringAsFixed(2)} m/s",
                                textAlign: TextAlign.center,
                                style:
                                TextStyle(fontSize: 20, color: Colors.blue)),
                          if (_isComplete)
                            Text("측정이 완료되었습니다!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 20, color: Colors.green)),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _onButtonPressed,
                            child: Text(_buttonText),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 300,
                    child: Container(
                      padding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('${minutes}분 ${seconds}초',
                          style: TextStyle(color: Colors.white, fontSize: 20)),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
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
      ),
    );
  }
}
