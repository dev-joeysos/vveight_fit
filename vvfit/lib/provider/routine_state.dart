import 'package:flutter/material.dart';

class RoutineState with ChangeNotifier {
  String exerciseName = '';
  String regressionId = '';

  void updateData(String name, String id) {
    exerciseName = name;
    regressionId = id;
    notifyListeners();
  }
}
