import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/notifications/push_notification_service.dart';
import 'core/telemetry/firebase_telemetry_service.dart';
import 'features/fitness/presentation/bloc/fitness_bloc.dart';
import 'injection.dart';
import 'views/shared/theme.dart';
import 'views/dashboard/dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  await getIt<FirebaseTelemetryService>().initialize();
  await getIt<PushNotificationService>().initialize();

  runApp(const PulseFitApp());
}

class PulseFitApp extends StatelessWidget {
  const PulseFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<FitnessBloc>()..add(const FitnessStarted()),
      child: MaterialApp(
        title: 'PulseFit - Fitness Tracker',
        theme: FitnessTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const DashboardScreen(),
      ),
    );
  }
}
