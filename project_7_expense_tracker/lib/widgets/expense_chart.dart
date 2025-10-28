import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/expense.dart';

class ExpenseChart extends StatelessWidget {
  final List<Expense> expenses;
  const ExpenseChart({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    // Gom dữ liệu theo ngày
    final Map<String, double> dailyTotals = {};
    for (var e in expenses) {
      final dateKey = '${e.date.day}/${e.date.month}';
      dailyTotals[dateKey] = (dailyTotals[dateKey] ?? 0) + e.amount;
    }

    final data = dailyTotals.entries.toList();

    return Card(
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: BarChart(
          BarChartData(
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, _) {
                    int index = v.toInt();
                    if (index < 0 || index >= data.length) {
                      return const Text('');
                    }
                    return Text(
                      data[index].key,
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            barGroups: data
                .asMap()
                .entries
                .map(
                  (e) => BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.value,
                        width: 16,
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.green,
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
