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

  const EditRoutine({
    Key? key,
    required this.setDetail,
    required this.setIndex,
    required this.onUpdate,
    required this.onDelete,
    required this.exerciseName,
    required this.onStartWorkout,
    required this.exerciseId, // 생성자에서 받음
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
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
            child: Text("Set $setIndex", style: TextStyle(fontWeight: FontWeight.bold)),
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
          _buildTextFormField(
            initialValue: setDetail.reps.toString(),
            label: '횟수',
            onChanged: (val) {
              setDetail.reps = int.tryParse(val) ?? setDetail.reps;
              onUpdate();
            },
          ),
          IconButton(
            icon: Icon(setDetail.completed ? Icons.check_box : Icons.check_box_outline_blank),
            color: setDetail.completed ? Colors.blue : null,
            onPressed: () {
              setDetail.completed = !setDetail.completed;
              onUpdate();
            },
          ),
          IconButton(
            icon: Icon(Icons.play_arrow),
            color: Colors.blueAccent,
            onPressed: () {
              onStartWorkout(); // 운동 시작 콜백 호출
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GuidePage(exerciseName: exerciseName, exerciseId: exerciseId,),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            color: Colors.pinkAccent,
            onPressed: onDelete,
          ),
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
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          isDense: true,
        ),
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        onChanged: onChanged,
      ),
    );
  }
}
