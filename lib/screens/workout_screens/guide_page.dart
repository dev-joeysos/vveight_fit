import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/trashs/workCam_page.dart';
import 'package:provider/provider.dart';
import '../../provider/realweghts_list.dart';
import '../camera_screens/camera_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_project/trashs/recommend_page.dart';
import 'package:flutter_project/screens/workout_screens/routine_page.dart';
import '../camera_screens/testing.dart';
import '../main_screens/my_page.dart';

class GuidePage extends StatefulWidget {
  final String exerciseId;
  final String exerciseName;
  final double weight;
  final int reps;
  final int restPeriod;
  final List<double> realWeights; // 진짜 운동용 무게 받기 _ 불러온 루틴 데이터의 최신 운동수행 무게
  final Map<String, dynamic>? regressionData; // 회귀 데이터 받기
  final bool disableModelCreation;

  const GuidePage({
    Key? key,
    required this.exerciseId,
    required this.exerciseName,
    required this.weight,
    required this.reps,
    required this.restPeriod,
    required this.realWeights,
    this.regressionData,
    required this.disableModelCreation,
  }) : super(key: key);

  @override
  _GuidePageState createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {
  @override
  void initState() {
    super.initState();
    print('Initial realWeights: ${widget.realWeights}');
    print('쉬는 시간: ${widget.restPeriod}');
  }

  String? errorMessage; // For displaying error messages
  bool isStartExercise = false; // 운동 시작 버튼을 클릭했는지 확인하는 플래그

  // Function to show the custom input dialog
  Future<void> showInputDialog(BuildContext context) async {
    TextEditingController weightController = TextEditingController();
    TextEditingController repsController = TextEditingController();
    List<String> selectedPlates = [];

    void validateInput() async {
      String weight = weightController.text;
      String reps = repsController.text;

      if (weight.isEmpty || reps.isEmpty || selectedPlates.isEmpty) {
        setState(() {
          errorMessage = "모든 값을 입력해주세요.";
        });
        return;
      }
      if (double.tryParse(weight) == null || int.tryParse(reps) == null) {
        setState(() {
          errorMessage = "숫자값을 입력해주세요.";
        });
        return;
      }

      double weightValue = double.parse(weight);
      int repsValue = int.parse(reps);

      Map<String, dynamic> requestBody = {
        'exercise_id': widget.exerciseId,
        'weight': weightValue,
        'reps': repsValue,
        'units': selectedPlates.map((plate) => double.parse(plate.replaceAll('kg', ''))).toList(),
      };

      double oneRM = 0.0;
      double threeRM = 0.0;
      List<double> testWeights = [];
      String eID = '';
      try {
        var response = await http.post(
          Uri.parse('http://52.79.236.191:3000/api/vbt_core/base_weights'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(requestBody),
        );

        if (response.statusCode == 200) {
          var responseData = json.decode(response.body);
          print('API Response: $responseData');
          oneRM = responseData['one_rep_max'].toDouble();
          threeRM = responseData['three_rep_max'].toDouble();
          eID = responseData['exercise_id'];
          testWeights = List<double>.from(responseData['test_weights'].map((weight) => weight.toDouble()));
        } else {
          print('Failed to load data: ${response.statusCode}');
        }
      } catch (e) {
        print('Error: $e');
      }

      setState(() {
        errorMessage = null;
      });

      // 실제 운동할 때 수행한 무게가 루틴 페이지로 반영되어야 합니다.
      Provider.of<TestWeightsProvider>(context, listen: false).setTestWeights(testWeights, eID);

      Navigator.of(context).pop();
      showResultsDialog(context, oneRM, threeRM, testWeights);
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('${widget.exerciseName}'),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '평균 수행 중량 입력:',
                      hintText: 'kg',
                    ),
                  ),
                  TextField(
                    controller: repsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '평균 수행 횟수 입력:',
                      hintText: '횟수',
                    ),
                  ),
                  SizedBox(height: 20),
                  Text("원판 종류를 모두 선택해주세요", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xff585858))),
                  SizedBox(height: 10),
                  PlateSelection(
                    selectedPlates: selectedPlates,
                    onSelectionChanged: (List<String> plates) {
                      setState(() {
                        selectedPlates = plates;
                      });
                    },
                  ),
                  if (errorMessage != null)
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        errorMessage!,
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: validateInput,
              child: Text('확인'),
            ),
            TextButton(
              child: Text('취소'),
              onPressed: () {
                setState(() {
                  errorMessage = null;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Function to display 1RM and 3RM results and navigate to CameraPage
  void showResultsDialog(BuildContext context, double oneRM, double threeRM, List<double> testWeights) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('계산 결과'),
          content: Text('1RM: ${oneRM.toStringAsFixed(0)} kg\n3RM: ${threeRM.toStringAsFixed(0)} kg\n'),
          actions: <Widget>[
            TextButton(
              child: Text('모델 생성'),
              onPressed: () async {
                Navigator.of(context).pop();
                // Update the Provider with the fetched testWeights and exerciseId
                Provider.of<TestWeightsProvider>(context, listen: false).setTestWeights(testWeights, widget.exerciseId);

                final cameras = await availableCameras();
                if (isStartExercise) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Testing(
                        cameras: cameras,
                        exerciseName: widget.exerciseName,
                        exerciseId: widget.exerciseId,
                        oneRM: oneRM,
                        threeRM: threeRM,
                        realWeights: testWeights,
                        rData: widget.regressionData,
                        restPeriod: widget.restPeriod,
                      ),
                    ),
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CameraPage(
                        cameras: cameras,
                        exerciseName: widget.exerciseName,
                        exerciseId: widget.exerciseId,
                        oneRM: oneRM,
                        threeRM: threeRM,
                        testWeights: testWeights,
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("VBT 가이드라인",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 25),
                Image.asset('assets/images/tripod.png', width: 100),
                SizedBox(height: 5),
                Text("삼각대",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text("정확한 촬영을 위해 삼각대를 준비해주세요."),
                SizedBox(height: 20),
                Image.asset('assets/images/pose.png', width: 100),
                SizedBox(height: 5),
                Text("바른 자세",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text("최대한 바른 자세로 운동해주세요."),
                SizedBox(height: 20),
                Image.asset('assets/images/pose.png', width: 100),
                SizedBox(height: 5),
                Text("바벨 제한",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text("정확한 속도 측정을 위해 주변 바벨을 최대한 치워주세요."),
                SizedBox(height: 20),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20.0),
                  padding: EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.blueAccent),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Text(
                    "[모델 생성] 새로운 LV 모델을 생성합니다.\n[운동시작] 기존의 LV 모델로 운동을 시작합니다.",
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (!widget.disableModelCreation)
                      ElevatedButton(
                        onPressed: () {
                          isStartExercise = false; // 모델 생성 플래그 설정
                          showInputDialog(context);
                        },
                        child: Text('모델 생성1'),
                      ),
                    if (widget.disableModelCreation)
                      ElevatedButton(
                        onPressed: () {
                          isStartExercise = true; // 운동 시작 플래그 설정
                          showInputDialog(context);
                        },
                        child: Text('운동 시작'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PlateSelection extends StatefulWidget {
  final List<String> selectedPlates;
  final ValueChanged<List<String>> onSelectionChanged;

  const PlateSelection(
      {required this.selectedPlates, required this.onSelectionChanged});

  @override
  _PlateSelectionState createState() => _PlateSelectionState();
}

class _PlateSelectionState extends State<PlateSelection> {
  List<String> selectedPlates = [];

  @override
  void initState() {
    super.initState();
    selectedPlates = widget.selectedPlates;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10.0,
      children: ['1.25kg', '2.5kg', '5kg', '10kg', '20kg'].map((plate) {
        return ChoiceChip(
          label: Text(plate),
          selected: selectedPlates.contains(plate),
          onSelected: (selected) {
            setState(() {
              if (selected) {
                selectedPlates.add(plate);
              } else {
                selectedPlates.remove(plate);
              }
              widget.onSelectionChanged(selectedPlates);
            });
          },
          selectedColor: Colors.blue,
          // Change to blue when selected
          labelStyle: TextStyle(
            color: selectedPlates.contains(plate) ? Colors.white : Colors.black,
          ),
        );
      }).toList(),
    );
  }
}
