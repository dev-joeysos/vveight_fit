// line_chart_widget.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class LineChartWidget extends StatelessWidget {
  final Map<String, dynamic> regressionData;
  final List<double> realWeights;
  final List<double> speedValues;

  LineChartWidget({
    required this.regressionData,
    required this.realWeights,
    required this.speedValues,
  });

  List<FlSpot> _getLineSpots(double slope, double yIntercept) {
    List<FlSpot> spots = [];
    for (int i = 50; i <= 100; i += 5) {
      double x = i.toDouble();
      double y = slope * x + yIntercept;
      spots.add(FlSpot(x, y));
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    double slope = double.parse(regressionData['slope'].toString());
    double yIntercept = double.parse(regressionData['y_intercept'].toString());

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 1.0,
        lineBarsData: [
          LineChartBarData(
            spots: _getLineSpots(slope, yIntercept),
            isCurved: false,
            color: Color(0xff143365),
            barWidth: 5,
            isStrokeCapRound: false,
            belowBarData: BarAreaData(show: false),
            dotData: FlDotData(show: false),
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 0.2,
              getTitlesWidget: (value, meta) {
                if (value == 0) {
                  return Container(); // Hide the left bottom 0.0 value
                }
                return Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Text(
                    value.toStringAsFixed(1),
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    '${value.toInt()}kg',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
        ),
        gridData: FlGridData(
          show: true,
          horizontalInterval: 0.2,
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(
          show: false, // Hide the border around the chart
        ),
      ),
    );
  }
}
