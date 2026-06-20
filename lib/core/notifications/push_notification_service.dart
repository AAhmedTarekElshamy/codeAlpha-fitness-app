import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class PushNotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings();

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: darwin, macOS: darwin),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _initializeFirebaseMessaging();
  }

  Future<String?> getPushToken() async {
    if (Firebase.apps.isEmpty) return null;

    try {
      return FirebaseMessaging.instance.getToken();
    } catch (error) {
      debugPrint('Firebase Messaging token unavailable: $error');
      return null;
    }
  }

  Future<void> showGoalReached(String title, String body) async {
    const android = AndroidNotificationDetails(
      'fitness_goals',
      'Fitness goals',
      channelDescription: 'Goal progress and workout reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    const darwin = DarwinNotificationDetails();

    await _plugin.show(
      1001,
      title,
      body,
      const NotificationDetails(android: android, iOS: darwin, macOS: darwin),
    );
  }

  Future<void> _initializeFirebaseMessaging() async {
    if (Firebase.apps.isEmpty) return;

    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();

      FirebaseMessaging.onMessage.listen((message) {
        final notification = message.notification;
        if (notification == null) return;

        unawaited(
          showGoalReached(
            notification.title ?? 'PulseFit',
            notification.body ?? 'You have a new fitness update.',
          ),
        );
      });
    } catch (error) {
      debugPrint('Firebase Messaging disabled: $error');
    }
  }
}
