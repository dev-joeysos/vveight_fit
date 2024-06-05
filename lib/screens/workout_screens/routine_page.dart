import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../components/timer_service.dart';
import '../../provider/isUpdated.dart';
import '../../provider/regression_data.dart';
import '../../provider/regression_provider.dart';
import '../../provider/routine_state.dart';
import '../../provider/speed_values.dart';
import '../../provider/workout_data.dart';
import '../../provider/target_velocity.dart';
import '../result_screens/review_page.dart';
import 'guide_page.dart';
import 'library_page.dart';
import 'package:flutter_project/components/edit_routine.dart';
import 'package:http/http.dart' as http;

class SetDetail {
  double weight = 0;
  int reps = 0;
  bool completed = false;

  SetDetail({this.weight = 0, this.reps = 0, this.completed = false});
}

class RoutinePage extends StatefulWidget {
  final String target;
  final String purpose;

  const RoutinePage({super.key, required this.target, required this.purpose});

  @override
  _RoutinePageState createState() => _RoutinePageState();
}

class _RoutinePageState extends State<RoutinePage> {
  List<Exercise> selectedExercises = [];
  bool isExerciseSelected = false;
  Map<int, bool> expandedStates = {};
  Map<int, List<SetDetail>> exerciseSets = {};
  Map<int, bool> getFailedStates = {}; // 각 운동에 대한 _getFailed 상태를 관리하기 위한 Map
  Map<int, Map<String, dynamic>> exerciseRegressionData = {};
  int? createdRoutineId;

  List<double> getRealWeights(int exerciseIndex) {
    return exerciseSets[exerciseIndex]!
        .map((setDetail) => setDetail.weight)
        .toList();
  }

  bool isWorkoutStarted = false;
  Timer? workoutTimer;
  int workoutDuration = 0;

  OverlayEntry? _timerOverlay;
  Offset _timerPosition = Offset(20, 80);

  late Future<String> routineData;

