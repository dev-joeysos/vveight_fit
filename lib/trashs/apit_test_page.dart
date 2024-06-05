import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class APITestPage extends StatefulWidget {
  @override
  _APITestPageState createState() => _APITestPageState();
}

class _APITestPageState extends State<APITestPage> {
  String apiResponse = '';

  Future<void> createRoutine() async {
    const url = 'http://13.125.4.213:3000/api/routine/create';
    const requestBody = {
      'user_id': '00001',
      'target': 'Chest',
      'routine_name': 'default',
      'purpose': 'endurance',
      'recent_regression_id': 00001,
      'main': [00001],
      'sub': [00012, 00013],
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('Request URL: $url');
      print('Request Body: ${jsonEncode(requestBody)}');
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        setState(() {
          apiResponse = '''
Success: ${responseBody['success']}
Message: ${responseBody['message']}
Routine ID: ${responseBody['routine_id']}
          ''';
        });
      } else {
        setState(() {
          apiResponse = 'Error: ${response.statusCode} - ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        apiResponse = 'Error: $e';
      });
    }
  }

  Future<void> getRoutine() async {
    const url = 'http://13.125.4.213:3000/api/routine/get';
    const requestBody = {
      'routine_id': 38, // 조회할 루틴 번호
      'user_id': '00001', // 고정된 사용자 ID
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('Request URL: $url');
      print('Request Body: ${jsonEncode(requestBody)}');
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        setState(() {
          apiResponse = jsonEncode(responseBody, toEncodable: (e) => e.toString());
        });
      } else {
        setState(() {
          apiResponse = 'Error: ${response.statusCode} - ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        apiResponse = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('API 테스트 페이지'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: createRoutine,
              child: Text('루틴 자동 생성'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: getRoutine,
              child: Text('루틴 불러오기'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  apiResponse,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
