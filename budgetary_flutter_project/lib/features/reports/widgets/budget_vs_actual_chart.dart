import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BudgetVsActualChart extends StatelessWidget {
  final Map<String, double> budgetData; // category -> spent
  final double monthlyIncome;

  const BudgetVsActualChart({
    super.key,
    required this.budgetData,
    required this.monthlyIncome,
  });

  @override
  Widget build(BuildContext context) {
    if (budgetData.isEmpty) {
      return const Center(child: Text('No data'));
    }

    final keys = budgetData.keys.toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: monthlyIncome,
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= keys.length) return const SizedBox();
                return Text(keys[idx], style: const TextStyle(fontSize: 10));
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: budgetData.entries.toList().asMap().entries.map((e) {
          final actual = e.value.value;
          final catBudget = monthlyIncome / keys.length; // even split
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: actual,
                color: Colors.redAccent,
                width: 8,
              ),
              BarChartRodData(
                toY: catBudget,
                color: Colors.greenAccent,
                width: 8,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
