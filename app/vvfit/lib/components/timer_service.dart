import 'dart:async';

import 'package:flutter/cupertino.dart';

class TimerService with ChangeNotifier {
  Timer? _timer;
  int _seconds = 0;
  bool _isRunning = false;  // 타이머가 실행 중인지 여부

  int get seconds => _seconds;
  bool get isRunning => _isRunning;

  void startTimer() {
    if (!_isRunning) {
      _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
        _seconds++;
        notifyListeners();
      });
      _isRunning = true;
      notifyListeners();
    }
  }

  void stopTimer() {
    if (_isRunning) {
      _timer?.cancel();
      _isRunning = false;
      notifyListeners();
    }
  }

  void resetTimer() {
    _timer?.cancel();
    _seconds = 0;
    _isRunning = false;
    notifyListeners();
  }
}
