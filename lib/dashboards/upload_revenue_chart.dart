import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class UploadRevenueChart extends StatelessWidget {
  const UploadRevenueChart({super.key});

  @override
  Widget build(BuildContext context) {
    final weeks = ['W1', 'W2', 'W3', 'W4'];
    final uploads = [5.0, 8.0, 6.0, 10.0];
    final revenue = [1200.0, 1800.0, 1500.0, 2400.0];

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const Text("Uploads vs Revenue (Weekly)",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1.7,
              child: BarChart(
                BarChartData(
                  barGroups: List.generate(weeks.length, (i) {
                    return BarChartGroupData(x: i, barRods: [
                      BarChartRodData(
                          toY: uploads[i],
                          width: 8,
                          color: Colors.blueAccent),
                      BarChartRodData(
                          toY: revenue[i] / 300,
                          width: 8,
                          color: Colors.greenAccent),
                    ]);
                  }),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, interval: 2),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            weeks[value.toInt()],
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: true),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.circle, color: Colors.blueAccent, size: 10),
                SizedBox(width: 4),
                Text("Uploads"),
                SizedBox(width: 16),
                Icon(Icons.circle, color: Colors.greenAccent, size: 10),
                SizedBox(width: 4),
                Text("Revenue"),
              ],
            )
          ],
        ),
      ),
    );
  }
}

