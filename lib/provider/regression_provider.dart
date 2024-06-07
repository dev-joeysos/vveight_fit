import 'package:flutter/material.dart';

class RegressionModel {
  String? regressionIdBench;
  String? regressionIdSquat;
  String? regressionIdDL;
  String? regressionIdSP;

  RegressionModel({
    required this.regressionIdBench,
    this.regressionIdSquat,
    required this.regressionIdDL,
    required this.regressionIdSP,
  });
}

class RegressionProvider with ChangeNotifier {
  RegressionModel _regressionModel = RegressionModel(
    regressionIdBench: null,// '265',
    regressionIdDL: '237', // '237'
    regressionIdSP: '00000',
    regressionIdSquat: '215',
  );

  RegressionModel get regressionModel => _regressionModel;

  void updateRegressionId(String exerciseName, int regressionId) {
    switch (exerciseName) {
      case 'Bench Press':
        _regressionModel.regressionIdBench = regressionId.toString();
        break;
      case 'Conventional Dead Lift':
        _regressionModel.regressionIdDL = regressionId.toString();
        break;
      case 'Overhead Press':
        _regressionModel.regressionIdSP = regressionId.toString();
        break;
      case 'Back Squat':
        _regressionModel.regressionIdSquat = regressionId.toString();
        break;
      default:
        throw ArgumentError('Unknown exercise name: $exerciseName');
    }
    notifyListeners();
  }
}
