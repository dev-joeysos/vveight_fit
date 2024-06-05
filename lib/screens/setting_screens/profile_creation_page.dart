import 'package:flutter/material.dart';
import 'package:flutter_project/trashs/recommend_page.dart';
import '../camera_screens/camera_page.dart';
import 'package:camera/camera.dart';

import '../../trashs/apit_test_page.dart';

class ProfileCreationPage extends StatefulWidget {
  @override
  _ProfileCreationPageState createState() => _ProfileCreationPageState();
}

class _ProfileCreationPageState extends State<ProfileCreationPage> {
  String? errorMessage; // 에러 메시지를 표시하기 위한 변수
  bool isStartExercise = false; // 운동 시작 버튼 클릭 여부 확인을 위한 플래그

  // 커스텀 입력 다이얼로그를 표시하는 함수
  Future<void> showInputDialog(BuildContext context) async {
    TextEditingController weightController = TextEditingController();
    TextEditingController repsController = TextEditingController();

    void validateInput() {
      String weight = weightController.text;
      String reps = repsController.text;

      // 모든 필드가 입력되었는지 확인
      if (weight.isEmpty || reps.isEmpty) {
        setState(() {
          errorMessage = "모든 값을 입력해주세요.";
        });
        return;
      }
      // 입력된 값이 숫자인지 확인
      if (double.tryParse(weight) == null || int.tryParse(reps) == null) {
        setState(() {
          errorMessage = "숫자값을 입력해주세요.";
        });
        return;
      }

      double weightValue = double.parse(weight);
      int repsValue = int.parse(reps);
      // 1RM과 3RM 계산
      double oneRM = weightValue * (1 + repsValue / 30.0);
      double threeRM = oneRM * 0.93;

      setState(() {
        errorMessage = null; // 이전 에러 메시지 제거
      });
      Navigator.of(context).pop(); // 다이얼로그 닫기
      showResultsDialog(context, oneRM, threeRM); // 결과를 새로운 다이얼로그로 표시
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // 사용자 작업 시 다이얼로그 닫히지 않음
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('프로필 생성'),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.9, // 다이얼로그 넓이 조정
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number, // 숫자 키보드만 사용
                    decoration: InputDecoration(
                      labelText: '평균 수행 중량 입력:',
                      hintText: 'kg', // 힌트 텍스트
                    ),
                  ),
                  TextField(
                    controller: repsController,
                    keyboardType: TextInputType.number, // 숫자 키보드만 사용
                    decoration: InputDecoration(
                      labelText: '평균 수행 횟수 입력:',
                      hintText: '횟수', // 힌트 텍스트
                    ),
                  ),
                  if (errorMessage != null) // 에러 메시지가 있는 경우 표시
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
              child: Text('확인'),
              onPressed: validateInput, // 입력 확인 함수 호출
            ),
            TextButton(
              child: Text('취소'),
              onPressed: () {
                setState(() {
                  errorMessage = null;
                });
                Navigator.of(context).pop(); // 데이터를 저장하지 않고 다이얼로그 닫기
              },
            ),
          ],
        );
      },
    );
  }

  // 1RM과 3RM 결과를 표시하고 CameraPage로 이동하는 함수
  void showResultsDialog(BuildContext context, double oneRM, double threeRM) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('계산 결과'),
          content: Text(
              '1RM: ${oneRM.toStringAsFixed(0)} kg\n3RM: ${threeRM.toStringAsFixed(0)} kg'),
          actions: <Widget>[
            TextButton(
              child: Text('운동 시작'),
              onPressed: () async {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                if (isStartExercise) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecommendPage(
                        oneRM: oneRM,
                        exerciseName: "exerciseName",
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
                        exerciseName: "exerciseName",
                        oneRM: oneRM,
                        threeRM: threeRM, testWeights: [], exerciseId: '00001',
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
        title: Text("프로필 생성", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 25),
                Image.asset('assets/images/tripod.png', width: 100),
                SizedBox(height: 5),
                Text("삼각대", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text("정확한 촬영을 위해 삼각대를 준비해주세요."),
                SizedBox(height: 20),
                Image.asset('assets/images/pose.png', width: 100),
                SizedBox(height: 5),
                Text("바른 자세", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text("최대한 바른 자세로 운동해주세요."),
                SizedBox(height: 20),
                Image.asset('assets/images/pose.png', width: 100),
                SizedBox(height: 5),
                Text("바벨 제한", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                ElevatedButton(
                  onPressed: () {
                    isStartExercise = false; // 모델 생성 플래그 설정
                    showInputDialog(context);
                  },
                  child: Text('모델 생성'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // API 테스트 용도의 페이지로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => APITestPage(),
                      ),
                    );
                  },
                  child: Text('API 테스트 페이지로 이동'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


