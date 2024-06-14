import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/realweghts_list.dart';
import '../screens/workout_screens/guide_page.dart';
import '../screens/workout_screens/routine_page.dart';

class EditRoutine extends StatefulWidget {
  final SetDetail setDetail;
  final int setIndex;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;
  final String exerciseName;
  final VoidCallback onStartWorkout; // 운동 시작 콜백 추가
  final String exerciseId;
  final double weight;
  final int reps;
  final int rest_period;
  final List<double> realWeights; // 진짜 운동용 무게 받기 _ 불러온 루틴 데이터의 최신 운동수행 무게
  final Map<String, dynamic>? regressionData; // 회귀 데이터 받기
  final List<double>? testWeights; // 추가된 부분

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
    required this.rest_period,
    required this.realWeights,
    this.regressionData,
    this.testWeights, // 추가된 부분
  }) : super(key: key);

  @override
  State<EditRoutine> createState() => _EditRoutineState();
}

class _EditRoutineState extends State<EditRoutine> {
  late List<double> weights;

  @override
  Widget build(BuildContext context) {
    final testWeightsProvider = Provider.of<TestWeightsProvider>(context);

    // TestWeightsProvider의 값이 변경되면 weights 업데이트
    if (testWeightsProvider.exerciseId == widget.exerciseId) {
      setState(() {
        weights = testWeightsProvider.testWeights;
      });
    }
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      padding: EdgeInsets.all(12),
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 1), // border 두께 설정
        borderRadius: BorderRadius.circular(8), // border radius 설정
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2),
            child: Text("Set${widget.setIndex}",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          SizedBox(width: 8),
          _buildTextFormField(
            initialValue: widget.setDetail.weight.toString(),
            label: 'kg',
            onChanged: (val) {
              widget.setDetail.weight = double.tryParse(val) ?? widget.setDetail.weight;
              widget.onUpdate();
            },
          ),
          SizedBox(width: 8),
          // if (widget.setDetail.reps != 0)
          _buildTextFormField(
            initialValue: widget.setDetail.reps.toString(),
            label: 'reps',
            onChanged: (val) {
              widget.setDetail.reps = int.tryParse(val) ?? widget.setDetail.reps;
              widget.onUpdate();
            },
          ),
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
          contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          fillColor: Colors.black,
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
