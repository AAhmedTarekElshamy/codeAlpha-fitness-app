import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../shared/theme.dart';
import '../../models/workout.dart';
import '../../features/fitness/presentation/bloc/fitness_bloc.dart';

class LogActivityScreen extends StatefulWidget {
  const LogActivityScreen({super.key});

  @override
  State<LogActivityScreen> createState() => _LogActivityScreenState();
}

class _LogActivityScreenState extends State<LogActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _customTypeController = TextEditingController();

  String _selectedType = 'Running';
  int _duration = 30; // default 30 mins
  int _calories = 300; // default 300 kcal
  DateTime _workoutDateTime = DateTime.now();
  
  bool _isCustomType = false;

  // MET estimates (kcal burned per minute) for auto-calculation
  final Map<String, int> _caloriesPerMinute = {
    'Running': 10,
    'Walking': 5,
    'Cycling': 8,
    'Strength': 6,
    'Swimming': 9,
    'Yoga': 3,
  };

  final List<Map<String, dynamic>> _activities = [
    {'name': 'Running', 'icon': Icons.directions_run, 'color': FitnessTheme.calories},
    {'name': 'Walking', 'icon': Icons.directions_walk, 'color': FitnessTheme.steps},
    {'name': 'Cycling', 'icon': Icons.directions_bike, 'color': FitnessTheme.water},
    {'name': 'Strength', 'icon': Icons.fitness_center, 'color': FitnessTheme.workout},
    {'name': 'Swimming', 'icon': Icons.pool, 'color': Colors.blue},
    {'name': 'Yoga', 'icon': Icons.self_improvement, 'color': Colors.pinkAccent},
    {'name': 'Other', 'icon': Icons.more_horiz, 'color': Colors.grey},
  ];

  @override
  void initState() {
    super.initState();
    final fitnessState = context.read<FitnessBloc>().state;
    // Match the selected date on the dashboard for logging
    final currentDate = fitnessState.currentDate;
    final now = DateTime.now();
    _workoutDateTime = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
      now.hour,
      now.minute,
    );
  }

  void _calculateCalories(int duration) {
    if (_isCustomType) return;
    final rate = _caloriesPerMinute[_selectedType] ?? 7;
    setState(() {
      _calories = (rate * duration).clamp(10, 3000);
    });
  }

  void _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _workoutDateTime,
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

    if (pickedDate != null) {
      if (!mounted) return;
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_workoutDateTime),
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

      if (pickedTime != null) {
        setState(() {
          _workoutDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final type = _isCustomType ? _customTypeController.text.trim() : _selectedType;
      
      final workout = Workout(
        type: type,
        duration: _duration,
        calories: _calories,
        timestamp: _workoutDateTime,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      context.read<FitnessBloc>().add(FitnessWorkoutAdded(workout));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$type workout logged successfully!'),
          backgroundColor: FitnessTheme.steps,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Workout', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 768;

          return Form(
            key: _formKey,
            child: isWide 
                ? _buildWideLayout(context) 
                : _buildMobileLayout(context),
          );
        },
      ),
    );
  }

  // Mobile layout (Single Scroll Column)
  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Activity Type',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          _buildActivitySelector(),
          if (_isCustomType) ...[
            const SizedBox(height: 16),
            _buildCustomTypeField(),
          ],
          const SizedBox(height: 24),
          _buildDurationSlider(),
          const SizedBox(height: 24),
          _buildCaloriesSlider(),
          const SizedBox(height: 24),
          _buildDateTimePickerRow(),
          const SizedBox(height: 24),
          _buildNotesField(),
          const SizedBox(height: 32),
          _buildSubmitButton(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Tablet/Desktop layout (Split Panels)
  Widget _buildWideLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side: Type Selector
          Expanded(
            flex: 5,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Activity Type',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    _buildActivitySelector(),
                    if (_isCustomType) ...[
                      const SizedBox(height: 16),
                      _buildCustomTypeField(),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          // Right side: Parameters
          Expanded(
            flex: 6,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDurationSlider(),
                    const SizedBox(height: 20),
                    _buildCaloriesSlider(),
                    const SizedBox(height: 20),
                    _buildDateTimePickerRow(),
                    const SizedBox(height: 20),
                    _buildNotesField(),
                    const SizedBox(height: 28),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySelector() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.15,
      ),
      itemCount: _activities.length,
      itemBuilder: (context, index) {
        final act = _activities[index];
        final name = act['name'] as String;
        final icon = act['icon'] as IconData;
        final color = act['color'] as Color;
        final isSelected = (_selectedType == name && !_isCustomType) || 
            (name == 'Other' && _isCustomType);

        return InkWell(
          onTap: () {
            setState(() {
              if (name == 'Other') {
                _isCustomType = true;
                _selectedType = 'Other';
              } else {
                _isCustomType = false;
                _selectedType = name;
                _calculateCalories(_duration);
              }
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.15) : FitnessTheme.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? color : FitnessTheme.cardBorder,
                width: 1.5,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))]
                  : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isSelected ? color : FitnessTheme.textSecondary,
                  size: 26,
                ),
                const SizedBox(height: 6),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : FitnessTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomTypeField() {
    return TextFormField(
      controller: _customTypeController,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Custom Exercise Name',
        labelStyle: const TextStyle(color: FitnessTheme.textSecondary),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: FitnessTheme.cardBorder),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: FitnessTheme.primary),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (_isCustomType && (value == null || value.trim().isEmpty)) {
          return 'Please enter a name for the custom exercise';
        }
        return null;
      },
    );
  }

  Widget _buildDurationSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Workout Duration',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              '$_duration mins',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: FitnessTheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: _duration.toDouble(),
          min: 5,
          max: 180,
          divisions: 35,
          onChanged: (val) {
            setState(() {
              _duration = val.toInt();
              _calculateCalories(_duration);
            });
          },
        ),
      ],
    );
  }

  Widget _buildCaloriesSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Calories Burned',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              '$_calories kcal',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: FitnessTheme.calories,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: _calories.toDouble(),
          min: 10,
          max: 3000,
          divisions: 299,
          activeColor: FitnessTheme.calories,
          onChanged: (val) {
            setState(() {
              _calories = val.toInt();
            });
          },
        ),
      ],
    );
  }

  Widget _buildDateTimePickerRow() {
    final formattedDate = DateFormat('EEE, MMM d, y - h:mm a').format(_workoutDateTime);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date & Time',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDateTime(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: FitnessTheme.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: FitnessTheme.cardBorder, width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                ),
                const Icon(Icons.calendar_month, color: FitnessTheme.primary, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notes (Optional)',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _notesController,
          maxLines: 2,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Add a brief note about this workout...',
            hintStyle: const TextStyle(color: FitnessTheme.textMuted, fontSize: 13),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: FitnessTheme.cardBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: FitnessTheme.primary),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: FitnessTheme.primary,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        onPressed: _submitForm,
        child: const Text(
          'Log Workout Session',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
