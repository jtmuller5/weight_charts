import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ChartHolder extends StatelessWidget {
  const ChartHolder({
    Key? key,
    required this.title,
    required this.chart,
    required this.maxWidth,
    required this.color,
    required this.onExpand,
    required this.type,
    this.maxHeight = 200,
    this.popup = false,
    this.showExpand = true,
  }) : super(key: key);

  final String title;
  final Widget chart;
  final double maxWidth;
  final double? maxHeight;
  final Color color;
  final Function(String?, Chart?) onExpand;
  final Chart type;
  final bool popup;
  final bool showExpand;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              child: Stack(
                children: [
                  ColoredBox(
                      color: color,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                title,
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                            ),
                          ),
                        ],
                      )),
                  if(showExpand)Positioned(
                    right: 16,
                    top: 0,
                    child: popup
                        ? CloseButton(
                            onPressed: () {
                              onExpand(null, null);
                            },
                          )
                        : IconButton(
                            iconSize: 16,
                            constraints: const BoxConstraints(maxHeight: 24, maxWidth: 24),
                            onPressed: () {
                              onExpand(title, type);
                            },
                            icon: const Icon(Icons.open_in_full),
                          ),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: maxHeight ?? 200,
                maxWidth: maxWidth,
              ),
              child: chart,
            ),
          ),
        ],
      ),
    );
  }
}

LineChartBarData getReferenceLine({
  required double startX,
  required double endX,
  required Color color,
  required double y,
}) {
  return LineChartBarData(
    spots: [
      FlSpot(startX, y),
      FlSpot(endX, y),
    ],
    barWidth: 1,
    dashArray: [10, 4],
    colors: [color],
    dotData: FlDotData(show: false),
  );
}

enum Chart { awwl, weight, calories, food }
