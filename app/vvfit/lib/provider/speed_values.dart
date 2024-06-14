import 'package:flutter/foundation.dart';

class SpeedValuesProvider with ChangeNotifier {
  Map<String, List<double>> _speedValues = {};

  Map<String, List<double>> get speedValues => _speedValues;

  void updateSpeedValues(String exerciseName, List<double> values) {
    _speedValues[exerciseName] = values;
    notifyListeners();
  }

  List<double>? getSpeedValues(String exerciseName) {
    return _speedValues[exerciseName];
  }
}
