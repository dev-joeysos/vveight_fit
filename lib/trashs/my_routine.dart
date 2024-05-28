import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../screens/workout_screens/guide_page.dart';

// 루틴 추천 카드 컴포넌트
class MyRoutine extends StatefulWidget {
  final List<RoutineSet> routineSets;

  const MyRoutine({
    Key? key,
    required this.routineSets,
  }) : super(key: key);

  @override
  _MyRoutineState createState() => _MyRoutineState();
}

class _MyRoutineState extends State<MyRoutine> {
  late List<TextEditingController> weightControllers;
  late List<TextEditingController> repsControllers;

  get exerciseName => null;

  @override
  void initState() {
    super.initState();
    weightControllers = widget.routineSets.map((set) => TextEditingController(text: set.weight)).toList();
    repsControllers = widget.routineSets.map((set) => TextEditingController(text: set.reps)).toList();
  }

  @override
  void dispose() {
    weightControllers.forEach((controller) => controller.dispose());
    repsControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String title = widget.routineSets.isNotEmpty ? widget.routineSets.first.exerciseName : "루틴 이름 없음";

    return Column(
      children: <Widget>[
        const SizedBox(height: 15),
        Card(
          elevation: 5,
          shadowColor: Colors.black.withOpacity(0.2),
          color: const Color(0xFF6AC7F0),
          margin: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GuidePage(exerciseName: exerciseName, exerciseId: '',)),
                      ),
                      child: const Text('시작'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF123364),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.white, thickness: 1.2),
                ...List.generate(widget.routineSets.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Set ${widget.routineSets[index].setId}', style: const TextStyle(fontSize: 18.0, color: Colors.black)),
                        Row(
                          children: [
                            SizedBox(
                              width: 50,
                              child: TextFormField(
                                controller: weightControllers[index],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.right, // 텍스트를 오른쪽 정렬로 변경
                                decoration: InputDecoration(
                                  hintText: '00', // 예시 텍스트
                                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  filled: true, // 배경색 채우기 활성화
                                  fillColor: Color(0xFFF004C97), // 배경색을 조금 더 어둡게 설정
                                ),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 6), // 밑줄과 일치하게 맞춤
                              child: Text('kg', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 50,
                              child: TextFormField(
                                controller: repsControllers[index],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.right, // 텍스트를 오른쪽 정렬로 변경
                                decoration: InputDecoration(
                                  hintText: '00', // 예시 텍스트
                                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  filled: true, // 배경색 채우기 활성화
                                  fillColor: Color(0xFFF004C97), // 배경색을 조금 더 어둡게 설정
                                ),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 6), // 밑줄과 일치하게 맞춤
                              child: Text('reps', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),

                const Divider(color: Colors.white, thickness: 1.2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(onPressed: null, child: const Text('del btn', style: TextStyle(color: Colors.white))),
                    ElevatedButton(onPressed: null, child: const Text('add btn', style: TextStyle(color: Colors.white))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class RoutineSet {
  final String exerciseName;
  final int setId;
  String weight;
  String reps;

  RoutineSet({
    required this.exerciseName,
    required this.setId,
    required this.weight,
    required this.reps,
  });
}
