import 'package:flutter/material.dart';
import 'package:flutter_project/screens/sample_screens/profile_creation_page.dart';
import 'package:flutter_project/screens/sample_screens/purpose_page.dart';

import '../workout_screens/guide_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SelectPage(),
    );
  }
}

class SelectPage extends StatefulWidget {
  const SelectPage({super.key});

  @override
  State<SelectPage> createState() => _SelectPageState();
}

class _SelectPageState extends State<SelectPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Workout Selection"),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close_rounded),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      // Todo: 4개 종목을 대표 운동으로 수정합니다.
      body: Column(
        children: <Widget>[
          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(child: buildWorkoutCard("Bench Press", "00001", "Chest")),
                // Expanded(child: buildWorkoutCard("가슴", "Emoji", "Chest")),
                VerticalDivider(width: 1, color: Colors.black),
                Expanded(
                    child: buildWorkoutCard("Squat", "00011", "lower body")), // Todo: 뭘까요 이건
              ],
            ),
          ),
          Divider(height: 1, color: Colors.black),
          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(child: buildWorkoutCard("Conventional Dead Lift", "00004", "Back", unavailable: true)),
                VerticalDivider(width: 1, color: Colors.black),
                Expanded(
                    child: buildWorkoutCard("Over Head Press", "00009", "Shoulder")),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildWorkoutCard(String title, String keyId, String key,
      {bool unavailable = false}) {
    return InkWell(
      onTap: () {
        if (unavailable) {
          navigateToGuidePage(keyId, title);
        } else {
          navigateToSamplePage(key);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: unavailable ? Colors.grey : Colors.black,
                ),
              ),
              Text(
                keyId,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: unavailable ? Colors.grey : Colors.black,
                ),
              ),
              if (unavailable)
                Text(
                  'LV 프로파일이 없습니다.',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void navigateToSamplePage(String key) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PurposePage(target: key),
      ),
    );
  }

  void navigateToGuidePage(String exerciseId, String exerciseName) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => GuidePage(exerciseId: exerciseId, exerciseName: exerciseName),
      ),
    );
  }
}
