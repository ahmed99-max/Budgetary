import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CategoryBreakdownChart extends StatelessWidget {
  final Map<String, double> data; // category name -> amount

  const CategoryBreakdownChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No data'));
    }

    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple
    ];

    int colorIndex = 0;

    return PieChart(
      PieChartData(
        sections: data.entries.map((entry) {
          final color = colors[colorIndex % colors.length];
          colorIndex++;
          return PieChartSectionData(
            value: entry.value,
            title: '${entry.key} (${entry.value.toStringAsFixed(0)})',
            color: color,
            radius: 50,
            titleStyle: const TextStyle(fontSize: 10, color: Colors.white),
          );
        }).toList(),
      ),
    );
  }
}
