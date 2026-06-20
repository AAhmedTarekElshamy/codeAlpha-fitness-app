import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../shared/theme.dart';
import '../../features/fitness/presentation/bloc/fitness_bloc.dart';
import '../../models/daily_stats.dart';
import 'widgets/daily_progress_ring.dart';
import 'widgets/stats_card.dart';
import 'widgets/weekly_bar_chart.dart';
import '../log_activity/log_activity_screen.dart';
import '../history/history_screen.dart';
import '../../src/presentation/screens/step_counter_maps_screen.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  void _selectDate(BuildContext context, FitnessState state) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: state.currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: FitnessTheme.primary,
              onPrimary: Colors.black,
              surface: FitnessTheme.surface,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != state.currentDate && context.mounted) {
      context.read<FitnessBloc>().add(FitnessDateSelected(picked));
    }
  }

  void _showGoalsDialog(BuildContext context, FitnessState state) {
    final stats = state.todayStats;
    if (stats == null) return;

    final stepsController = TextEditingController(text: stats.targetSteps.toString());
    final caloriesController = TextEditingController(text: stats.targetCalories.toString());
    final waterController = TextEditingController(text: stats.targetWater.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: FitnessTheme.surface,
          title: const Text(
            'Edit Daily Goals',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildGoalInputField(
                  label: 'Steps Goal',
                  controller: stepsController,
                  icon: Icons.directions_walk,
                  color: FitnessTheme.steps,
                ),
                const SizedBox(height: 12),
                _buildGoalInputField(
                  label: 'Calories Goal (kcal)',
                  controller: caloriesController,
                  icon: Icons.local_fire_department,
                  color: FitnessTheme.calories,
                ),
                const SizedBox(height: 12),
                _buildGoalInputField(
                  label: 'Water Goal (ml)',
                  controller: waterController,
                  icon: Icons.water_drop,
                  color: FitnessTheme.water,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: FitnessTheme.primary,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                final steps = int.tryParse(stepsController.text) ?? stats.targetSteps;
                final calories = int.tryParse(caloriesController.text) ?? stats.targetCalories;
                final water = int.tryParse(waterController.text) ?? stats.targetWater;

                context.read<FitnessBloc>().add(FitnessGoalsUpdated(
                  targetSteps: steps,
                  targetCalories: calories,
                  targetWater: water,
                ));
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Goals updated successfully!'),
                    backgroundColor: FitnessTheme.surface,
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGoalInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required Color color,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: FitnessTheme.textSecondary),
        prefixIcon: Icon(icon, color: color),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: FitnessTheme.cardBorder),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: color),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: FitnessTheme.primary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bolt,
                color: FitnessTheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'PulseFit',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 22,
                color: FitnessTheme.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.map, color: Colors.white),
            tooltip: 'Step Counter & GPS',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StepCounterMapScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            tooltip: 'Workout History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),
          BlocBuilder<FitnessBloc, FitnessState>(
            builder: (context, state) {
              return IconButton(
                icon: const Icon(Icons.edit_road, color: Colors.white),
                tooltip: 'Edit Goals',
                onPressed: () => _showGoalsDialog(context, state),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<FitnessBloc, FitnessState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator(color: FitnessTheme.primary));
          }

          final stats = state.todayStats;
          if (stats == null) {
            return const Center(child: Text('Failed to load daily stats.'));
          }

          final today = DateTime.now();
          final isToday = state.currentDate.year == today.year &&
              state.currentDate.month == today.month &&
              state.currentDate.day == today.day;

          // Responsive design layout builder
          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 768;
              
              if (isWide) {
                // Tablet/Desktop layout (Side-by-side)
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Panel (Progress Ring & Navigation)
                      Expanded(
                        flex: 4,
                        child: Column(
                          children: [
                            _buildDateSelector(state),
                            const SizedBox(height: 32),
                            DailyProgressRing(
                              steps: stats.steps,
                              targetSteps: stats.targetSteps,
                              size: 240,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              isToday ? "Keep pushing to hit your goals today!" : "Viewing archived workout log.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: FitnessTheme.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 32),
                      // Right Panel (Grid of Cards & Graph)
                      Expanded(
                        flex: 6,
                        child: Column(
                          children: [
                            _buildAiRecommendation(state),
                            const SizedBox(height: 16),
                            _buildStatsGrid(state, stats, isWide),
                            const SizedBox(height: 24),
                            WeeklyBarChart(
                              weeklyStats: state.weeklyStats,
                              getCaloriesForDate: state.getCaloriesBurnedForDate,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                // Mobile layout (Linear Scroll)
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Column(
                    children: [
                      _buildDateSelector(state),
                      const SizedBox(height: 24),
                      Center(
                        child: DailyProgressRing(
                          steps: stats.steps,
                          targetSteps: stats.targetSteps,
                          size: 200,
                        ),
                      ),
                      const SizedBox(height: 28),
                      _buildAiRecommendation(state),
                      const SizedBox(height: 16),
                      _buildStatsGrid(state, stats, isWide),
                      const SizedBox(height: 20),
                      WeeklyBarChart(
                        weeklyStats: state.weeklyStats,
                        getCaloriesForDate: state.getCaloriesBurnedForDate,
                      ),
                      const SizedBox(height: 80), // spacer for FAB
                    ],
                  ),
                );
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LogActivityScreen()),
          );
        },
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  // Header date navigation bar
  Widget _buildDateSelector(FitnessState state) {
    final dateLabel = DateFormat('EEEE, MMMM d').format(state.currentDate);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: FitnessTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FitnessTheme.cardBorder, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white),
            onPressed: () {
              context.read<FitnessBloc>().add(
                    FitnessDateSelected(state.currentDate.subtract(const Duration(days: 1))),
                  );
            },
          ),
          InkWell(
            onTap: () => _selectDate(context, state),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: FitnessTheme.primary),
                const SizedBox(width: 8),
                Text(
                  dateLabel,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: FitnessTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.white),
            onPressed: state.currentDate.isAfter(DateTime.now().subtract(const Duration(days: 1)))
                ? null
                : () {
                    context.read<FitnessBloc>().add(
                          FitnessDateSelected(state.currentDate.add(const Duration(days: 1))),
                        );
                  },
          ),
        ],
      ),
    );
  }

  // Dashboard quick-stats cards grid
  Widget _buildAiRecommendation(FitnessState state) {
    if (state.recommendation.isEmpty) return const SizedBox.shrink();

    return Card(
      child: ListTile(
        leading: const Icon(Icons.auto_awesome, color: FitnessTheme.primary),
        title: const Text(
          'AI Recommendation',
          style: TextStyle(fontWeight: FontWeight.bold, color: FitnessTheme.textPrimary),
        ),
        subtitle: Text(
          state.recommendation,
          style: const TextStyle(color: FitnessTheme.textSecondary),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(FitnessState state, DailyStats stats, bool isWide) {
    final cards = [
      StatsCard(
        title: 'Steps Walked',
        value: stats.steps.toString(),
        unit: '',
        current: stats.steps,
        target: stats.targetSteps,
        icon: Icons.directions_run,
        color: FitnessTheme.steps,
        subtractTooltip: 'Remove 1,000 steps',
        addTooltip: 'Add 1,000 steps',
        onSubtractTap: () {
          context.read<FitnessBloc>().add(const FitnessStepsAdded(-1000));
        },
        onAddTap: () {
          context.read<FitnessBloc>().add(const FitnessStepsAdded(1000));
        },
      ),
      StatsCard(
        title: 'Active Burn',
        value: state.totalCaloriesBurned.toString(),
        unit: ' kcal',
        current: state.totalCaloriesBurned,
        target: stats.targetCalories,
        icon: Icons.local_fire_department,
        color: FitnessTheme.calories,
      ),
      StatsCard(
        title: 'Hydration',
        value: stats.waterIntake.toString(),
        unit: ' ml',
        current: stats.waterIntake,
        target: stats.targetWater,
        icon: Icons.water_drop,
        color: FitnessTheme.water,
        subtractTooltip: 'Remove 250ml water',
        addTooltip: 'Add 250ml water',
        onSubtractTap: () {
          context.read<FitnessBloc>().add(const FitnessWaterAdded(-250));
        },
        onAddTap: () {
          context.read<FitnessBloc>().add(const FitnessWaterAdded(250));
        },
      ),
      StatsCard(
        title: 'Workouts',
        value: state.todayWorkouts.length.toString(),
        unit: ' logged',
        current: state.todayWorkouts.length,
        target: 1,
        icon: Icons.fitness_center,
        color: FitnessTheme.workout,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 380 ? 1 : 2;
        final cardHeight = crossAxisCount == 1 ? 196.0 : 204.0;

        return GridView.builder(
          itemCount: cards.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: cardHeight,
          ),
          itemBuilder: (context, index) => cards[index],
        );
      },
    );
  }
}
