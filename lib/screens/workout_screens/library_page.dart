import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_project/components/styled_button.dart';
import 'package:http/http.dart' as http;

import '../../components/long_button.dart';

class Exercise {
  final String exerciseId;
  final String name;
  final String category;
  final String description;
  final String target;
  final String? oneRepVelocity;
  bool isSelected;
  bool isMain;

  Exercise({
    required this.exerciseId,
    required this.name,
    required this.category,
    required this.description,
    required this.target,
    this.oneRepVelocity,
    this.isSelected = false,
    this.isMain = false,
  });

  factory Exercise.fromJson(Map<String, dynamic> json, {bool isMain = false}) {
    return Exercise(
      exerciseId: json['exercise_id'],
      name: json['name'],
      category: json['category'],
      description: json['description'],
      target: json['target'],
      oneRepVelocity: json['one_rep_velocity'],
      isSelected: false,
      isMain: isMain,
    );
  }

  @override
  String toString() {
    return 'Exercise{exerciseId: $exerciseId, name: $name, category: $category, description: $description, target: $target, oneRepVelocity: $oneRepVelocity, isSelected: $isSelected, isMain: $isMain}';
  }
}

class LibraryPage extends StatefulWidget {
  final String target;

  const LibraryPage({super.key, required this.target});

  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  late Future<Map<String, List<Exercise>>> exercisesFuture;

  @override
  void initState() {
    super.initState();
    exercisesFuture = fetchRoutineData();
  }

  Future<Map<String, List<Exercise>>> fetchRoutineData() async {
    try {
      final response = await http.post(
        Uri.parse('http://52.79.236.191:3000/api/routine/getForm'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'target': widget.target,
        }),
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        List<Exercise> mainExercises = (data['main'] as List)
            .map((data) => Exercise.fromJson(data, isMain: true))
            .toList();
        List<Exercise> subExercises = (data['sub'] as List)
            .map((data) => Exercise.fromJson(data, isMain: false))
            .toList();
        return {'main': mainExercises, 'sub': subExercises};
      } else {
        throw Exception('Failed to load routine data');
      }
    } catch (e) {
      return Future.error('Failed to load routine data: $e');
    }
  }

  String searchText = ''; // 사용자가 검색창에 입력하는 텍스트를 저장할 변수
  String? selectedTag; // 태그 선택 변수

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('라이브러리 페이지'),
      ),
      body: FutureBuilder<Map<String, List<Exercise>>>(
        future: exercisesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            List<Exercise> mainExercises = snapshot.data?['main'] ?? [];
            List<Exercise> subExercises = snapshot.data?['sub'] ?? [];

            // 검색어와 선택된 태그에 따라 필터링된 운동 리스트
            List<Exercise> filteredMainExercises =
                mainExercises.where((exercise) {
              return (selectedTag == null || exercise.target == selectedTag) &&
                  (searchText.isEmpty ||
                      exercise.name
                          .toLowerCase()
                          .contains(searchText.toLowerCase()));
            }).toList();

            List<Exercise> filteredSubExercises =
                subExercises.where((exercise) {
              return (selectedTag == null || exercise.target == selectedTag) &&
                  (searchText.isEmpty ||
                      exercise.name
                          .toLowerCase()
                          .contains(searchText.toLowerCase()));
            }).toList();

            return Column(
              children: [
                // 운동 검색창
                Padding(
                  padding: const EdgeInsets.fromLTRB(15.0, 10, 15.0, 0),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        searchText = value; // 사용자 입력에 따라 searchText 업데이트
                      });
                    },
                    decoration: InputDecoration(
                      labelText: '운동 검색',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.search),
                    ),
                  ),
                ),

                // SizedBox(height: 10),
                // 운동 태그 선택
                // Wrap(
                //   spacing: 8.0, // 버튼 사이의 공간
                //   children: ['모두', '가슴', '등', '어깨'].map((tag) {
                //     bool isSelected = (tag == '모두' && selectedTag == null) ||
                //         tag == selectedTag;
                //     return ElevatedButton(
                //       onPressed: () => setState(() {
                //         selectedTag = tag == '모두' ? null : tag;
                //       }),
                //       child: Text(tag),
                //       // 선택된 버튼에 따라 스타일을 동적으로 변경
                //       style: ElevatedButton.styleFrom(
                //         backgroundColor:
                //             isSelected ? Colors.blue : Colors.white,
                //         // 선택 상태에 따라 배경색 변경
                //         foregroundColor:
                //             isSelected ? Colors.white : Colors.black,
                //         // 선택 상태에 따라 텍스트색 변경
                //         padding:
                //             EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                //         // 버튼 내부의 패딩
                //         shape: RoundedRectangleBorder(
                //           // 버튼의 모양을 정의
                //           borderRadius:
                //               BorderRadius.circular(20), // 버튼의 모서리를 둥글게
                //         ),
                //       ),
                //     );
                //   }).toList(),
                // ),

                SizedBox(height: 10),
                Expanded(
                  child: Column(
                    children: [
                      Text('메인 운동',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredMainExercises.length,
                          itemBuilder: (context, index) {
                            var exercise = filteredMainExercises[index];
                            return ListTile(
                              title: Text(exercise.name),
                              trailing: Icon(
                                exercise.isSelected
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                color: Colors.blue,
                              ),
                              onTap: () {
                                setState(() {
                                  exercise.isSelected = !exercise.isSelected;
                                });
                              },
                            );
                          },
                        ),
                      ),
                      Text('서브 운동',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredSubExercises.length,
                          itemBuilder: (context, index) {
                            var exercise = filteredSubExercises[index];
                            return ListTile(
                              title: Text(exercise.name),
                              trailing: Icon(
                                exercise.isSelected
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                color: Colors.blue,
                              ),
                              onTap: () {
                                setState(() {
                                  exercise.isSelected = !exercise.isSelected;
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 10),
                LongButton(
                  onPressed: () {
                    List<Exercise> selectedExercises = [
                      ...mainExercises.where((exercise) => exercise.isSelected),
                      ...subExercises.where((exercise) => exercise.isSelected),
                    ];
                    Navigator.pop(
                        context, selectedExercises); // 선택 목록을 반환하고 페이지를 닫습니다
                  },
                  text: '선택 완료',
                ),
                SizedBox(height: 24),
              ],
            );
          } else {
            // Show a loading spinner
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
