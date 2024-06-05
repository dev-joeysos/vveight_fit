import 'package:flutter/material.dart';
import '../screens/workout_screens/guide_page.dart';
import '../screens/workout_screens/routine_page.dart';

class EditRoutine extends StatelessWidget {
  final SetDetail setDetail;
  final int setIndex;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;
  final String exerciseName;
  final VoidCallback onStartWorkout; // 운동 시작 콜백 추가
  final String exerciseId;
  final double weight;
  final int reps;
  final List<double> realWeights; // 진짜 운동용 무게 받기 _ 불러온 루틴 데이터의 최신 운동수행 무게
  final Map<String, dynamic>? regressionData; // 회귀 데이터 받기

  const EditRoutine({
    Key? key,
    required this.setDetail,
    required this.setIndex,
    required this.onUpdate,
    required this.onDelete,
    required this.exerciseName,
    required this.onStartWorkout,
    required this.exerciseId, // 생성자에서 받음
    required this.weight,
    required this.reps,
    required this.realWeights,
    this.regressionData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 0),
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.blue[100],

        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text("Set $setIndex",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          _buildTextFormField(
            initialValue: setDetail.weight.toString(),
            label: 'kg',
            onChanged: (val) {
              setDetail.weight = double.tryParse(val) ?? setDetail.weight;
              onUpdate();
            },
          ),
          SizedBox(width: 8),
          if (setDetail.reps != 0)
            _buildTextFormField(
              initialValue: setDetail.reps.toString(),
              label: '횟수',
              onChanged: (val) {
                setDetail.reps = int.tryParse(val) ?? setDetail.reps;
                onUpdate();
              },
            ),
          // Todo: 루틴 불러오기 없이 운동 시작했을 때 가능하게
          // IconButton(
          //   icon: Icon(setDetail.completed
          //       ? Icons.check_box
          //       : Icons.check_box_outline_blank),
          //   color: setDetail.completed ? Colors.blue : null,
          //   onPressed: () {
          //     setDetail.completed = !setDetail.completed;
          //     onUpdate();
          //   },
          // ),
          // IconButton(
          //   icon: Icon(Icons.camera_alt_outlined),
          //   color: Colors.blueAccent,
          //   onPressed: () {
          //     onStartWorkout(); // 운동 시작 콜백 호출
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => GuidePage(
          //           weight: weight,
          //           reps: reps,
          //           exerciseId: exerciseId,
          //           exerciseName: exerciseName,
          //           realWeights: realWeights,
          //           regressionData: regressionData,
          //         ),
          //       ),
          //     );
          //   },
          // ),
          // IconButton(
          //   icon: Icon(Icons.delete),
          //   color: Colors.pinkAccent,
          //   onPressed: onDelete,
          // ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required String initialValue,
    required String label,
    required Function(String) onChanged,
  }) {
    return Expanded(
      child: TextFormField(
        initialValue: initialValue,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          isDense: true,
          fillColor: Colors.white,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue), // Focused border color
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black), // Enabled border color
          ),
        ),
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        onChanged: onChanged,
      ),
    );
  }
}
