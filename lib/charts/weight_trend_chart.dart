import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:weight_charts/charts/chart_holder.dart';
import 'package:weight_charts/models/date_range.dart';
import 'package:weight_charts/models/json_utilities.dart';
import 'package:weight_charts/models/measurement/measurement.dart';

class WeightTrendChart extends StatelessWidget {
  final double maxWidth;
  final double maxHeight;
  double? targetWeight;
  final bool metric;
  final Color color;
  final Color dotColor;
  final DateRange selectedDateRange;
  final Stream<QuerySnapshot<Map<String, dynamic>>> stream;
  final Function(String?, Chart?) onExpand;
  final bool popup;
  final bool showExpand;

  WeightTrendChart({
    Key? key,
    required this.targetWeight,
    required this.stream,
    required this.metric,
    required this.color,
    required this.selectedDateRange,
    required this.dotColor,
    required this.onExpand,
    required this.maxWidth,
    this.maxHeight = 200,
    this.popup = false,
    this.showExpand = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    targetWeight = metric ? (targetWeight ?? 0) : (targetWeight ?? 0) *2.205;
    return ChartHolder(
      type: Chart.weight,
      popup: popup,
      showExpand: showExpand,
      title: 'Home Weight Trend (${metric ? 'kg' : 'lbs'})',
      maxWidth: maxWidth,
      maxHeight: maxHeight,
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
              List<DateTime> dates = [];
              double? largestWeight;
              double? smallestWeight;

              for (Measurement measurement in rawMeasurements) {
                if (measurement.weight != null && measurement.dateTime != null) {
                  double weight = double.parse((measurement.weight! * (metric ? 1 : 2.205)).toStringAsFixed(2));
                  spots.add(
                    FlSpot(
                      measurement.dateTime!.difference(DateTime.now()).inDays.toDouble(),
                      weight,
                    ),
                  );

                  DateTime dateWithoutTime = DateTime(measurement.dateTime!.year, measurement.dateTime!.month, measurement.dateTime!.day);
                  if (!dates.contains(dateWithoutTime)) {
                    dates.add(DateTime(measurement.dateTime!.year, measurement.dateTime!.month, measurement.dateTime!.day));
                  }

                  if (weight > (largestWeight ?? 0)) largestWeight = weight;
                  if (weight < (smallestWeight ?? 900)) smallestWeight = weight;
                }
              }
              bool losingWeight = targetWeight! < (smallestWeight ?? 5);
              debugPrint('smallestWeight: ' + smallestWeight.toString());
              debugPrint('targetWeight: ' + targetWeight.toString());

              if(smallestWeight != null || largestWeight != null) {
                return Padding(
                  padding: const EdgeInsets.only(right: 24.0),
                  child: LineChart(
                    LineChartData(
                        minY: (targetWeight != null && losingWeight) // Losing weight
                            ? targetWeight!-1//(((targetWeight!) * .25).roundToDouble() / .25) - 2
                            : ((((smallestWeight ?? 5)) * .25).roundToDouble() / .25) - 1.5,
                        minX: -selectedDateRange.duration.inDays.toDouble(),
                        maxX: 0,
                        maxY: (targetWeight != null && targetWeight! > (largestWeight ?? 0 + 5))
                            ? targetWeight! + 1
                            : (largestWeight ?? 0) + 1,
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
                              showTitles: true,
                              reservedSize: 24,
                              interval: .5,
                              getTextStyles: (context, value) {
                                return const TextStyle(fontSize: 10);
                              },
                              getTitles: (value) {
                                return value.toStringAsFixed(2);
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
                          horizontalInterval: .25,
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
                          getReferenceLine(startX: -selectedDateRange.duration.inDays.toDouble(), endX: 0, color: Colors.transparent, y: 1),
                          if (spots.isNotEmpty)
                            LineChartBarData(
                                spots: spots,
                                barWidth: 1,
                                colors: [Colors.black54],
                                dotData: FlDotData(
                                  getDotPainter: (spot, value, barData, index) {
                                    return FlDotCirclePainter(
                                      color: dotColor,
                                      strokeWidth: 0,
                                      radius: 4,
                                      strokeColor: dotColor,
                                    );
                                  },
                                )),
                          if (targetWeight != null)
                            LineChartBarData(
                              spots: [
                                FlSpot(-selectedDateRange.duration.inDays.toDouble(), targetWeight!),
                                FlSpot(0, targetWeight!),
                              ],
                              barWidth: 2,
                              dashArray: [10, 4],
                              colors: [Colors.green],
                              dotData: FlDotData(show: false),
                            ),
                        ]),
                    swapAnimationDuration: const Duration(milliseconds: 150), // Optional
                    swapAnimationCurve: Curves.linear, // Optional
                  ),
                );
              } else{
                return Center(
                  child: Text('No data'),
                );
              }
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
      color: color,
      onExpand: (title, chart) => onExpand(title, chart),
    );
  }
}
