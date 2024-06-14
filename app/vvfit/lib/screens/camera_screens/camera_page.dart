import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../result_screens/set_result_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_project/components/flutter_vision.dart';
import 'package:image_picker/image_picker.dart';

class CameraPage extends StatefulWidget {
  final List<CameraDescription> cameras;
  final String exerciseName;
  final String exerciseId;
  final double oneRM;
  final double threeRM;
  final List<double> testWeights;
  final FlutterVision vision;


  const CameraPage({
    Key? key,
    required this.cameras,
    required this.exerciseName,
    required this.exerciseId,
    required this.oneRM,
    required this.threeRM,
    required this.testWeights,
    required this.vision,
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
  late List<Map<String, dynamic>> yoloResults;
  late List<double> speed=[];
  CameraImage? cameraImage;
  bool isLoaded = false;
  bool isDetecting = false;
  Stopwatch stopwatch = new Stopwatch();
  late double slocation=640.0;
  late int stime=0;
  bool isRising=false;
  late double flocation=0.0;
  late int ftime=0;
  late double velocity=0.0;
  late double scalevelocity=0.0;
  late double scalepixel=0.0;
  int cnt=0;
  bool isMeasuring=false;
  double _currentSpeed = 0.0;
  final double _standardSpeed = 0.5; // 기준 속도
  double _stopSpeed = 0.425; // 중단 속도 (기준속도의 85%)
  int _measureCount = 0; // 측정 횟수를 저장하는 변수
  int _sessionIndex = 0; // 현재 측정 세션 인덱스
  List<int> _sessionCounts = [0, 0, 0]; // 각 세션의 측정 횟수를 저장하는 리스트
  //List<double> speedValues = [0.6, 0.5, 0.4];
  List<double> maxSpeeds = [];
  bool isFinding=true;


  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.cameras.first,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize().then((value) {
      loadYoloModel().then((value) {
        setState(() {
          isLoaded = true;
          isDetecting = false;
          yoloResults = [];
        });
      });
    });
    _startTimer();
    print('Test weights: ${widget.testWeights}');
  }
  Future<void> loadYoloModel() async {
    await widget.vision.loadYoloModel(
        labels: 'assets/labels.txt',
        modelPath: 'assets/yolov5n.tflite',
        modelVersion: "yolov5",
        quantization: false,
        numThreads: 2,
        useGpu: true);
    setState(() {
      isLoaded = true;
    });
  }
  Future<void> yoloOnFrame(CameraImage cameraImage) async {
    final result = await widget.vision.yoloOnFrame(
        bytesList: cameraImage.planes.map((plane) => plane.bytes).toList(),
        imageHeight: cameraImage.height,
        imageWidth: cameraImage.width,
        iouThreshold: 0.4,
        confThreshold: 0.7,
        classThreshold: 0.5);
    if (result.isNotEmpty) {
      setState(() {
        yoloResults = result;
      });
    }
  }
  Future<void> startDetection() async {
    setState(() {
      isDetecting = true;
      stopwatch.start();
    });
    if (_controller.value.isStreamingImages) {
      return;
    }
    await _controller.startImageStream((image) async {
      if (isDetecting) {
        cameraImage = image;
        yoloOnFrame(image);
      }
    });
  }
  Future<void> stopDetection() async {
    setState(() {
      isDetecting = false;
      stopwatch.stop();
      yoloResults.clear();
    });
  }
  List<Widget> displayBoxesAroundRecognizedObjects(Size screen) {
    if (yoloResults.isEmpty) return [];
    if(!isMeasuring)return [];
    if(!isFinding)return[];
    double second=0;
    double factorX = screen.width / (cameraImage?.height ?? 1);
    double factorY = screen.height / (cameraImage?.width ?? 1);
    Color colorPick = const Color.fromARGB(255, 50, 233, 30);

    int flag=0;
    int nowtime=0;
    double nowlocation=0;
    int locate=50;
    int locate2=50;



    for(int i=0;i<yoloResults.length;i++)
    {
      if(yoloResults[i]["tag"]=="ll") {
        flag++;
        nowlocation=(yoloResults[i]["box"][3]+yoloResults[i]["box"][1])/2*factorY;
        nowtime=stopwatch.elapsedMilliseconds;
        locate=i;
      }
      if(yoloResults[i]["tag"]=="bbl"&&scalepixel==0.0){
        locate2=i;
        scalepixel=5.0/((yoloResults[i]["box"][3] - yoloResults[i]["box"][1]) * factorY);
      }
    }

    if(flag==1){

      if(isRising)
      {
        if((nowlocation+20.0)<flocation)//rising->rising
            {
          flocation=nowlocation;
          ftime=nowtime;
        }
        else if((nowlocation-20.0)>flocation)  {  //rising->not rising
          velocity=(((slocation-flocation))/((ftime-stime).toDouble()))*1000;
          scalevelocity=velocity*scalepixel*0.01;
          if(scalevelocity>0) speed.add(scalevelocity);
          stime=ftime;
          slocation=flocation;
          ftime=nowtime;
          flocation=nowlocation;
          isRising=false;
        }
        else
        {
          flocation=nowlocation;
          ftime=nowtime;
        }

      }
      else
      {
        if((nowlocation-20.0)>flocation)//not rising->not rising
            {
          flocation=nowlocation;
          ftime=nowtime;
        }
        else if((nowlocation+20.0)<flocation){//not rising -> rising
          stime=ftime;
          slocation=flocation;
          ftime=nowtime;
          flocation=nowlocation;
          isRising=true;
        }
        else
        {
          flocation=nowlocation;
          ftime=nowtime;
        }
      }



    }



    _currentSpeed = scalevelocity;
    _measureCount=speed.isNotEmpty?speed.length :0;
    _sessionCounts[_sessionIndex] = _measureCount;
    _stopSpeed=_measureCount!=0? (speed.reduce((curr, next) => curr > next? curr: next))*0.7:0.0;







    return yoloResults.map((result) {
      return Positioned(
        left: result["box"][0] * factorX,
        top: result["box"][1] * factorY,
        width: (result["box"][2] - result["box"][0]) * factorX,
        height: (result["box"][3] - result["box"][1]) * factorY,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            border: Border.all(color: Colors.pink, width: 2.0),
          ),
          child: Text(
            "${result['tag']} ${(result["box"][4] * 100).toStringAsFixed(0)}% ${speed.length.toString()} ${(stime/1000).toStringAsFixed(0)}  ${scalevelocity.toStringAsFixed(2)}",//${velocity} ${reps}
            style: TextStyle(
              background: Paint()..color = colorPick,
              color: Colors.white,
              fontSize: 18.0,
            ),
          ),
        ),
      );
    }).toList();
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
      isFinding=true;
    } else if (_buttonText == '측정 완료') {
      setState(() {
        _isMeasuring = false;
      });
      isFinding=false;
      int setNumber = (_buttonPressCount ~/ 3) + 1;
      int repNumber = (_buttonPressCount % 3) + 1;
      double currentWeight = widget.testWeights[setNumber - 1];
      double currentSpeed =
      speed.isNotEmpty? ((speed.reduce((value, element) => value + element))/speed.length):0.0;
      speed.clear();
      stime=0;
      ftime=0;
      scalevelocity=0;
      _showSetResultPage(
          context, repNumber, _secondsPassed, currentWeight, currentSpeed);
    } else if (_buttonText == '결과 보기') {
      stopDetection();
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
    final Size size = MediaQuery.of(context).size;
    if (!isLoaded) {
      return const Scaffold(
        body: Center(
          child: Text("Model not loaded, waiting for it"),
        ),
      );
    }
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
                  ...displayBoxesAroundRecognizedObjects(size),
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
                          //SizedBox(height:3),
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
                              "Set ${((_buttonPressCount % 3) + 1)} 평균 속도: ${speed.isNotEmpty? (((speed.reduce((value, element) => value + element))/speed.length).toStringAsFixed(2)):"0.0"} m/s",
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
                            onPressed: ()async{
                              isMeasuring=true;
                              await startDetection();
                              _onButtonPressed();
                            },
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
