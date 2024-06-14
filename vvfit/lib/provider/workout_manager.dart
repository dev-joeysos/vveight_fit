import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_project/provider/workout_data.dart';

class WorkoutManager with ChangeNotifier {
  WorkoutData? _workoutData;
  XFile? _imageFile;
  int? _workoutDuration;
  String _review = ''; // 리뷰를 저장할 변수

  WorkoutData? get workoutData => _workoutData;
  XFile? get imageFile => _imageFile;
  int? get workoutDuration => _workoutDuration;
  String get review => _review;

  void updateWorkoutData(WorkoutData data) {
    _workoutData = data;
    notifyListeners();
  }

  void updateImageFile(XFile file) {
    _imageFile = file;
    notifyListeners();
  }

  void updateWorkoutDuration(int duration) {
    _workoutDuration = duration;
    notifyListeners();
  }

  void updateReview(String reviewText) {
    _review = reviewText;
    notifyListeners();
  }
}
