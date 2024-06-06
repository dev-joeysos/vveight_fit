import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../provider/isUpdated.dart';
import '../../provider/speed_values.dart';

class TestingResult extends StatefulWidget {
  final int setNumber;
  final String exerciseId;
  final String exerciseName;
  final int setTime;
  final List<double> realWeights;
  final List<double> speedValues;
  final double rSquared;
  final double slope;
  final double yIntercept;
  final double oneRM;
  final Map<String, dynamic>? rData;
  final int restPeriod;

  TestingResult({
    super.key,
    required this.setNumber,
    required this.exerciseId,
    required this.exerciseName,
    required this.setTime,
    required this.realWeights,
    required this.speedValues,
    required this.rSquared,
    required this.slope,
    required this.yIntercept,
    required this.oneRM,
    this.rData,
    required this.restPeriod,
  });

  @override
  State<TestingResult> createState() => _TestingResultState();
}

class _TestingResultState extends State<TestingResult> {
  bool _providerUpdated = false;
  late int _remainingRestTime;
  Timer? _timer;
  bool _showRestTimer = false;

  @override
  void initState() {
    super.initState();
    _remainingRestTime = widget.restPeriod;
    if (_remainingRestTime > 0) {
      _showRestTimer = true;
      _startRestTimer();
    }
  }

