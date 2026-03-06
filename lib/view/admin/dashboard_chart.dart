import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DashboardChart extends StatelessWidget {
  final List<int> monthlyUsers;

  const DashboardChart({
    super.key,
    required this.monthlyUsers,
  });

  double _getMaxY() {
    double maxValue =
        monthlyUsers.reduce((a, b) => a > b ? a : b).toDouble();
    return (maxValue / 5).ceil() * 5 + 5;
  }

  @override
  Widget build(BuildContext context) {
    final maxY = _getMaxY();

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          minY: 0,
          maxY: maxY,

          gridData: FlGridData(
            show: true,
            horizontalInterval: 5,
            drawVerticalLine: false,
          ),

          borderData: FlBorderData(
            show: true,
            border: const Border(
              left: BorderSide(),
              bottom: BorderSide(),
              right: BorderSide.none,
              top: BorderSide.none,
            ),
          ),

          titlesData: FlTitlesData(
            /// THÁNG
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  if (value < 0 || value > 11) {
                    return const SizedBox();
                  }

                  return Text(
                    '${value.toInt() + 1}',
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),

            /// TRỤC Y
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 5,
                reservedSize: 35,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),

            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),

          barGroups: List.generate(
            12,
            (index) => BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: index < monthlyUsers.length
                  ? monthlyUsers[index].toDouble()
                  : 0,
                  width: 14,
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.teal,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}