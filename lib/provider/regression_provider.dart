import 'package:flutter/material.dart';

class RegressionModel {
  String regressionIdBench;
  String? regressionIdSquat;
  String regressionIdDL;
  String regressionIdSP;

  RegressionModel({
    required this.regressionIdBench,
    this.regressionIdSquat,
    required this.regressionIdDL,
    required this.regressionIdSP,
  });
}

class RegressionProvider with ChangeNotifier {
  RegressionModel _regressionModel = RegressionModel(
    regressionIdBench: '147',
    regressionIdSquat: null,
    regressionIdDL: '00000',
    regressionIdSP: '33',
  );

  RegressionModel get regressionModel => _regressionModel;

  void updateRegressionId(String exerciseName, int regressionId) {
    switch (exerciseName) {
      case 'Bench Press':
        _regressionModel.regressionIdBench = regressionId.toString();
        break;
      case 'Squat':
        _regressionModel.regressionIdSquat = regressionId.toString();
        break;
      case 'Dead Lift':
        _regressionModel.regressionIdDL = regressionId.toString();
        break;
      case 'Over Head Press':
        _regressionModel.regressionIdSP = regressionId.toString();
        break;
      default:
        throw ArgumentError('Unknown exercise name: $exerciseName');
    }
    notifyListeners();
  }
}
