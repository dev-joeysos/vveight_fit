import 'package:flutter/foundation.dart';

class SetDetail with ChangeNotifier {
  double weight;
  int reps;
  bool completed;

  SetDetail({this.weight = 0, this.reps = 0, this.completed = false});

  void updateWeight(double newWeight) {
    weight = newWeight;
    notifyListeners();
  }

  void updateReps(int newReps) {
    reps = newReps;
    notifyListeners();
  }

  void toggleCompleted() {
    completed = !completed;
    notifyListeners();
  }
}
