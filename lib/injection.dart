import 'package:get_it/get_it.dart';

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

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  if (getIt.isRegistered<FitnessBloc>()) return;

  getIt
    ..registerLazySingleton<ApiClient>(ApiClient.new)
    ..registerLazySingleton<FitnessCacheService>(FitnessCacheService.new)
    ..registerLazySingleton<PushNotificationService>(PushNotificationService.new)
    ..registerLazySingleton<FirebaseTelemetryService>(FirebaseTelemetryService.new)
    ..registerLazySingleton<FitnessLocalDataSource>(SqfliteFitnessLocalDataSource.new)
    ..registerLazySingleton<FitnessRepository>(() => FitnessRepositoryImpl(getIt()))
    ..registerLazySingleton<RecommendationRepository>(() => RecommendationRepositoryImpl(getIt(), getIt()))
    ..registerFactory<FitnessBloc>(() => FitnessBloc(getIt(), getIt(), getIt(), getIt(), getIt()));
}
