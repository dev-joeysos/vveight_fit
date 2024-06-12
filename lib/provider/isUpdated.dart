import 'package:flutter/material.dart';

class IsUpdated with ChangeNotifier {
  bool _isUpdated = false;

  bool get isUpdated => _isUpdated;

  void setUpdated(bool updated) {
    print('isUpdated 값입니다 = $_isUpdated to $updated');
    _isUpdated = updated;
    notifyListeners();
  }
}