  void _startRestTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingRestTime > 0) {
          _remainingRestTime--;
        } else {
          _timer?.cancel();
          _showRestTimer = false;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_providerUpdated && widget.rData != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<SpeedValuesProvider>(context, listen: false)
            .updateSpeedValues(widget.exerciseName, widget.speedValues);
      });
      _providerUpdated = true;
    }
  }

  List<FlSpot> _getLinearLinePoints(double slope, double yIntercept) {
    List<FlSpot> linePoints = [];
    for (int i = 0; i < widget.realWeights.length; i++) {
      double x = widget.realWeights[i].toDouble();
      double y = slope * x + yIntercept;
      linePoints.add(FlSpot(x, y));
    }
    return linePoints;
  }

  Future<void> _saveRegressionData(BuildContext context) async {
    const url = 'http://52.79.236.191:3000/api/vbt_core/save';
    final body = {
      'user_id': '00001',
      'exercise_id': widget.exerciseId,
      'name': widget.exerciseName,
      'regression': {
        'one_rep_max': widget.oneRM.toString(),
        'r_squared': widget.rData?['r_squared']?.toString() ?? widget.rSquared.toString(),
        'slope': widget.rData?['slope']?.toString() ?? widget.slope.toString(),
        'y_intercept': widget.rData?['y_intercept']?.toString() ?? widget.yIntercept.toString(),
        'type': 'workout'
      }
    };

    print('Saving regression data: $body');
    print('Real weights: ${widget.realWeights}');
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final regressionId = responseData['regression_id'];
        print('Saved regression data with ID: $regressionId');
        Provider.of<IsUpdated>(context, listen: false).setUpdated(true);
        Navigator.of(context).pop({
          'exerciseName': widget.exerciseName,
          'regressionId': regressionId
        });
      } else {
        print('Failed to save regression data: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error saving regression data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<FlSpot> linearLinePoints =
    _getLinearLinePoints(widget.slope, widget.yIntercept);
    List<FlSpot>? rDataLinePoints;
    if (widget.rData != null) {
      rDataLinePoints = _getLinearLinePoints(
          double.parse(widget.rData?['slope'].toString() ?? '0.0'),
          double.parse(widget.rData?['y_intercept'].toString() ?? '0.0'));
    }
    bool hasRegressionData =
        widget.rSquared != 0 || widget.slope != 0 || widget.yIntercept != 0;
    bool hasRData = widget.rData != null;

    double currentRSquared = hasRData
        ? double.parse(widget.rData?['r_squared'].toString() ?? '0.0')
        : widget.rSquared;
    double currentSlope = hasRData
        ? double.parse(widget.rData?['slope'].toString() ?? '0.0')
        : widget.slope;
    double currentYIntercept = hasRData
        ? double.parse(widget.rData?['y_intercept'].toString() ?? '0.0')
        : widget.yIntercept;

    return Scaffold(
      appBar: AppBar(
        title: Text("Testing Result"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                hasRegressionData
                    ? '측정 결과'
                    : '${widget.exerciseName} - 세트 ${widget.setNumber} 결과',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                '측정 시간: ${widget.setTime}초',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              Text(
                '펑균 속도: ${widget.speedValues.last.toStringAsFixed(2)} m/s',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
              SizedBox(height: 10),
              if (hasRegressionData) ...[
                Text(
                  '편차: ${currentRSquared.toStringAsFixed(5)}',
                  style: TextStyle(fontSize: 18, color: Colors.blue),
                ),
                Text(
                  '기울기: ${currentSlope.toStringAsFixed(5)}',
                  style: TextStyle(fontSize: 18, color: Colors.blue),
                ),
                Text(
                  'y 절편: ${currentYIntercept.toStringAsFixed(5)}',
                  style: TextStyle(fontSize: 18, color: Colors.blue),
                ),
                SizedBox(height: 20),
              ],
              SizedBox(
                height: 360,
                child: Stack(
                  children: [
                    ScatterChart(
                      ScatterChartData(
                        scatterSpots: [
                          for (int i = 0; i < widget.speedValues.length; i++)
                            ScatterSpot(
                              widget.realWeights[i].toDouble(),
                              widget.speedValues[i],
                              dotPainter: FlDotCirclePainter(
                                radius: 8,
                                color: Color(0xff6BBEE2),
                              ),
                            ),
                        ],
                        minX: (widget.realWeights
                            .reduce((a, b) => a < b ? a : b) -
                            10)
                            .toDouble(),
                        maxX: (widget.realWeights
                            .reduce((a, b) => a > b ? a : b) +
                            10)
                            .toDouble(),
                        minY: 0,
                        maxY: (widget.speedValues
                            .reduce((a, b) => a > b ? a : b) +
                            0.4),
                        backgroundColor: Colors.white,
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          drawHorizontalLine: true,
                          verticalInterval: 10,
                          horizontalInterval: 0.2,
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 0.2,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 10,
                              getTitlesWidget: (value, meta) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    '${value.toInt()}kg',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    if (hasRegressionData)
                      LineChart(
                        LineChartData(
                          lineBarsData: [
                            LineChartBarData(
                              spots: linearLinePoints,
                              isCurved: false,
                              color: Color(0xff143365),
                              barWidth: 5,
                              dotData: FlDotData(show: false),
                            ),
                            if (rDataLinePoints != null)
                              LineChartBarData(
                                spots: rDataLinePoints,
                                isCurved: false,
                                color: Color(0xff6BBEE2),
                                barWidth: 5,
                                dotData: FlDotData(show: false),
                                dashArray: [9, 6],
                              ),
                          ],
                          minX: (widget.realWeights
                              .reduce((a, b) => a < b ? a : b) -
                              10)
                              .toDouble(),
                          maxX: (widget.realWeights
                              .reduce((a, b) => a > b ? a : b) +
                              10)
                              .toDouble(),
                          minY: 0,
                          maxY: (widget.speedValues
                              .reduce((a, b) => a > b ? a : b) +
                              0.4),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            drawHorizontalLine: true,
                            verticalInterval: 10,
                            horizontalInterval: 0.2,
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 0.2,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toStringAsFixed(1),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 10,
                                getTitlesWidget: (value, meta) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      '${value.toInt()}kg',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (_showRestTimer) ...[
                SizedBox(height: 20),
                Text(
                  'Rest Time: $_remainingRestTime seconds',
                  style: TextStyle(fontSize: 18, color: Colors.green),
                ),
                Text(
                  '창닫기를 누르면 휴식이 중단됩니다.',
                  style: TextStyle(fontSize: 18, color: Colors.green),
                ),
              ],
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (hasRData) {
                    _saveRegressionData(context);
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                child: Text(hasRData ? '저장하기' : '창닫기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

