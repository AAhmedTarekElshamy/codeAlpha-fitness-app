import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/api/api_client.dart';
import 'core/cache/fitness_cache_service.dart';
import 'core/notifications/push_notification_service.dart';
import 'core/telemetry/firebase_telemetry_service.dart';
import 'features/fitness/data/datasources/fitness_local_data_source.dart';
import 'features/fitness/data/repositories/fitness_repository_impl.dart';
import 'features/fitness/data/repositories/recommendation_repository_impl.dart';
import 'features/fitness/domain/repositories/fitness_repository.dart';
import 'features/fitness/domain/repositories/recommendation_repository.dart';
import 'features/fitness/presentation/bloc/fitness_bloc.dart';
import 'src/data/datasources/local/step_counter_local_datasource.dart' as step_local;
import 'src/data/datasources/local/step_counter_local_datasource_impl.dart' as step_local_impl;
import 'src/data/datasources/pedometer/pedometer_datasource.dart' as pedometer;
import 'src/data/repositories/step_counter_repository_impl.dart' as step_repo_impl;
import 'src/domain/repositories/step_counter_repository.dart' as step_repo;
import 'src/domain/usecases/step_counter_usecases.dart' as step_usecases;
import 'src/presentation/blocs/step_counter_bloc.dart' as step_bloc;

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  if (!getIt.isRegistered<SharedPreferences>()) {
    getIt.registerSingleton<SharedPreferences>(await SharedPreferences.getInstance());
  }
  if (!getIt.isRegistered<ApiClient>()) {
    getIt.registerLazySingleton<ApiClient>(ApiClient.new);
  }
  if (!getIt.isRegistered<FitnessCacheService>()) {
    getIt.registerLazySingleton<FitnessCacheService>(FitnessCacheService.new);
  }
  if (!getIt.isRegistered<PushNotificationService>()) {
    getIt.registerLazySingleton<PushNotificationService>(PushNotificationService.new);
  }
  if (!getIt.isRegistered<FirebaseTelemetryService>()) {
    getIt.registerLazySingleton<FirebaseTelemetryService>(FirebaseTelemetryService.new);
  }
  if (!getIt.isRegistered<FitnessLocalDataSource>()) {
    getIt.registerLazySingleton<FitnessLocalDataSource>(SqfliteFitnessLocalDataSource.new);
  }
  if (!getIt.isRegistered<FitnessRepository>()) {
    getIt.registerLazySingleton<FitnessRepository>(() => FitnessRepositoryImpl(getIt()));
  }
  if (!getIt.isRegistered<RecommendationRepository>()) {
    getIt.registerLazySingleton<RecommendationRepository>(() => RecommendationRepositoryImpl(getIt(), getIt()));
  }
  if (!getIt.isRegistered<FitnessBloc>()) {
    getIt.registerFactory<FitnessBloc>(() => FitnessBloc(getIt(), getIt(), getIt(), getIt(), getIt()));
  }

  _registerStepCounterDependencies();
}

void _registerStepCounterDependencies() {
  if (!getIt.isRegistered<pedometer.PedometerDataSource>()) {
    getIt.registerLazySingleton<pedometer.PedometerDataSource>(pedometer.PedometerDataSourceImpl.new);
  }
  if (!getIt.isRegistered<step_local.StepCounterLocalDataSource>()) {
    getIt.registerLazySingleton<step_local.StepCounterLocalDataSource>(
      () => step_local_impl.StepCounterLocalDataSourceImpl(sharedPreferences: getIt()),
    );
  }
  if (!getIt.isRegistered<step_repo.StepCounterRepository>()) {
    getIt.registerLazySingleton<step_repo.StepCounterRepository>(
      () => step_repo_impl.StepCounterRepositoryImpl(
        localDataSource: getIt(),
        pedometerDataSource: getIt(),
      ),
    );
  }
  if (!getIt.isRegistered<step_usecases.GetCurrentStepsUseCase>()) {
    getIt.registerLazySingleton<step_usecases.GetCurrentStepsUseCase>(
      () => step_usecases.GetCurrentStepsUseCase(repository: getIt()),
    );
  }
  if (!getIt.isRegistered<step_usecases.StartStepCountingUseCase>()) {
    getIt.registerLazySingleton<step_usecases.StartStepCountingUseCase>(
      () => step_usecases.StartStepCountingUseCase(repository: getIt()),
    );
  }
  if (!getIt.isRegistered<step_usecases.StopStepCountingUseCase>()) {
    getIt.registerLazySingleton<step_usecases.StopStepCountingUseCase>(
      () => step_usecases.StopStepCountingUseCase(repository: getIt()),
    );
  }
  if (!getIt.isRegistered<step_usecases.GetStepsForDateUseCase>()) {
    getIt.registerLazySingleton<step_usecases.GetStepsForDateUseCase>(
      () => step_usecases.GetStepsForDateUseCase(repository: getIt()),
    );
  }
  if (!getIt.isRegistered<step_usecases.GetDailyGoalUseCase>()) {
    getIt.registerLazySingleton<step_usecases.GetDailyGoalUseCase>(
      () => step_usecases.GetDailyGoalUseCase(repository: getIt()),
    );
  }
  if (!getIt.isRegistered<step_usecases.UpdateDailyGoalUseCase>()) {
    getIt.registerLazySingleton<step_usecases.UpdateDailyGoalUseCase>(
      () => step_usecases.UpdateDailyGoalUseCase(repository: getIt()),
    );
  }
  if (!getIt.isRegistered<step_usecases.CheckStepCounterPermissionsUseCase>()) {
    getIt.registerLazySingleton<step_usecases.CheckStepCounterPermissionsUseCase>(
      () => step_usecases.CheckStepCounterPermissionsUseCase(repository: getIt()),
    );
  }
  if (!getIt.isRegistered<step_usecases.RequestStepCounterPermissionsUseCase>()) {
    getIt.registerLazySingleton<step_usecases.RequestStepCounterPermissionsUseCase>(
      () => step_usecases.RequestStepCounterPermissionsUseCase(repository: getIt()),
    );
  }
  if (!getIt.isRegistered<step_usecases.ResetDailyStepsUseCase>()) {
    getIt.registerLazySingleton<step_usecases.ResetDailyStepsUseCase>(
      () => step_usecases.ResetDailyStepsUseCase(repository: getIt()),
    );
  }
  if (!getIt.isRegistered<step_bloc.StepCounterBloc>()) {
    getIt.registerFactory<step_bloc.StepCounterBloc>(
      () => step_bloc.StepCounterBloc(
        getCurrentStepsUseCase: getIt(),
        startStepCountingUseCase: getIt(),
        stopStepCountingUseCase: getIt(),
        getStepsForDateUseCase: getIt(),
        getDailyGoalUseCase: getIt(),
        updateDailyGoalUseCase: getIt(),
        checkPermissionsUseCase: getIt(),
        requestPermissionsUseCase: getIt(),
        resetDailyStepsUseCase: getIt(),
      ),
    );
  }
}
