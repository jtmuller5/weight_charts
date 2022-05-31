import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:weight_charts/models/date_range.dart';
import 'package:weight_charts/models/json_utilities.dart';
import 'package:weight_charts/models/measurement/measurement.dart';

import 'chart_holder.dart';

class AverageWeeklyWeightLossChart extends StatelessWidget {
  final double sideLength;
  final Stream<QuerySnapshot<Map<String, dynamic>>> stream;
  final Color color;
  final Color dotColor;
  final double? currentWeight;
  final DateRange selectedDateRange;
  final Function(String, Chart) onExpand;

  const AverageWeeklyWeightLossChart({
    Key? key,
    required this.sideLength,
    required this.stream,
    required this.color,
    required this.dotColor,
    required this.selectedDateRange,
    required this.currentWeight,
    required this.onExpand,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChartHolder(
      title: 'Average Weekly Weight Loss %',
      chart: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: stream,
          builder: (context, snapshot) {
            debugPrint('snapshot: ${snapshot.connectionState}');
            if (snapshot.hasData) {
              List<Measurement> allMeasurements = snapshot.data?.docs.map((e) => Measurement.fromJson(e.data())).toList() ?? [];
              List<Measurement> rawMeasurements = allMeasurements
                  .where((measurement) =>
                      (measurement.dateTime != null && measurement.dateTime!.isAfter(DateTime.now().subtract(selectedDateRange.duration))))
                  .toList();

              // if (rawMeasurements.isNotEmpty) {
              List<FlSpot> spots = [];
              List<DateTime> dates = [];
              Map<DateTime, Measurement?> measurements = {};

              int totalDaysBeingMeasured = selectedDateRange.duration.inDays * 2;

              /// 0 - Create list of all visible days
              for (int i = 0; i < totalDaysBeingMeasured; i++) {
                measurements.addEntries(List.generate(totalDaysBeingMeasured,
                    (index) => MapEntry(getDateWithoutTime(DateTime.now().subtract(Duration(days: totalDaysBeingMeasured - index))), null)));
              }

              for (Measurement measurement in (rawMeasurements)) {
                /// 1 - Add all weight measurements to map
                if (measurement.weight != null) {
                  measurements[getDateWithoutTime(measurement.dateTime!)] = measurement;

                  DateTime dateWithoutTime = getDateWithoutTime(measurement.dateTime!);
                  if (!dates.contains(dateWithoutTime)) {
                    dates.add(getDateWithoutTime(measurement.dateTime!));
                  }
                }
              }

              /// 2 - Calculate AWWL for each day
              double rollingWeight = currentWeight ?? 0;
              List<Measurement?> reversedMeasurements = measurements.entries.toList().reversed.map((e) => e.value).toList();

              /// 2.a - cycle through all days in reverse order (current -> past)
              reversedMeasurements.forEachIndexed((index, element) {
                try {
                  DateTime measurementDate = element?.dateTime ?? measurements.keys.toList()[index];

                  if (element != null) rollingWeight = element.weight!;

                  Measurement? differenceMeasurement;

                  for (int sub = 14; sub > 1; sub--) {
                    int adjustedIndex = index + sub;

                    if (adjustedIndex <= reversedMeasurements.length - 1) {
                      Measurement? testMeasurement = reversedMeasurements[adjustedIndex];

                      if (testMeasurement != null) {
                        differenceMeasurement = testMeasurement;
                        break;
                      }
                    }
                  }

                  if (differenceMeasurement != null) {
                    double weightDifference = differenceMeasurement.weight! - rollingWeight;
                    int dayDifference = differenceMeasurement.dateTime!.difference(measurementDate).inDays;

                    double perDayWeightLoss = weightDifference / dayDifference;
                    double weeklyWeightLoss = perDayWeightLoss * 7;
                    double percentWeeklyWeightLoss = weeklyWeightLoss / rollingWeight;

                    double awwl = double.parse((percentWeeklyWeightLoss * -100).toStringAsFixed(2));

                    double diff = measurementDate.difference(DateTime.now()).inDays.toDouble();
                    if (diff < 0 && diff > totalDaysBeingMeasured / -2) {
                      if (awwl > -2 && awwl < 4) {
                        spots.add(
                          FlSpot(
                            diff,
                            awwl,
                          ),
                        );
                      }
                    }
                  }

                  index++;
                } catch (e) {
                  debugPrint('Error with awwl: $e');
                }
              });

              spots.sort((a, b) => a.x.compareTo(b.x));
              return Padding(
                padding: const EdgeInsets.only(right: 24.0),
                child: LineChart(
                  LineChartData(
                      minY: -2,
                      minX: -selectedDateRange.duration.inDays.toDouble(),
                      maxY: 4,
                      maxX: 0,
                      lineTouchData: LineTouchData(
                          getTouchedSpotIndicator: (barData, spotIndexes) {
                            return [
                              TouchedSpotIndicatorData(FlLine(color: Colors.black), FlDotData(
                                getDotPainter: (p0, p1, p2, p3) {
                                  return FlDotCirclePainter(
                                    radius: 5,
                                    color: getDotColor(p0.y),
                                  );
                                },
                              ))
                            ];
                          },
                          touchTooltipData: LineTouchTooltipData(
                            tooltipBgColor: color,
                            getTooltipItems: (barSpots) {
                              return barSpots
                                  .map((e) => LineTooltipItem(
                                        e.y.toStringAsFixed(2),
                                        Theme.of(context).textTheme.subtitle1!,
                                      ))
                                  .toList();
                            },
                          )),
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
                            interval: 1,
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
                        getReferenceLine(
                          startX: -selectedDateRange.duration.inDays.toDouble(),
                          endX: 0,
                          color: Colors.brown,
                          y: 3,
                        ),
                        getReferenceLine(
                          startX: -selectedDateRange.duration.inDays.toDouble(),
                          endX: 0,
                          color: Colors.red,
                          y: 2,
                        ),
                        getReferenceLine(
                          startX: -selectedDateRange.duration.inDays.toDouble(),
                          endX: 0,
                          color: Colors.orange,
                          y: 1.5,
                        ),
                        getReferenceLine(startX: -selectedDateRange.duration.inDays.toDouble(), endX: 0, color: Colors.green, y: 1),
                        getReferenceLine(startX: -selectedDateRange.duration.inDays.toDouble(), endX: 0, color: Colors.orange, y: .5),
                        getReferenceLine(
                          startX: -selectedDateRange.duration.inDays.toDouble(),
                          endX: 0,
                          color: Colors.yellow,
                          y: 0,
                        ),
                        LineChartBarData(
                          spots: spots,
                          barWidth: 1,
                          colors: [Colors.black26],
                          dotData: FlDotData(
                            getDotPainter: (spot, value, barData, index) {
                              return FlDotCirclePainter(
                                color: getDotColor(spot.y),
                                strokeWidth: 0,
                                radius: 3,
                                strokeColor: getDotColor(spot.y),
                              );
                            },
                          ),
                        ),
                      ]),
                  swapAnimationDuration: const Duration(milliseconds: 150), // Optional
                  swapAnimationCurve: Curves.linear, // Optional
                ),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
      sideLength: sideLength,
      color: color,
      onExpand: (title, chart) => onExpand(title,chart),
    );
  }
}
