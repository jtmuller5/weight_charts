import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ChartHolder extends StatelessWidget {
  const ChartHolder({
    Key? key,
    required this.title,
    required this.chart,
    required this.sideLength,
    required this.color,
    required this.onExpand,
  }) : super(key: key);

  final String title;
  final Widget chart;
  final double sideLength;
  final Color color;
  final Function(String, Widget) onExpand;

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
                  Positioned(
                    right: 16,
                    top: 0,
                    child: IconButton(
                      iconSize: 16,
                      constraints: const BoxConstraints(maxHeight: 24, maxWidth: 24),
                      onPressed: () {
                        onExpand(title, chart);
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
                maxHeight: 200,
                maxWidth: sideLength,
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
