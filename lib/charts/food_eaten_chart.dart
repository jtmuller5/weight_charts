import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:weight_charts/charts/chart_holder.dart';
import 'package:weight_charts/models/date_range.dart';

import '../models/measurement/measurement.dart';

class FoodEatenChart extends StatelessWidget {
  final double maxWidth;
  final double? maxHeight;
  final Stream<QuerySnapshot<Map<String, dynamic>>> stream;
  final Color color;
  final Color dotColor;
  final DateRange selectedDateRange;
  final Function(String?, Chart?) onExpand;
  final bool popup;
  final bool showExpand;
  final bool metric;

  const FoodEatenChart({
    Key? key,
    required this.stream,
    required this.color,
    required this.dotColor,
    required this.selectedDateRange,
    required this.onExpand,
    required this.maxWidth,
    this.maxHeight = 200,
    this.popup = false,
    this.showExpand = true,
    required this.metric,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChartHolder(
      type: Chart.food,
      showExpand: showExpand,
      popup: popup,
      title: 'Food Eaten (g)/Treats Fed (g)',
      //'Food Eaten (${model.metric ? 'g' : 'lbs'})/Treats Fed (${model.metric ? 'g' : 'lbs'})',
      chart: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: stream,
          builder: (context, snapshot) {
            double maxFood = 0;

            if (snapshot.hasData) {
              List<Measurement> allMeasurements = snapshot.data?.docs.map((e) => Measurement.fromJson(e.data())).toList() ?? [];
              List<Measurement> rawMeasurements = allMeasurements
                  .where((measurement) =>
                      (measurement.dateTime != null && measurement.dateTime!.isAfter(DateTime.now().subtract(selectedDateRange.duration))))
                  .toList();
              Map<int, BarChartGroupData> bars = {
                for (var element in List.generate(
                  selectedDateRange.duration.inDays,
                  (index) => index,
                ))
                  element: BarChartGroupData(
                    x: element,
                    barRods: [
                      BarChartRodData(
                        y: 0,
                      )
                    ],
                  )
              };

              for (Measurement measurement in (rawMeasurements)) {
                if (measurement.offered != null && measurement.dateTime != null) {
                  double eaten = (measurement.offered! - (measurement.notEaten ?? 0)) / (metric ? 1 : 454);
                  double treats = (measurement.treats ?? 0) / (metric ? 1 : 454);

                  if(eaten != 0) {
                    bars[selectedDateRange.duration.inDays + measurement.dateTime!.difference(DateTime.now()).inDays] = BarChartGroupData(
                      x: selectedDateRange.duration.inDays + measurement.dateTime!.difference(DateTime.now()).inDays,
                      barRods: [
                        BarChartRodData(
                          y: eaten + treats,
                          rodStackItems: [
                            BarChartRodStackItem(0, eaten, color),
                            if (measurement.treats != null) BarChartRodStackItem(eaten, eaten + treats, Colors.redAccent),
                          ],
                        )
                      ],
                    );
                  }
                }
              }
              return Padding(
                  padding: const EdgeInsets.only(right: 28.0),
                  child: BarChart(
                    BarChartData(
                      gridData: FlGridData(drawVerticalLine: true),
                      barGroups: bars.values.toList(),
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
                            getTextStyles: (context, value) {
                              return const TextStyle(fontSize: 10);
                            },
                            getTitles: (value) {
                              return value.toStringAsFixed(metric ? 0 : 2);
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
                              return MaterialLocalizations.of(context).formatShortMonthDay(
                                DateTime.now().subtract(Duration(days: selectedDateRange.duration.inDays - value.toInt())),
                              );
                            },
                          )),
                    ),
                    swapAnimationDuration: const Duration(milliseconds: 150), // Optional
                    swapAnimationCurve: Curves.linear, // Optional
                  ));
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      color: color,
      onExpand: (title, chart) => onExpand(title, chart),
    );
  }
}
