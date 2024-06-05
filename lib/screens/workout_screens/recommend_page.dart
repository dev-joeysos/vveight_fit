import 'package:flutter/material.dart';
import 'package:flutter_project/screens/camera_screens/workCam_page.dart';

class RecommendPage extends StatefulWidget {
  final double oneRM;
  final String exerciseName;
  final Map<String, dynamic>? regressionData; // 회귀 데이터 받기

  const RecommendPage({
    Key? key,
    required this.oneRM,
    required this.exerciseName,
    this.regressionData,
  }) : super(key: key);

  @override
  _RecommendPageState createState() => _RecommendPageState();
}

class _RecommendPageState extends State<RecommendPage> {
  int? _selectedRoutine = 0; // Default to the first routine
  @override
  void initState() {
    super.initState();
    if (widget.regressionData != null) {
      print('Received regressionData: ${widget.regressionData}');
    } else {
      print('No regressionData received');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("루틴 추천"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.exerciseName,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView(
                scrollDirection: Axis.vertical,
                children: <Widget>[
                  _buildOptionCard("크로스핏형 루틴", [0.40, 0.45, 0.50], 20,
                      "근파워와 유산소를 병행할 수 있는 구간", 0),
                  _buildOptionCard(
                      "근비대 루틴", [0.60, 0.65, 0.70], 10, "근비대, 근파워 병행 구간", 1),
                  _buildOptionCard(
                      "근파워 루틴", [0.70, 0.75, 0.80], 5, "근파워를 위한 훈련 구간", 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(String title, List<double> percentages, int reps,
      String description, int cardIndex) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            subtitle: Text(description, style: TextStyle(fontSize: 15)),
            trailing: Radio<int>(
              value: cardIndex,
              groupValue: _selectedRoutine,
              onChanged: (int? value) {
                setState(() {
                  _selectedRoutine = value;
                });
              },
            ),
          ),
          Divider(),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var percentage in percentages)
                  Text(
                      '${(percentage * 100).toInt()}% of 1RM: ${(widget.oneRM * percentage).toStringAsFixed(0)} kg, $reps회',
                      style: TextStyle(fontSize: 15)),
                SizedBox(height: 20),
                if (_selectedRoutine ==
                    cardIndex) // Only show the button for the selected routine
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to the camera page with multiple weights based on selected percentages
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WorkCamPage(
                              weights: percentages
                                  .map((p) => widget.oneRM * p)
                                  .toList(),
                              exerciseName: widget.exerciseName,
                            ), // Todo: reps : reps (deleted)
                          ),
                        );
                      },
                      child: Text('이 루틴으로 운동 시작하기'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
