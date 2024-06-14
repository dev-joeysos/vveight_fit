import 'package:flutter/material.dart';

class TestWeightsProvider with ChangeNotifier {
  List<double> _testWeights = [];
  String? _exerciseId;

  List<double> get testWeights => _testWeights;
  String? get exerciseId => _exerciseId;

  void setTestWeights(List<double> weights, String exerciseId) {
    _testWeights = weights;
    _exerciseId = exerciseId;
    notifyListeners();
  }
}
