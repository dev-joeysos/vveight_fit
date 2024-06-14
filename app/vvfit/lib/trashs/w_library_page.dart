import 'package:flutter/material.dart';

class WLibraryPage extends StatelessWidget {
  // 생성자에 콜백 함수를 포함합니다.
  // Workout_page 에 선택된 운도 리스트를 동적으로 넘겨주기 위함입니다.
  final Function(List<Exercise>) onRoutineCreated;
  WLibraryPage({Key? key, required this.onRoutineCreated}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ExerciseWLibraryPage(onRoutineCreated: onRoutineCreated),
    );
  }
}

class ExerciseWLibraryPage extends StatefulWidget {
  // 이 페이지도 업데이트합니다.
  final Function(List<Exercise>) onRoutineCreated;
  ExerciseWLibraryPage({Key? key, required this.onRoutineCreated}) : super(key: key);

  @override
  _ExerciseWLibraryPageState createState() => _ExerciseWLibraryPageState();
}

class _ExerciseWLibraryPageState extends State<ExerciseWLibraryPage> {
  // 더미 데이터
  List<Exercise> exercises = [
    Exercise(name: '벤치 프레스', tag: '가슴', imageUrl: 'assets/images/puang.png', isSelected: false),
    Exercise(name: '덤벨 플라이', tag: '가슴', imageUrl: 'assets/images/puang.png', isSelected: false),
    Exercise(name: '데드리프트', tag: '등', imageUrl: 'assets/images/puang.png', isSelected: false),
    Exercise(name: '바벨 로우', tag: '등', imageUrl: 'assets/images/puang.png', isSelected: false),
    Exercise(name: '숄더 프레스', tag: '어깨', imageUrl: 'assets/images/puang.png', isSelected: false),
    Exercise(name: '사이드 레터럴 레이즈', tag: '어깨', imageUrl: 'assets/images/puang.png', isSelected: false),
    Exercise(name: '인클라인 벤치 프레스', tag: '가슴', imageUrl: 'assets/images/puang.png', isSelected: false),
    Exercise(name: '풀업', tag: '등', imageUrl: 'assets/images/puang.png', isSelected: false),
    Exercise(name: '페이스 풀', tag: '어깨', imageUrl: 'assets/images/puang.png', isSelected: false),
    Exercise(name: '푸시업', tag: '가슴', imageUrl: 'assets/images/puang.png', isSelected: false),
    Exercise(name: '렛 풀다운', tag: '등', imageUrl: 'assets/images/puang.png', isSelected: false),
    Exercise(name: '프론트 레이즈', tag: '어깨', imageUrl: 'assets/images/puang.png', isSelected: false),
    Exercise(name: '체스트 프레스', tag: '가슴', imageUrl: 'assets/images/puang.png', isSelected: false),
    Exercise(name: '원암 덤벨 로우', tag: '등', imageUrl: 'assets/images/puang.png', isSelected: false),
    Exercise(name: '덤벨 숄더 프레스', tag: '어깨', imageUrl: 'assets/images/puang.png', isSelected: false),
    Exercise(name: '플라이', tag: '가슴', imageUrl: 'assets/images/puang.png', isSelected: false),
    Exercise(name: '시티드 로우', tag: '등', imageUrl: 'assets/images/puang.png', isSelected: false),
    Exercise(name: '아놀드 프레스', tag: '어깨', imageUrl: 'assets/images/puang.png', isSelected: false),
    Exercise(name: '디클라인 벤치 프레스', tag: '가슴', imageUrl: 'assets/images/puang.png', isSelected: false),
    Exercise(name: '백 익스텐션', tag: '등', imageUrl: 'assets/images/puang.png', isSelected: false),
  ];

  String? selectedTag; // 태그 선택 변수
  String searchText = ''; // 사용자가 검색창에 입력하는 텍스트를 저장할 변수

  @override
  Widget build(BuildContext context) {
    // 검색어와 선택된 태그에 따라 필터링된 운동 리스트
    List<Exercise> filteredExercises = exercises.where((exercise) {
      return (selectedTag == null || exercise.tag == selectedTag) &&
          (searchText.isEmpty || exercise.name.toLowerCase().contains(searchText.toLowerCase()));
    }).toList();

    return Scaffold(
      body: Column(
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

          SizedBox(height: 10),
          // 운동 태그 선택
          Wrap(
            spacing: 8.0, // 버튼 사이의 공간
            children: ['모두', '가슴', '등', '어깨'].map((tag) {
              bool isSelected = (tag == '모두' && selectedTag == null) || tag == selectedTag;
              return ElevatedButton(
                onPressed: () => setState(() {
                  selectedTag = tag == '모두' ? null : tag;
                }),
                child: Text(tag),
                // 선택된 버튼에 따라 스타일을 동적으로 변경
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? Colors.blue : Colors.white, // 선택 상태에 따라 배경색 변경
                  foregroundColor: isSelected? Colors.white : Colors.black, // 선택 상태에 따라 텍스트색 변경
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // 버튼 내부의 패딩
                  shape: RoundedRectangleBorder( // 버튼의 모양을 정의
                    borderRadius: BorderRadius.circular(20), // 버튼의 모서리를 둥글게
                  ),
                ),
              );
            }).toList(),
          ),

          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: filteredExercises.length,
              itemBuilder: (context, index) {
                var exercise = filteredExercises[index];
                return ListTile(
                  leading: Image.asset(exercise.imageUrl), // 로컬 이미지 사용
                  title: Text(exercise.name),
                  trailing: Icon(
                    exercise.isSelected ? Icons.check_box : Icons.check_box_outline_blank, color: Colors.blue,
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

          SizedBox(height: 10),
          ElevatedButton(
            onPressed: _createRoutine, // '나만의 루틴 생성하기' 버튼 클릭 시 호출될 메소드
            child: Text('나만의 루틴 생성하기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, // 버튼 색상
              foregroundColor: Colors.white, // 텍스트 색상
            ),
          ),

          SizedBox(height: 10),
        ],
      ),
    );
  }
  void _createRoutine() {
    List<Exercise> selectedExercises = exercises.where((exercise) => exercise.isSelected).toList();
    widget.onRoutineCreated(selectedExercises); // 선택된 운동들로 콜백 함수 호출
    Navigator.pop(context); // 선택 후 LibraryPage를 선택적으로 닫기
  }
}

class Exercise {
  String name;
  String tag;
  String imageUrl;
  bool isSelected;

  Exercise({required this.name, required this.tag, required this.imageUrl, this.isSelected = false});
}
