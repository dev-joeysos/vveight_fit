import 'package:flutter/foundation.dart';

// RDP: Regression Data Provider
class RDP with ChangeNotifier {
  int? _testRegressionId;

  int? get testRegressionId => _testRegressionId;

  void setTestRegressionId(int? id) {
    _testRegressionId = id;
    notifyListeners();
  }
}