  String formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return "${minutes.toString().padLeft(2, '0')}m ${seconds.toString().padLeft(2, '0')}s";
  }

  OverlayEntry _createTimerOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Positioned(
        left: _timerPosition.dx,
        top: _timerPosition.dy,
        child: Draggable(
          feedback: Material(
            color: Colors.transparent,
            child: _buildTimerContainer(context),
          ),
          childWhenDragging: Container(),
          child: Material(
            color: Colors.transparent,
            child: _buildTimerContainer(context),
          ),
          onDragEnd: (details) {
            setState(() {
              _timerPosition = details.offset;
            });
            _updateTimerOverlay();
          },
        ),
      ),
    );
  }

  Widget _buildTimerContainer(BuildContext context) {
    bool isTimerRunning = Provider.of<TimerService>(context).isRunning;

    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[900],
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.timer, color: Colors.white),
              SizedBox(width: 8),
              Text(
                '타이머',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            formatTime(Provider.of<TimerService>(context).seconds),
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(isTimerRunning ? Icons.pause : Icons.play_arrow),
                color: Colors.white,
                onPressed: _toggleTimer,
              ),
              IconButton(
                icon: Icon(Icons.refresh),
                color: Colors.white,
                onPressed: _resetTimer,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _toggleTimer() {
    var timerService = Provider.of<TimerService>(context, listen: false);
    if (timerService.isRunning) {
      timerService.stopTimer();
    } else {
      timerService.startTimer();
    }
  }

  void _resetTimer() {
    var timerService = Provider.of<TimerService>(context, listen: false);
    timerService.resetTimer();
  }

  @override
  void initState() {
    super.initState();
    routineData = fetchRoutineData();
  }

  void _updateTimerOverlay() {
    _timerOverlay?.remove();
    _timerOverlay = _createTimerOverlayEntry();
    Overlay.of(context)?.insert(_timerOverlay!);
  }

  void _toggleWorkout() {
    setState(() {
      isWorkoutStarted = !isWorkoutStarted;
      if (isWorkoutStarted) {
        Provider.of<TimerService>(context, listen: false).startTimer();
        if (_timerOverlay == null) {
          _timerOverlay = _createTimerOverlayEntry();
          Overlay.of(context)?.insert(_timerOverlay!);
        }
        expandedStates.updateAll((key, value) => true);
      } else {
        Provider.of<TimerService>(context, listen: false).stopTimer();
        _timerOverlay?.remove();
        _timerOverlay = null;
      }
    });
  }

  void _startWorkout() {
    if (!isWorkoutStarted) {
      _toggleWorkout();
    }
  }

  @override
  void dispose() {
    _timerOverlay?.remove();
    super.dispose();
  }

  void _removeSetDetail(int exerciseIndex, int setIndex) {
    setState(() {
      exerciseSets[exerciseIndex]!.removeAt(setIndex);
      if (exerciseSets[exerciseIndex]!.isEmpty) {
        // expandedStates[exerciseIndex] = false;
      }
    });
  }

  void _selectExercises() async {
    final List<Exercise> result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LibraryPage(target: widget.target),
      ),
    );
    print(result);
    setState(() {
      for (var exercise in result) {
        if (!selectedExercises.contains(exercise)) {
          selectedExercises.add(exercise);
          int index = selectedExercises.indexOf(exercise);
          exerciseSets[index] = [SetDetail()];
          expandedStates[index] = false;
          getFailedStates[index] = false; // 초기화
        }
      }
      isExerciseSelected = true;
    });
  }

  void _showDeleteSnackbar(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('운동을 삭제하시겠습니까?'),
        action: SnackBarAction(
          label: '삭제',
          onPressed: () {
            _removeExercise(index);
          },
        ),
        duration: Duration(seconds: 5),
      ),
    );
  }

  void _removeExercise(int index) {
    setState(() {
      selectedExercises.removeAt(index);
      exerciseSets.remove(index);
      expandedStates.remove(index);
      getFailedStates.remove(index); // 삭제
      if (selectedExercises.isEmpty) {
        isExerciseSelected = false;
      } else {
        _updateMapsAfterRemoval(index);
      }
    });
  }

  void _updateMapsAfterRemoval(int removedIndex) {
    var newSets = <int, List<SetDetail>>{};
    var newStates = <int, bool>{};
    var newFailedStates = <int, bool>{}; // 추가
    for (int i = 0; i < selectedExercises.length; i++) {
      int oldIndex = i >= removedIndex ? i + 1 : i;
      newSets[i] = exerciseSets[oldIndex]!;
      newStates[i] = expandedStates[oldIndex]!;
      newFailedStates[i] = getFailedStates[oldIndex] ?? false; // 추가
    }

    setState(() {
      exerciseSets = newSets;
      expandedStates = newStates;
      getFailedStates = newFailedStates; // 업데이트
    });
  }

  void _toggleExpanded(int index) {
    setState(() {
      bool isCurrentlyExpanded = expandedStates[index] ?? false;
      if (!isCurrentlyExpanded || (exerciseSets[index]?.isEmpty ?? true)) {
        expandedStates[index] = true;
        exerciseSets[index] ??= [];
        if (exerciseSets[index]!.isEmpty) {
          exerciseSets[index]!.add(SetDetail());
        }
      } else {
        expandedStates[index] = !isCurrentlyExpanded;
      }
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }

      final Exercise item = selectedExercises.removeAt(oldIndex);
      selectedExercises.insert(newIndex, item);

      var newExpandedStates = Map<int, bool>();
      var newExerciseSets = Map<int, List<SetDetail>>();
      var newFailedStates = Map<int, bool>();

      for (int i = 0; i < selectedExercises.length; i++) {
        newExpandedStates[i] = expandedStates[
        oldIndex == i ? newIndex : (newIndex == i ? oldIndex : i)] ??
            false;
        newExerciseSets[i] = exerciseSets[
        oldIndex == i ? newIndex : (newIndex == i ? oldIndex : i)] ??
            [];
        newFailedStates[i] = getFailedStates[
        oldIndex == i ? newIndex : (newIndex == i ? oldIndex : i)] ??
            false; // 추가
      }

      expandedStates = newExpandedStates;
      exerciseSets = newExerciseSets;
      getFailedStates = newFailedStates; // 업데이트
    });
  }

  Future<void> getAll() async {
    try {
      List<String> mainExerciseIds = selectedExercises
          .where((exercise) => exercise.isMain == true)
          .map((exercise) => exercise.exerciseId)
          .toList();

      List<String> subExerciseIds = selectedExercises
          .where((exercise) => exercise.isMain == false)
          .map((exercise) => exercise.exerciseId)
          .toList();

      print('mainExerciseIds: $mainExerciseIds');
      print('subExerciseIds: $subExerciseIds');

      for (String exerciseId in [...mainExerciseIds, ...subExerciseIds]) {
        final response = await http.post(
          Uri.parse('http://52.79.236.191:3000/api/vbt_core/getAll'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'exercise_id': exerciseId,
            'user_id': 00001,
          }),
        );

        print('Response body for $exerciseId: ${response.body}');

        if (response.statusCode == 200) {
          var data = jsonDecode(response.body)['data'];
          if (data.length == 0) {
            int index = selectedExercises
                .indexWhere((exercise) => exercise.exerciseId == exerciseId);
            setState(() {
              getFailedStates[index] = true;
            });
            continue;
          }

          var regressionProvider = Provider.of<RegressionProvider>(context, listen: false);
          String exerciseName = selectedExercises.firstWhere((exercise) => exercise.exerciseId == exerciseId).name;

          var regressionId;
          switch (exerciseName) {
            case 'Bench Press':
              regressionId = regressionProvider.regressionModel.regressionIdBench;
              break;
            case 'Squat':
              regressionId = regressionProvider.regressionModel.regressionIdSquat;
              break;
            case 'Dead Lift':
              regressionId = regressionProvider.regressionModel.regressionIdDL;
              break;
            case 'Over Head Press':
              regressionId = regressionProvider.regressionModel.regressionIdSP;
              break;
          }

          int regressionIdInt = int.parse(regressionId);

          var mostRecentData = data.firstWhere((element) => element['regression_id'] == regressionIdInt, orElse: () => data[0]);
          int index = selectedExercises
              .indexWhere((exercise) => exercise.exerciseId == exerciseId);

          print('가장 최근 regressionId: $regressionIdInt');
          print('가장 최근에 생성된 회귀 데이터: $exerciseId: $mostRecentData');

          setState(() {
            exerciseRegressionData[index] = {
              'slope': mostRecentData['slope'],
              'y_intercept': mostRecentData['y_intercept'],
              'r_squared': mostRecentData['r_squared'],
            };
          });

          // Update the regression ID in the provider
          Provider.of<RDP>(context, listen: false)
              .setTestRegressionId(mostRecentData['regression_id']);
        }
      }
    } catch (e) {
      print('Error fetching regression data: $e');
      for (int index = 0; index < selectedExercises.length; index++) {
        setState(() {
          getFailedStates[index] = true;
        });
      }
    }
  }

  Future<void> createRoutine() async {
    try {
      List<String> mainExerciseIds = selectedExercises
          .where((exercise) => exercise.isMain == true)
          .map((exercise) => exercise.exerciseId)
          .toList();

      List<String> subExerciseIds = selectedExercises
          .where((exercise) => exercise.isMain == false)
          .map((exercise) => exercise.exerciseId)
          .toList();

      int? recentRegressionId =
          Provider.of<RDP>(context, listen: false).testRegressionId;

      final requestBody = jsonEncode(<String, dynamic>{
        'user_id': '00001',
        'target': widget.target,
        'routine_name': 'default',
        'purpose': widget.purpose,
        'recent_regression_id': recentRegressionId,
        'main': mainExerciseIds,
        'sub': subExerciseIds,
        'units': ['1.25', '2.5', '5', '10', '20']
      });

      final response = await http.post(
        Uri.parse('http://52.79.236.191:3000/api/routine/create'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: requestBody,
      );

      print('Request body: $requestBody');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print('Routine creation success: ${data['success']}');
        print('Message: ${data['message']}');
        print('Routine ID: ${data['routine_id']}');
        createdRoutineId = data['routine_id'];

        // 루틴 생성 후 새로운 요청 보내기
        if (data['success'] == true) {
          await fetchRoutineById(data['routine_id']);
        }
      } else {
        print('Failed to create routine');
      }
    } catch (e) {
      print('Error creating routine: $e');
    }
  }

  // 추가된 함수: 루틴 ID로 루틴 정보 요청
  Future<void> fetchRoutineById(int routineId) async {
    try {
      final response = await http.post(
        Uri.parse('http://52.79.236.191:3000/api/routine/get'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'routine_id': routineId, // 예시 recent regression ID
          'user_id': 00001, // 예시 user ID
        }),
      );

      print('Request body: ${jsonEncode(<String, dynamic>{
        'routine_id': routineId,
        'user_id': 00001,
      })}');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print('Routine fetched successfully: ${data['routine']}');
        print('Exercises fetched successfully: ${data['exercises']}');
        updateExerciseSets(data['exercises']);
      } else {
        print('Failed to fetch routine');
      }
    } catch (e) {
      print('Error fetching routine: $e');
    }
  }

  // 추가된 함수: 응답 데이터를 운동 세트에 매칭
  void updateExerciseSets(List<dynamic> exercises) {
    setState(() {
      for (var exercise in exercises) {
        int index = selectedExercises
            .indexWhere((ex) => ex.exerciseId == exercise['exercise_id']);
        if (index != -1) {
          List<SetDetail> sets = [];
          for (int i = 0; i < exercise['sets']; i++) {
            sets.add(SetDetail(
              weight: double.parse(exercise['weights'][i]),
              reps: exercise['reps'] ?? 0,
            ));
          }
          exerciseSets[index] = sets;

          // Set the target_velocity using a Provider
          Provider.of<TargetVelo>(context, listen: false).setTargetVelocity(double.parse(exercise['target_velocity'].toString()));
        }
      }
    });
  }

  // 추가된 함수: 모든 운동 목록을 출력하는 함수
  void _printExercises() {
    selectedExercises.forEach((exercise) {
      print(exercise.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    var workoutData = Provider.of<WorkoutData>(context);
    var routineState = Provider.of<RoutineState>(context);
    var speedValuesProvider = Provider.of<SpeedValuesProvider>(context);
    var updateStatus = Provider.of<IsUpdated>(context);
    // Check if isUpdated is true and call getAll if it is
    if (updateStatus.isUpdated) {
      Future.microtask(() async {
        await getAll();
        updateStatus.setUpdated(false); // Reset isUpdated to false
        if (!isWorkoutStarted) {
          _toggleWorkout(); // Trigger workout action again
        }
        setState(() {
          expandedStates.updateAll((key, value) => true);
        });
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('루틴 페이지'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ReorderableListView.builder(
              itemCount: selectedExercises.length,
              itemBuilder: (context, index) {
                bool isExpanded = expandedStates[index] ?? false;
                ExerciseData? exerciseData =
                workoutData.getData(selectedExercises[index].name);
                List<double>? speedValues = speedValuesProvider
                    .getSpeedValues(selectedExercises[index].name);

                return Container(
                  margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  key: ValueKey(selectedExercises[index]),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(selectedExercises[index].name,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 21)),
                        onTap: () => _toggleExpanded(index),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ReorderableDragStartListener(
                              index: index,
                              child: Icon(Icons.drag_handle),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _showDeleteSnackbar(index),
                            ),
                          ],
                        ),
                      ),
                      if (isExpanded && exerciseSets[index]!.isNotEmpty)
                        Column(
                          children: [
                            if (exerciseData != null)
                              ...exerciseData.sessionCounts
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                return ListTile(
                                  title: Text('${entry.key + 1} 세트'),
                                  subtitle: Text(
                                      '무게: ${exerciseData.weights[entry.key].toStringAsFixed(0)} kg / 횟수: ${entry.value}회'),
                                );
                              }).toList(),
                            ...exerciseSets[index]!.map((setDetail) {
                              List<double> realWeights = getRealWeights(index);
                              return EditRoutine(
                                key: ObjectKey(setDetail),
                                setDetail: setDetail,
                                setIndex:
                                exerciseSets[index]!.indexOf(setDetail) + 1,
                                onUpdate: () => setState(() {}),
                                onDelete: () => _removeSetDetail(index,
                                    exerciseSets[index]!.indexOf(setDetail)),
                                exerciseName: selectedExercises[index].name,
                                exerciseId: selectedExercises[index].exerciseId,
                                onStartWorkout: _startWorkout,
                                weight: setDetail.weight,
                                reps: setDetail.reps,
                                realWeights: realWeights,
                                regressionData: exerciseRegressionData[index],
                              );
                            }).toList(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      exerciseSets[index]!.add(SetDetail());
                                    });
                                  },
                                  child: Text('세트 추가'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    List<double> realWeights =
                                    getRealWeights(index);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => GuidePage(
                                          weight:
                                          exerciseSets[index]!.last.weight,
                                          reps: exerciseSets[index]!.last.reps,
                                          exerciseId: selectedExercises[index]
                                              .exerciseId,
                                          exerciseName:
                                          selectedExercises[index].name,
                                          realWeights: realWeights,
                                          regressionData:
                                          exerciseRegressionData[index],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text('세트 시작'),
                                ),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              },
              onReorder: _onReorder,
            ),
          ),
          isExerciseSelected
              ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _selectExercises,
                child: Text('운동 추가'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (isWorkoutStarted) {
                    workoutDuration =
                        Provider.of<TimerService>(context, listen: false)
                            .seconds;
                    Provider.of<TimerService>(context, listen: false)
                        .stopTimer();

                    Exercise mainExercise = selectedExercises.firstWhere(
                            (exercise) => exercise.isMain,
                        orElse: () => selectedExercises.first);
                    int index = selectedExercises.indexOf(mainExercise);

                    String? regressionId;
                    switch (mainExercise.name) {
                      case 'Bench Press':
                        regressionId = Provider.of<RegressionProvider>(
                            context,
                            listen: false)
                            .regressionModel
                            .regressionIdBench;
                        break;
                      case 'Squat':
                        regressionId = Provider.of<RegressionProvider>(
                            context,
                            listen: false)
                            .regressionModel
                            .regressionIdSquat;
                        break;
                      case 'Dead Lift':
                        regressionId = Provider.of<RegressionProvider>(
                            context,
                            listen: false)
                            .regressionModel
                            .regressionIdDL;
                        break;
                      case 'Over Head Press':
                        regressionId = Provider.of<RegressionProvider>(
                            context,
                            listen: false)
                            .regressionModel
                            .regressionIdSP;
                        break;
                    }
                    List<Map<String, dynamic>> exerciseData =
                    List.generate(
                        exerciseSets[index]!.length,
                            (i) => {
                          'weight':
                          exerciseSets[index]![i].weight,
                          'mean_velocity':
                          speedValuesProvider.getSpeedValues(
                              mainExercise.name)?[i],
                        });

                    Map<String, dynamic> reviewData = {
                      'user_id': '00001',
                      'test_regression_id': regressionId,
                      'exercise_id': mainExercise.exerciseId,
                      'name': mainExercise.name,
                      'data': exerciseData,
                      'routine_id': createdRoutineId,
                    };

                    print('Sending data to ReviewPage: $reviewData');

                    Navigator.of(context)
                        .pushReplacement(MaterialPageRoute(
                      builder: (context) => ReviewPage(
                        workoutDuration: workoutDuration,
                        workoutData: workoutData,
                        compareData: reviewData,
                      ),
                    ));
                  } else {
                    await getAll();
                    await createRoutine(); // 루틴 생성 함수 호출
                    _toggleWorkout();
                  }
                },
                child: Text(isWorkoutStarted ? '운동 완료' : '운동 시작'),
              ),
              ElevatedButton(
                onPressed: _printExercises,
                child: Text('운동 목록 출력'),
              ),
            ],
          )
              : ElevatedButton(
            onPressed: _selectExercises,
            child: Text('운동 선택'),
          ),
        ],
      ),
    );
  }

  Future<String> fetchRoutineData() async {
    try {
      final response = await http.post(
        Uri.parse('http://52.79.236.191:3000/api/routine/getForm'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode(<String, String>{
          'target': widget.target,
        }),
      );
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to load routine data');
      }
    } catch (e) {
      return Future.error('Failed to load routine data: $e');
    }
  }
}
