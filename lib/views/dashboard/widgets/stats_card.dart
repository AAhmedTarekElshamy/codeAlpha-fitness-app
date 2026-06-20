import 'package:flutter/material.dart';
import 'dart:math';
import '../../shared/theme.dart';

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final int current;
  final int target;
  final IconData icon;
  final Color color;
  final VoidCallback? onAddTap;
  final VoidCallback? onSubtractTap;
  final String? addTooltip;
  final String? subtractTooltip;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.current,
    required this.target,
    required this.icon,
    required this.color,
    this.onAddTap,
    this.onSubtractTap,
    this.addTooltip,
    this.subtractTooltip,
  });

  @override
  Widget build(BuildContext context) {
    final double percentage = target > 0 ? current / target : 0.0;
    final double progress = min(percentage, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon block
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                if (onSubtractTap != null || onAddTap != null)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onAddTap != null)
                        _QuickActionButton(
                          icon: Icons.add,
                          tooltip: addTooltip ?? 'Quick add',
                          onTap: onAddTap!,
                        ),
                      if (onSubtractTap != null && onAddTap != null) const SizedBox(height: 6),
                      if (onSubtractTap != null)
                        _QuickActionButton(
                          icon: Icons.remove,
                          tooltip: subtractTooltip ?? 'Quick subtract',
                          onTap: onSubtractTap!,
                        ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: FitnessTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            // Metrics
            Row(
              textBaseline: TextBaseline.alphabetic,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: FitnessTheme.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: FitnessTheme.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Goal indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Goal: $target$unit',
                  style: TextStyle(
                    fontSize: 10,
                    color: FitnessTheme.textMuted,
                  ),
                ),
                Text(
                  '${(percentage * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 6,
                width: double.infinity,
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: FitnessTheme.cardBorder.withOpacity(0.5),
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: FitnessTheme.cardBorder,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox.square(
            dimension: 24,
            child: Icon(
              icon,
              color: Colors.white,
              size: 15,
            ),
          ),
        ),
      ),
    );
  }
}
