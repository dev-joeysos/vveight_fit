import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_project/components/styled_button.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

import '../../components/long_button.dart';
import '../../components/styled_container.dart';
import '../../provider/regression_provider.dart';

class SetResultPage extends StatelessWidget {
  final int setNumber;
  final String exerciseId;
  final String exerciseName;
  final int setTime;
  final List<double> testWeights;
  final List<double> speedValues;
  final double rSquared;
  final double slope;
  final double yIntercept;
  final double oneRM;

  SetResultPage({
    Key? key,
    required this.setNumber,
    required this.exerciseId,
    required this.exerciseName,
    required this.setTime,
    required this.testWeights,
    required this.speedValues,
    required this.rSquared,
    required this.slope,
    required this.yIntercept,
    required this.oneRM,
  }) : super(key: key);

  List<FlSpot> _getLinearLinePoints() {
    List<FlSpot> linePoints = [];
    for (int i = 0; i < testWeights.length; i++) {
      double x = testWeights[i].toDouble();
      double y = slope * x + yIntercept;
      linePoints.add(FlSpot(x, y));
    }
    return linePoints;
  }

  void _printBody(BuildContext context) {
    final body = {
      'user_id': '00001',
      'exercise_id': exerciseId,
      'name': exerciseName,
      'regression': {
        'r_squared': rSquared,
        'slope': slope,
        'y_intercept': yIntercept,
        'type': 'Test',
        'one_rep_max': oneRM,
      },
    };
    print('Request body: ${json.encode(body)}');
  }

  Future<void> _saveRegressionData(BuildContext context) async {
    const url = 'http://52.79.236.191:3000/api/vbt_core/save';
    final body = {
      'user_id': '00001',
      'exercise_id': exerciseId,
      'name': exerciseName,
      'regression': {
        'r_squared': rSquared,
        'slope': slope,
        'y_intercept': yIntercept,
        'type': 'Test',
        'one_rep_max': oneRM,
      },
    };

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

        // Update the RegressionProvider with the new regressionId based on exerciseName
        Provider.of<RegressionProvider>(context, listen: false)
            .updateRegressionId(exerciseName, regressionId);

        Navigator.of(context).pop({'exerciseName': exerciseName, 'regressionId': regressionId});
      } else {
        print('Failed to save regression data: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error saving regression data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<FlSpot> linearLinePoints = _getLinearLinePoints();
    bool hasRegressionData = rSquared != 0 || slope != 0 || yIntercept != 0;

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                hasRegressionData ? '측정 결과' : '$setNumber세트 결과',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  StyledContainer(
                    text: '${exerciseName}',
                  ),
                  SizedBox(height: 20),
                  StyledContainer(
                    text: '측정 시간: ${setTime}초',
                  ),
                ],
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey),
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '평균 속도',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      '${testWeights.last}kg-${speedValues.last.toStringAsFixed(2)}m/s',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 18),
                    AspectRatio(
                      aspectRatio: 1.5,
                      child: Stack(
                        children: [
                          ScatterChart(
                            ScatterChartData(
                              scatterSpots: [
                                for (int i = 0; i < speedValues.length; i++)
                                  ScatterSpot(
                                    testWeights[i].toDouble(),
                                    speedValues[i],
                                    dotPainter: FlDotCirclePainter(
                                      radius: 6,
                                      color: Color(0xff143365),
                                    ),
                                  ),
                              ],
                              minX: (testWeights.reduce((a, b) => a < b ? a : b) - 10).toDouble(),
                              maxX: (testWeights.reduce((a, b) => a > b ? a : b) + 10).toDouble(),
                              minY: 0,
                              maxY: (speedValues.reduce((a, b) => a > b ? a : b) + 0.4),
                              backgroundColor: Colors.white,
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                drawHorizontalLine: true,
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
                                ],
                                minX: (testWeights.reduce((a, b) => a < b ? a : b) - 10).toDouble(),
                                maxX: (testWeights.reduce((a, b) => a > b ? a : b) + 10).toDouble(),
                                minY: 0,
                                maxY: (speedValues.reduce((a, b) => a > b ? a : b) + 0.4),
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  drawHorizontalLine: true,
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
                  ],
                ),
              ),
              SizedBox(height: 30),
              LongButton(
                onPressed: () {
                  if (hasRegressionData) {
                    _saveRegressionData(context);
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                text: hasRegressionData ? '저장하기' : '창닫기',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
