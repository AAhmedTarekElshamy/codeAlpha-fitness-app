import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class FirebaseTelemetryService {
  static const _firebaseEnabled = bool.fromEnvironment('ENABLE_FIREBASE');

  bool _enabled = false;

  Future<void> initialize() async {
    if (!_firebaseEnabled) {
      debugPrint('Firebase telemetry disabled: run with --dart-define=ENABLE_FIREBASE=true after Firebase setup.');
      return;
    }

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
