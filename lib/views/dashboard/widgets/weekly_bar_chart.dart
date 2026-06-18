import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../shared/theme.dart';
import '../../../models/daily_stats.dart';

class WeeklyBarChart extends StatefulWidget {
  final List<DailyStats> weeklyStats;
  final int Function(String dateStr) getCaloriesForDate;

  const WeeklyBarChart({
    super.key,
    required this.weeklyStats,
    required this.getCaloriesForDate,
  });

  @override
  State<WeeklyBarChart> createState() => _WeeklyBarChartState();
}

class _WeeklyBarChartState extends State<WeeklyBarChart> {
  bool _showSteps = true; // true: Steps, false: Calories

  @override
  Widget build(BuildContext context) {
    // Determine maximum value for Y scaling
    double maxVal = 0.0;
    for (var stat in widget.weeklyStats) {
      final val = _showSteps
          ? stat.steps.toDouble()
          : widget.getCaloriesForDate(stat.date).toDouble();
      if (val > maxVal) {
        maxVal = val;
      }
    }
    
    // Add default padding to maxY (avoid divide by 0)
    final double maxY = maxVal == 0 ? 1000 : maxVal * 1.2;
    final themeColor = _showSteps ? FitnessTheme.steps : FitnessTheme.calories;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Weekly Analytics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: FitnessTheme.textPrimary,
                  ),
                ),
                // Toggle Switch
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: FitnessTheme.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _buildToggleButton('Steps', _showSteps, () {
                        setState(() => _showSteps = true);
                      }, FitnessTheme.steps),
                      _buildToggleButton('Calories', !_showSteps, () {
                        setState(() => _showSteps = false);
                      }, FitnessTheme.calories),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) => FitnessTheme.cardBg,
                      tooltipBorder: const BorderSide(color: FitnessTheme.cardBorder),
                      tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final stat = widget.weeklyStats[groupIndex];
                        final valStr = _showSteps
                            ? '${rod.toY.toInt()} steps'
                            : '${rod.toY.toInt()} kcal';
                        return BarTooltipItem(
                          '${_formatDateLabel(stat.date)}\n',
                          const TextStyle(
                            color: FitnessTheme.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                          children: [
                            TextSpan(
                              text: valStr,
                              style: TextStyle(
                                color: themeColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final int index = value.toInt();
                          if (index < 0 || index >= widget.weeklyStats.length) {
                            return const SizedBox.shrink();
                          }
                          final dateStr = widget.weeklyStats[index].date;
                          final parsedDate = DateTime.parse(dateStr);
                          final label = DateFormat('E').format(parsedDate).substring(0, 1); // e.g. M, T, W
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              label,
                              style: const TextStyle(
                                color: FitnessTheme.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(widget.weeklyStats.length, (index) {
                    final stat = widget.weeklyStats[index];
                    final double val = _showSteps
                        ? stat.steps.toDouble()
                        : widget.getCaloriesForDate(stat.date).toDouble();

                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: val,
                          gradient: LinearGradient(
                            colors: [
                              themeColor.withOpacity(0.5),
                              themeColor,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          width: 14,
                          borderRadius: BorderRadius.circular(6),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxY,
                            color: FitnessTheme.background,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isSelected, VoidCallback onTap, Color activeColor) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? activeColor : FitnessTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _formatDateLabel(String dateStr) {
    final date = DateTime.parse(dateStr);
    return DateFormat('EEE, MMM d').format(date);
  }
}
