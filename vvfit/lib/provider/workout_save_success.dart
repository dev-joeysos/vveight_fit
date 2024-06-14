import 'package:flutter/cupertino.dart';

class WorkoutSaveProvider with ChangeNotifier {
  bool _isSaved = false;

  bool get isSaved => _isSaved;

  void setSaved(bool value) {
    _isSaved = value;
    notifyListeners();
  }
}