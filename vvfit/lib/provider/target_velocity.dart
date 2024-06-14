import 'package:flutter/cupertino.dart';

class TargetVelo with ChangeNotifier {
  double _targetVelocity = 0.0;

  double get targetVelocity => _targetVelocity;

  void setTargetVelocity(double newVelocity) {
    _targetVelocity = newVelocity;
    notifyListeners();
  }
}
