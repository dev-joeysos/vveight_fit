import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/screens/workout_screens/recommend_page.dart';
import '../camera_screens/camera_page.dart';
import '../main_screens/my_page.dart';
import 'package:http/http.dart' as http; // HTTP 패키지 추가
import 'dart:convert'; // JSON 인코딩 및 디코딩을 위한 패키지 추가

class GuidePage extends StatefulWidget {
  final String exerciseId;
  final String exerciseName;

  const GuidePage({Key? key, required this.exerciseId, required this.exerciseName}) : super(key: key);

  @override
  _GuidePageState createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {
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

      // Check if both fields are filled
      if (weight.isEmpty || reps.isEmpty || selectedPlates.isEmpty) {
        setState(() {
          errorMessage = "모든 값을 입력해주세요.";
        });
        return;
      }
      // Check if both inputs are numeric
      if (double.tryParse(weight) == null || int.tryParse(reps) == null) {
        setState(() {
          errorMessage = "숫자값을 입력해주세요.";
        });
        return;
      }

      double weightValue = double.parse(weight);
      int repsValue = int.parse(reps);

      // API 호출을 위한 데이터 준비
      Map<String, dynamic> requestBody = {
        'exercise_id': widget.exerciseName,
        'weight': weightValue,
        'reps': repsValue,
        'units': selectedPlates.map((plate) => double.parse(plate.replaceAll('kg', ''))).toList(),
      };

      double oneRM = 0.0;
      double threeRM = 0.0;
      List<int> testWeights = [];

      try {
        // API 호출
        var response = await http.post(
          Uri.parse('http://52.79.236.191:3000/api/vbt_core/base_weights'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(requestBody),
        );

        if (response.statusCode == 200) {
          // 성공적으로 응답을 받았을 경우
          var responseData = json.decode(response.body);
          print('API Response: $responseData');

          // API 응답에서 1RM 및 3RM 값을 가져옴
          oneRM = responseData['one_rep_max'].toDouble();
          threeRM = responseData['three_rep_max'].toDouble();
          testWeights = List<int>.from(responseData['test_weights']);
        } else {
          // 에러 발생 시
          print('Failed to load data: ${response.statusCode}');
        }
      } catch (e) {
        // 예외 발생 시
        print('Error: $e');
      }

      setState(() {
        errorMessage = null; // Clear any previous error messages
      });
      Navigator.of(context).pop(); // Close the dialog
      showResultsDialog(
          context, oneRM, threeRM, testWeights); // Show results in a new dialog
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      // The user must tap a button to dismiss the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('${widget.exerciseName}'),
          content: Container(
            width: MediaQuery.of(context).size.width *
                0.9, // Makes the dialog wider
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number, // Only numeric keyboard
                    decoration: InputDecoration(
                      labelText: '평균 수행 중량 입력:',
                      hintText: 'kg', // Hint text
                    ),
                  ),
                  TextField(
                    controller: repsController,
                    keyboardType: TextInputType.number, // Only numeric keyboard
                    decoration: InputDecoration(
                      labelText: '평균 수행 횟수 입력:',
                      hintText: '횟수', // Hint text
                    ),
                  ),
                  SizedBox(height: 20),
                  Text("원판 종류를 모두 선택해주세요",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xff585858))),
                  SizedBox(height: 10),
                  PlateSelection(
                    selectedPlates: selectedPlates,
                    onSelectionChanged: (List<String> plates) {
                      setState(() {
                        selectedPlates = plates;
                      });
                    },
                  ),
                  if (errorMessage !=
                      null) // Error message if there is an error
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
              onPressed:
              validateInput,
              child: Text('확인'), // Check inputs when this button is pressed
            ),
            TextButton(
              child: Text('취소'),
              onPressed: () {
                setState(() {
                  errorMessage = null;
                });
                Navigator.of(context)
                    .pop(); // Close the dialog without saving data
              },
            ),
          ],
        );
      },
    );
  }

  // Function to display 1RM and 3RM results and navigate to CameraPage
  void showResultsDialog(BuildContext context, double oneRM, double threeRM, List<int> testWeights) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('계산 결과'),
          content: Text(
              '1RM: ${oneRM.toStringAsFixed(0)} kg\n3RM: ${threeRM.toStringAsFixed(0)} kg'),
          actions: <Widget>[
            TextButton(
              child: Text('모델 생성'),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                if (isStartExercise) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecommendPage(
                        oneRM: oneRM,
                        exerciseName: widget.exerciseName,
                      ),
                    ),
                  );
                } else {
                  final cameras = await availableCameras();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CameraPage(
                          cameras: cameras,
                          exerciseName: widget.exerciseName,
                          exerciseId: widget.exerciseId,
                          oneRM: oneRM,
                          threeRM: threeRM,
                          testWeights: testWeights), // Pass testWeights here
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
                    ElevatedButton(
                      onPressed: () {
                        isStartExercise = false; // 모델 생성 플래그 설정
                        showInputDialog(context);
                      },
                      child: Text('모델 생성'),
                    ),
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
