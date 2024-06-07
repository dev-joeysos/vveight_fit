import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_project/components/long_button.dart';
import 'package:provider/provider.dart';
import '../../components/my_button.dart';
import '../../provider/realweghts_list.dart';
import '../camera_screens/camera_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../camera_screens/testing.dart';

class GuidePage extends StatefulWidget {
  final String exerciseId;
  final String exerciseName;
  final double weight;
  final int reps;
  final int restPeriod;
  final List<double> realWeights;
  final Map<String, dynamic>? regressionData;
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
  final PageController _controller = PageController();

  @override
  void initState() {
    super.initState();
    print('Initial realWeights: ${widget.realWeights}');
    print('쉬는 시간: ${widget.restPeriod}');
  }

  String? errorMessage;
  bool isStartExercise = false;

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

      Provider.of<TestWeightsProvider>(context, listen: false).setTestWeights(testWeights, eID);

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
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            widget.exerciseName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xff143365),
            ),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '평소에 이정도 무게로 운동해요',
                      hintText: '숫자(kg)값만 입력해주세요',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Color(0xff143365),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: repsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '평소에 이정도 횟수로 운동해요',
                      hintText: '숫자(reps)값만 입력해주세요',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Color(0xff143365),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 9),
                  Divider(
                    color: Colors.grey[400],
                    thickness: 1.0,
                  ),
                  SizedBox(height: 9),
                  Text(
                    "원판 선택",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff143365),
                    ),
                  ),
                  SizedBox(height: 9),
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
              style: TextButton.styleFrom(
                backgroundColor: Color(0xff143365),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(21),
                ),
              ),
              child: Text(
                '확인',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            TextButton(
              child: Text(
                '취소',
                style: TextStyle(
                  color: Color(0xff143365),
                ),
              ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("촬영 가이드라인",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 150),
                Container(
                  height: 300,
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView(
                          controller: _controller,
                          children: [
                            _buildGuideItem('assets/images/guide_camera.jpeg', '삼각대', '정확한 촬영을 위해 삼각대를 준비해주세요.'),
                            _buildGuideItem('assets/images/guide_pose.png', '바른 자세', '최대한 바른 자세로 운동해주세요.'),
                            _buildGuideItem('assets/images/guide_disc.jpeg', '바벨 제한', '정확한 측정을 위해 주변 운동기구를 정리해주세요.'),
                          ],
                        ),
                      ),
                      SmoothPageIndicator(
                        controller: _controller,
                        count: 3,
                        effect: WormEffect(
                          dotWidth: 10,
                          dotHeight: 10,
                          activeDotColor: Color(0xff2B95C3),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 180),
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (!widget.disableModelCreation)
                      LongButton(
                        onPressed: () {
                          isStartExercise = false;
                          showInputDialog(context);
                        },
                        text: 'LV 모델 생성하기',
                      ),
                    if (widget.disableModelCreation)
                      LongButton(
                        onPressed: () {
                          isStartExercise = true;
                          showInputDialog(context);
                        },
                        text: '운동 시작하기',
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

  Widget _buildGuideItem(String imagePath, String title, String subtitle) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(imagePath, width: 180),
        SizedBox(height: 10),
        Text(
          title,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 6),
        Text(subtitle, style: TextStyle(fontSize: 15),),
      ],
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
      spacing: 9.0,
      children: ['1.25kg', '2.5kg', '5kg', '10kg', '20kg'].map((plate) {
        return FilterChip(
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
          selectedColor: Color(0xff143365),
          checkmarkColor: Colors.white,
          labelStyle: TextStyle(
            fontSize: 15,
            color: selectedPlates.contains(plate) ? Colors.white : Colors.black,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(21),
            side: BorderSide(
              color: selectedPlates.contains(plate) ? Colors.white : Color(0xff143365),
              width: 1,
            ),
          ),
        );
      }).toList(),
    );
  }
}
