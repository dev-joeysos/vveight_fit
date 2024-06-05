import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../workout_screens/routine_page.dart';

class PurposePage extends StatefulWidget {
  final String target;

  const PurposePage({super.key, required this.target});

  @override
  State<PurposePage> createState() => _PurposePageState();
}

class _PurposePageState extends State<PurposePage> {
  bool _dontAskAgain = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("운동 목표를 설정해주세요"),
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
                      title: "지구력 향상",
                      onTap: () => goToRoutinePage("endurance"),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Expanded(
                    child: PurposeButton(
                      title: "근력 향상",
                      onTap: () => goToRoutinePage("strength"),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Expanded(
                    child: PurposeButton(
                      title: "근비대",
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

  // purpose -> RoutinePage
  void goToRoutinePage(String purpose) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => RoutinePage(
            target: widget.target,
            purpose: purpose),
      ),
    );
  }
}

class PurposeButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const PurposeButton({super.key, required this.title, required this.onTap});

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