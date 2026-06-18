import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'views/shared/theme.dart';
import 'viewmodels/fitness_viewmodel.dart';
import 'views/dashboard/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PulseFitApp());
}

class PulseFitApp extends StatelessWidget {
  const PulseFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FitnessViewModel(),
      child: MaterialApp(
        title: 'PulseFit - Fitness Tracker',
        theme: FitnessTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const DashboardScreen(),
      ),
    );
  }
}
