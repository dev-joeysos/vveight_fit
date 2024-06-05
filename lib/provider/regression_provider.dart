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
    regressionIdBench: '00001',
    regressionIdSquat: null,
    regressionIdDL: '00000',
    regressionIdSP: '00033',
  );

  RegressionModel get regressionModel => _regressionModel;

  void updateRegressionIds({
    String? regressionIdBench,
    String? regressionIdSquat,
    String? regressionIdDL,
    String? regressionIdSP,
  }) {
    if (regressionIdBench != null) {
      _regressionModel.regressionIdBench = regressionIdBench;
    }
    if (regressionIdSquat != null) {
      _regressionModel.regressionIdSquat = regressionIdSquat;
    }
    if (regressionIdDL != null) {
      _regressionModel.regressionIdDL = regressionIdDL;
    }
    if (regressionIdSP != null) {
      _regressionModel.regressionIdSP = regressionIdSP;
    }
    notifyListeners();
  }
}
