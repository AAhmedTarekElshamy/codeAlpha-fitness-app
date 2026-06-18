import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../shared/theme.dart';
import '../../models/workout.dart';
import '../../viewmodels/fitness_viewmodel.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  Workout? _selectedWorkout;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ensure we query for weekly workouts / data on load
      final viewModel = context.read<FitnessViewModel>();
      viewModel.loadDataForDate(viewModel.currentDate);
    });
  }

  void _handleDelete(BuildContext context, FitnessViewModel viewModel, Workout workout) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final workoutId = workout.id;
    if (workoutId == null) return;

    // Remove from database
    await viewModel.deleteWorkout(workoutId);

    // Show undo banner
    scaffoldMessenger.clearSnackBars();
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text('Deleted ${workout.type} workout'),
        backgroundColor: FitnessTheme.surface,
        action: SnackBarAction(
          label: 'UNDO',
          textColor: FitnessTheme.primary,
          onPressed: () async {
            // Re-insert workout
            await viewModel.addWorkout(workout);
          },
        ),
      ),
    );

    if (_selectedWorkout?.id == workoutId) {
      setState(() {
        _selectedWorkout = null;
      });
    }
  }

  void _showDetailsDialog(BuildContext context, Workout workout, FitnessViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: FitnessTheme.surface,
          title: Row(
            children: [
              _buildTypeIcon(workout.type, 22),
              const SizedBox(width: 10),
              Text(workout.type, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(Icons.calendar_month, 'Date:', DateFormat('EEE, MMM d, yyyy').format(workout.timestamp)),
              _buildDetailRow(Icons.access_time, 'Logged at:', DateFormat('h:mm a').format(workout.timestamp)),
              _buildDetailRow(Icons.timer_outlined, 'Duration:', '${workout.duration} minutes'),
              _buildDetailRow(Icons.local_fire_department_outlined, 'Burned:', '${workout.calories} kcal'),
              const Divider(color: FitnessTheme.cardBorder, height: 20),
              const Text('Notes:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: FitnessTheme.textSecondary)),
              const SizedBox(height: 6),
              Text(
                workout.notes ?? 'No notes recorded for this workout.',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: workout.notes == null ? FontStyle.italic : FontStyle.normal,
                  color: workout.notes == null ? FitnessTheme.textMuted : Colors.white,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _handleDelete(context, viewModel, workout);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: FitnessTheme.primary,
                foregroundColor: Colors.black,
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: FitnessTheme.primary),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13, color: FitnessTheme.textSecondary, fontWeight: FontWeight.w500)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeIcon(String type, double size) {
    IconData iconData = Icons.fitness_center;
    Color color = FitnessTheme.workout;

    switch (type) {
      case 'Running':
        iconData = Icons.directions_run;
        color = FitnessTheme.calories;
        break;
      case 'Walking':
        iconData = Icons.directions_walk;
        color = FitnessTheme.steps;
        break;
      case 'Cycling':
        iconData = Icons.directions_bike;
        color = FitnessTheme.water;
        break;
      case 'Strength':
        iconData = Icons.fitness_center;
        color = FitnessTheme.workout;
        break;
      case 'Swimming':
        iconData = Icons.pool;
        color = Colors.blue;
        break;
      case 'Yoga':
        iconData = Icons.self_improvement;
        color = Colors.pinkAccent;
        break;
      default:
        iconData = Icons.bolt;
        color = FitnessTheme.primary;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: color, size: size),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout History', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<FitnessViewModel>(
        builder: (context, viewModel, child) {
          // Sort all weekly/recent workouts descending
          final workouts = List<Workout>.from(viewModel.weeklyWorkouts)
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

          if (workouts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: FitnessTheme.cardBg,
                      shape: BoxShape.circle,
                      border: Border.all(color: FitnessTheme.cardBorder, width: 1.5),
                    ),
                    child: const Icon(Icons.history_toggle_off, size: 48, color: FitnessTheme.textMuted),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'No Workouts Logged Yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your weekly logged sessions will appear here.',
                    style: TextStyle(fontSize: 14, color: FitnessTheme.textSecondary),
                  ),
                ],
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 768;

              if (isWide) {
                // Wide Screen Layout (Master-Detail List)
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // List Panel (Master)
                      Expanded(
                        flex: 5,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: _buildWorkoutListView(workouts, viewModel, isWide),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Detail Panel (Detail)
                      Expanded(
                        flex: 6,
                        child: _selectedWorkout == null
                            ? Card(
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.touch_app, size: 36, color: FitnessTheme.textMuted),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Select a workout to view details',
                                        style: TextStyle(color: FitnessTheme.textSecondary, fontSize: 15),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : _buildWorkoutDetailPane(viewModel, _selectedWorkout!),
                      ),
                    ],
                  ),
                );
              } else {
                // Mobile layout (Standard list view)
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: _buildWorkoutListView(workouts, viewModel, isWide),
                );
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildWorkoutListView(List<Workout> workouts, FitnessViewModel viewModel, bool isWide) {
    return ListView.separated(
      itemCount: workouts.length,
      separatorBuilder: (context, index) => const Divider(color: FitnessTheme.cardBorder, height: 1),
      itemBuilder: (context, index) {
        final workout = workouts[index];
        final timeLabel = DateFormat('jm').format(workout.timestamp);
        final dateLabel = DateFormat('MMM d').format(workout.timestamp);

        final isSelected = _selectedWorkout?.id == workout.id;

        return Dismissible(
          key: Key(workout.id.toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.redAccent.withOpacity(0.8),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) => _handleDelete(context, viewModel, workout),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: _buildTypeIcon(workout.type, 18),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  workout.type,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isSelected && isWide ? FitnessTheme.primary : Colors.white,
                  ),
                ),
                Text(
                  '$dateLabel, $timeLabel',
                  style: TextStyle(fontSize: 11, color: FitnessTheme.textMuted),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Row(
                children: [
                  Icon(Icons.timer_outlined, size: 13, color: FitnessTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text('${workout.duration}m', style: TextStyle(fontSize: 13, color: FitnessTheme.textSecondary)),
                  const SizedBox(width: 14),
                  Icon(Icons.local_fire_department_outlined, size: 13, color: FitnessTheme.calories),
                  const SizedBox(width: 4),
                  Text('${workout.calories} kcal', style: TextStyle(fontSize: 13, color: FitnessTheme.textSecondary)),
                ],
              ),
            ),
            selected: isSelected && isWide,
            selectedTileColor: FitnessTheme.primary.withOpacity(0.08),
            onTap: () {
              if (isWide) {
                setState(() {
                  _selectedWorkout = workout;
                });
              } else {
                _showDetailsDialog(context, workout, viewModel);
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildWorkoutDetailPane(FitnessViewModel viewModel, Workout workout) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildTypeIcon(workout.type, 28),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout.type,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(
                          DateFormat('EEEE, MMMM d, yyyy').format(workout.timestamp),
                          style: TextStyle(fontSize: 13, color: FitnessTheme.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  tooltip: 'Delete Workout',
                  onPressed: () => _handleDelete(context, viewModel, workout),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: _buildMetricDetailCard(
                    Icons.timer_outlined,
                    'Duration',
                    '${workout.duration}',
                    'minutes',
                    FitnessTheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricDetailCard(
                    Icons.local_fire_department_outlined,
                    'Burned',
                    '${workout.calories}',
                    'kcal',
                    FitnessTheme.calories,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Activity Notes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: FitnessTheme.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: FitnessTheme.cardBorder, width: 1.5),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    workout.notes ?? 'No notes recorded for this workout.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      fontStyle: workout.notes == null ? FontStyle.italic : FontStyle.normal,
                      color: workout.notes == null ? FitnessTheme.textMuted : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricDetailCard(IconData icon, String label, String value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: FitnessTheme.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: FitnessTheme.cardBorder, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(fontSize: 12, color: FitnessTheme.textSecondary, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            textBaseline: TextBaseline.alphabetic,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(fontSize: 12, color: FitnessTheme.textMuted, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
