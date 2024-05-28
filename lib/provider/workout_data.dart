import 'package:flutter/material.dart';

class ExerciseData {
  List<int> sessionCounts;
  List<double> weights;

  ExerciseData({required this.sessionCounts, required this.weights});
}

class WorkoutData extends ChangeNotifier {
  Map<String, ExerciseData> exerciseDetails = {};

  void updateData(String exerciseName, List<int> sessionCounts, List<double> weights) {
    if (exerciseDetails.containsKey(exerciseName)) {
      exerciseDetails[exerciseName] = ExerciseData(sessionCounts: sessionCounts, weights: weights);
    } else {
      exerciseDetails[exerciseName] = ExerciseData(sessionCounts: sessionCounts, weights: weights);
    }
    notifyListeners();
  }

  // 초기화 메서드 추가
  void resetData() {
    exerciseDetails.clear();
    notifyListeners();
  }

  ExerciseData? getData(String exerciseName) {
    return exerciseDetails[exerciseName];
  }
}
