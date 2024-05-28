import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../workout_screens/routine_page.dart';

class PurposePage extends StatefulWidget {
  final String target;

  const PurposePage({Key? key, required this.target}) : super(key: key);

  @override
  State<PurposePage> createState() => _PurposePageState();
}

class _PurposePageState extends State<PurposePage> {
  bool _dontAskAgain = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("목표 페이지"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: PurposeButton(
                      title: "For Endurance",
                      onTap: () => goToRoutinePage("endurance"),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Expanded(
                    child: PurposeButton(
                      title: "For Strength",
                      onTap: () => goToRoutinePage("strength"),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Expanded(
                    child: PurposeButton(
                      title: "For Hypertrophy",
                      onTap: () => goToRoutinePage("hypertrophy"),
                    ),
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: _dontAskAgain,
                        onChanged: (bool? value) {
                          setState(() {
                            _dontAskAgain = value ?? false;
                          });
                        },
                      ),
                      const Text("다음 번부터 묻지 않기(사용자 설정에서 변경 가능)"),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void goToRoutinePage(String purpose) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => RoutinePage(
            target: widget.target,
            purpose: purpose), // Todo: SamplePage _ purpose 가 필요한 지는 모르겠음
      ),
    );
  }
}

class PurposeButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const PurposeButton({Key? key, required this.title, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          title,
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class SamplePage extends StatefulWidget {
  final String target;
  final String purpose;

  const SamplePage({Key? key, required this.target, required this.purpose})
      : super(key: key);

  @override
  _SamplePageState createState() => _SamplePageState();
}

class _SamplePageState extends State<SamplePage> {
  late Future<String> routineData;

  @override
  void initState() {
    super.initState();
    routineData = fetchRoutineData();
  }

  Future<String> fetchRoutineData() async {
    try {
      // Todo: 백엔드 API에서 운동 목록 불러오기
      final response = await http.post(
        Uri.parse('http://13.125.4.213:3000/api/routine/getForm'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode(<String, String>{
          'target': widget.target,
        }),
      );
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to load routine data');
      }
    } catch (e) {
      return Future.error('Failed to load routine data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sample Page"),
      ),
      body: Center(
        child: FutureBuilder<String>(
          future: routineData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              }
              return Text(
                  "타겟: ${widget.target}, 목표: ${widget.purpose}, 데이터: ${snapshot.data}");
            } else {
              // Show a loading spinner
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
