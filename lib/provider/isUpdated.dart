import 'package:flutter/material.dart';

class IsUpdated with ChangeNotifier {
  bool _isUpdated = false;

  bool get isUpdated => _isUpdated;

  void setUpdated(bool value) {
    _isUpdated = value;
    notifyListeners();
  }
}
