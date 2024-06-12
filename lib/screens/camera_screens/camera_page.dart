import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../result_screens/set_result_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CameraPage extends StatefulWidget {
  final List<CameraDescription> cameras;
  final String exerciseName;
  final String exerciseId;
  final double oneRM;
  final double threeRM;
  final List<double> testWeights;

  const CameraPage({
    Key? key,
    required this.cameras,
    required this.exerciseName,
    required this.exerciseId,
    required this.oneRM,
    required this.threeRM,
    required this.testWeights,
  }) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  Timer? _timer;
  int _secondsPassed = 0;
  bool _isMeasuring = false;
  String _buttonText = '측정 시작';
  int _buttonPressCount = 0;
  bool _isComplete = false;
  bool _isFrontCamera = false;
  List<double> speedValues = [0.3, 0.21, 0.19];

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
    print('Test weights: ${widget.testWeights}');
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

  void _showSetResultPage(BuildContext context, int setNumber, int setTime,
      double weight, double maxSpeed) {
    maxSpeeds.add(maxSpeed);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SetResultPage(
          setNumber: setNumber,
          exerciseName: widget.exerciseName,
          setTime: setTime,
          testWeights: widget.testWeights,
          speedValues: maxSpeeds,
          rSquared: 0.0,
          slope: 0.0,
          yIntercept: 0.0,
          exerciseId: widget.exerciseId,
          oneRM: widget.oneRM,
        ),
      ),
    ).then((_) {
      setState(() {
        _buttonPressCount++;
        if (_buttonPressCount >= widget.testWeights.length) {
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
      double currentWeight = widget.testWeights[setNumber - 1];
      double currentSpeed =
      speedValues[(_buttonPressCount % 3) % speedValues.length];
      _showSetResultPage(
          context, repNumber, _secondsPassed, currentWeight, currentSpeed);
    } else if (_buttonText == '결과 보기') {
      var regressionData = await postRegressionData();
      if (regressionData != null) {
        double oneRepMax = double.parse(regressionData['one_rep_max'].toString());

        print('수정된 oneRM: $oneRepMax');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SetResultPage(
              setNumber: 1,
              exerciseName: widget.exerciseName,
              setTime: _secondsPassed,
              testWeights: widget.testWeights,
              speedValues: maxSpeeds,
              rSquared: double.parse(regressionData['r_squared'].toString()),
              slope: double.parse(regressionData['slope'].toString()),
              yIntercept:
              double.parse(regressionData['y_intercept'].toString()),
              exerciseId: widget.exerciseId,
              oneRM: oneRepMax,
            ),
          ),
        );
      }
    }
  }

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
            widget.testWeights.length,
                (index) => {
              'weight': widget.testWeights[index],
              'max_velocity': maxSpeeds[index],
            })
      }),
    );

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      print('모델 생성 회귀데이터: $responseData');
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

    return Scaffold(
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
                      color: Colors.black.withOpacity(0.3),
                      padding: EdgeInsets.all(8),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.exerciseName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // SizedBox(height:3),
                          if (!_isComplete)
                            Text(
                              '수행 무게 = ${widget.testWeights[(_buttonPressCount % 3)].toStringAsFixed(0)} kg',
                              style: TextStyle(
                                color: Color(0xff6BBEE2),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          if (_isMeasuring)
                            Text(
                              "Set ${((_buttonPressCount % 3) + 1)} 평균 속도: ${speedValues[(_buttonPressCount % 3) % speedValues.length].toStringAsFixed(2)} m/s",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          if (_isComplete)
                            Text(
                              "측정이 완료되었습니다!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 21,
                                color: Color(0xff18FF2F),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _onButtonPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xff3DB1D3),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 120, vertical: 12),
                              shadowColor: Colors.grey.withOpacity(0.5), // 그림자 색상
                              elevation: 10,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(90),
                              ),
                            ),
                            child: Text(
                              _buttonText,
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold ,color: Colors.white),
                            ),
                          ),
                          SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 774,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Text(
                        '수행 시간: $minutes분 ${seconds}초',
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      color: Colors.white,
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
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
