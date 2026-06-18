import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class FirebaseTelemetryService {
  bool _enabled = false;

  Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      _enabled = true;

      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        unawaited(recordError(error, stack, fatal: true));
        return true;
      };
    } catch (error) {
      debugPrint('Firebase telemetry disabled: $error');
    }
  }

  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    if (!_enabled) return;
    await FirebaseAnalytics.instance.logEvent(name: name, parameters: parameters);
  }

  Future<void> recordError(Object error, StackTrace stackTrace, {bool fatal = false}) async {
    if (!_enabled) return;
    await FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: fatal);
  }
}
