import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:weight_charts/charts/chart_holder.dart';

import '../models/date_range.dart';
import '../models/measurement/measurement.dart';

class CaloriesConsumedChart extends StatelessWidget {
  final double maxWidth;
  final double maxHeight;
  final Stream<QuerySnapshot<Map<String, dynamic>>> stream;
  final Color color;
  final Color dotColor;
  final DateRange selectedDateRange;
  final Function(String?, Chart?) onExpand;
  final bool popup;
  final bool showExpand;

  const CaloriesConsumedChart({
    Key? key,
    required this.stream,
    required this.color,
    required this.dotColor,
    required this.selectedDateRange,
    required this.onExpand,
    required this.maxWidth,
    this.maxHeight = 200,
    this.popup = false, this.showExpand = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChartHolder(
      type: Chart.calories,

      title: 'Calories Consumed',
      chart: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: stream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Measurement> allMeasurements = snapshot.data?.docs.map((e) => Measurement.fromJson(e.data())).toList() ?? [];
              List<Measurement> rawMeasurements = allMeasurements
                  .where((measurement) =>
                      (measurement.dateTime != null && measurement.dateTime!.isAfter(DateTime.now().subtract(selectedDateRange.duration))))
                  .toList();

              // if (rawMeasurements.isNotEmpty) {
              List<FlSpot> spots = [];
              double mostCalories = 0;

              for (Measurement measurement in rawMeasurements) {
                if (measurement.offered != null) {
                  double eaten = (measurement.offered! - (measurement.notEaten ?? 0));
                  double treats = ((measurement.treats ?? 0) * 1);
                  double calories = (eaten * 3.237) + (treats * 8.5);

                  spots.add(
                    FlSpot(
                      measurement.dateTime!.difference(DateTime.now()).inDays.toDouble(),
                      calories,
                    ),
                  );

                  if (calories > (mostCalories)) mostCalories = calories;
                }
              }

              if(spots.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(right: 24.0),
                  child: LineChart(
                    LineChartData(
                        minY: 0,
                        minX: -selectedDateRange.duration.inDays.toDouble(),
                        maxY: mostCalories + 5,
                        maxX: 0,
                        lineTouchData: LineTouchData(),
                        borderData: FlBorderData(
                          border: const Border(
                            left: BorderSide(
                              width: 1,
                              color: Colors.black54,
                            ),
                            bottom: BorderSide(
                              width: 1,
                              color: Colors.black54,
                            ),
                          ),
                          show: true,
                        ),
                        titlesData: FlTitlesData(
                            rightTitles: SideTitles(showTitles: false),
                            topTitles: SideTitles(showTitles: false),
                            leftTitles: SideTitles(
                              interval: (mostCalories / 6) == 0 ? 1 : (mostCalories / 6),
                              showTitles: true,
                              reservedSize: 24,
                              getTextStyles: (context, value) {
                                return const TextStyle(fontSize: 10);
                              },
                              getTitles: (value) {
                                return value.toStringAsFixed(0);
                              },
                            ),
                            bottomTitles: SideTitles(
                              reservedSize: 0,
                              showTitles: true,
                              getTextStyles: (context, value) {
                                return const TextStyle(fontSize: 10);
                              },
                              rotateAngle: 0,
                              interval: selectedDateRange.verticalInterval,
                              getTitles: (value) {
                                return MaterialLocalizations.of(context).formatShortMonthDay(DateTime.now().add(Duration(days: value.toInt())));
                              },
                            )),
                        gridData: FlGridData(
                          drawHorizontalLine: true,
                          horizontalInterval: (mostCalories / 6) == 0 ? 1 : (mostCalories / 6),
                          verticalInterval: selectedDateRange.verticalInterval,
                          drawVerticalLine: true,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(strokeWidth: .2);
                          },
                          getDrawingVerticalLine: (value) {
                            return FlLine(strokeWidth: .2);
                          },
                          checkToShowHorizontalLine: (value) {
                            return true;
                          },
                        ),
                        lineBarsData: [
                          getReferenceLine(startX: -selectedDateRange.duration.inDays.toDouble(), endX: 0, color: Colors.transparent, y: 0),
                          if (spots.length > 1)
                            LineChartBarData(
                                spots: spots,
                                barWidth: 1,
                                colors: [dotColor],
                                dotData: FlDotData(
                                  getDotPainter: (spot, value, barData, index) {
                                    return FlDotCirclePainter(
                                      color: dotColor,
                                      strokeWidth: 0,
                                      radius: 3,
                                      strokeColor: dotColor,
                                    );
                                  },
                                )),
                        ]),
                    swapAnimationDuration: const Duration(milliseconds: 150), // Optional
                    swapAnimationCurve: Curves.linear, // Optional
                  ),
                );
              } else{
                return Container();
              }
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      color: color,
      popup: popup,
      showExpand: showExpand,
      onExpand: (title, chart) => onExpand(title, chart),
    );
  }
}
