part of 'fitness_bloc.dart';

abstract class FitnessEvent extends Equatable {
  const FitnessEvent();

  @override
  List<Object?> get props => [];
}

class FitnessStarted extends FitnessEvent {
  const FitnessStarted();
}

class FitnessDateSelected extends FitnessEvent {
  const FitnessDateSelected(this.date);

  final DateTime date;

  @override
  List<Object?> get props => [date];
}

class FitnessStepsUpdated extends FitnessEvent {
  const FitnessStepsUpdated(this.steps);

  final int steps;

  @override
  List<Object?> get props => [steps];
}

class FitnessStepsAdded extends FitnessEvent {
  const FitnessStepsAdded(this.increment);

  final int increment;

  @override
  List<Object?> get props => [increment];
}

class FitnessWaterUpdated extends FitnessEvent {
  const FitnessWaterUpdated(this.waterMl);

  final int waterMl;

  @override
  List<Object?> get props => [waterMl];
}

class FitnessWaterAdded extends FitnessEvent {
  const FitnessWaterAdded(this.incrementMl);

  final int incrementMl;

  @override
  List<Object?> get props => [incrementMl];
}

class FitnessGoalsUpdated extends FitnessEvent {
  const FitnessGoalsUpdated({this.targetSteps, this.targetCalories, this.targetWater});

  final int? targetSteps;
  final int? targetCalories;
  final int? targetWater;

  @override
  List<Object?> get props => [targetSteps, targetCalories, targetWater];
}

class FitnessWorkoutAdded extends FitnessEvent {
  const FitnessWorkoutAdded(this.workout);

  final Workout workout;

  @override
  List<Object?> get props => [workout];
}

class FitnessWorkoutDeleted extends FitnessEvent {
  const FitnessWorkoutDeleted(this.workoutId);

  final int workoutId;

  @override
  List<Object?> get props => [workoutId];
}
