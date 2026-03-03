import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DashboardChart extends StatelessWidget {
  final List<int> monthlyPending;
  final List<int> monthlyApproved;

  const DashboardChart({
    super.key,
    required this.monthlyPending,
    required this.monthlyApproved,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const months = [
                    '1','2','3','4','5','6',
                    '7','8','9','10','11','12'
                  ];
                  if (value.toInt() < 0 || value.toInt() > 11) {
                    return const Text('');
                  }
                  return Text(months[value.toInt()]);
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                12,
                (index) => FlSpot(
                  index.toDouble(),
                  monthlyApproved[index].toDouble(),
                ),
              ),
              isCurved: true,
              color: Colors.green,
              barWidth: 3,
            ),
            LineChartBarData(
              spots: List.generate(
                12,
                (index) => FlSpot(
                  index.toDouble(),
                  monthlyPending[index].toDouble(),
                ),
              ),
              isCurved: true,
              color: Colors.orange,
              barWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}