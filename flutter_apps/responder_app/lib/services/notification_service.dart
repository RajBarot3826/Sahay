// Sahay Responder Notification Service
// Handles emergency dispatch notifications, mission updates, and system alerts.
// Works in all app states: foreground, background, and terminated.

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';

@pragma('vm:entry-point')
void onDidReceiveBackgroundNotificationResponse(NotificationResponse response) {
  debugPrint('Background notification tapped: ${response.payload}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // Channel IDs
  static const String dispatchChannelId = 'sos_dispatch_channel';
  static const String dispatchChannelName = 'Emergency Dispatch';
  static const String dispatchChannelDesc = 'Critical SOS emergency dispatch notifications';

  static const String missionChannelId = 'mission_updates_channel';
  static const String missionChannelName = 'Mission Updates';
  static const String missionChannelDesc = 'Mission phase and status updates';

  static const String systemChannelId = 'system_channel';
  static const String systemChannelName = 'System Notifications';
  static const String systemChannelDesc = 'Shift reports and system messages';

  Function(String? payload)? onNotificationTap;

  Future<void> initialize() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification tapped: ${response.payload}');
        onNotificationTap?.call(response.payload);
      },
      onDidReceiveBackgroundNotificationResponse: onDidReceiveBackgroundNotificationResponse,
    );

    final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      // Emergency Dispatch Channel — MAX priority, alarm
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          dispatchChannelId,
          dispatchChannelName,
          description: dispatchChannelDesc,
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          enableLights: true,
          ledColor: Color(0xFFFF0000),
          showBadge: true,
        ),
      );

      // Mission Updates Channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          missionChannelId,
          missionChannelName,
          description: missionChannelDesc,
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
          showBadge: true,
        ),
      );

      // System Channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          systemChannelId,
          systemChannelName,
          description: systemChannelDesc,
          importance: Importance.defaultImportance,
          playSound: true,
        ),
      );
    }

    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  /// Show a CRITICAL emergency dispatch notification — wakes device
  Future<void> showEmergencyNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      dispatchChannelId,
      dispatchChannelName,
      channelDescription: dispatchChannelDesc,
      importance: Importance.max,
      priority: Priority.max,
      ticker: 'EMERGENCY SOS DISPATCH',
      visibility: NotificationVisibility.public,
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: true,
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000, 500, 1000]),
      ongoing: false,
      autoCancel: true,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFFEF4444),
      colorized: true,
      styleInformation: BigTextStyleInformation(
        body,
        htmlFormatBigText: false,
        contentTitle: title,
        htmlFormatContentTitle: false,
        summaryText: 'Sahay Emergency Dispatch',
      ),
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      NotificationDetails(android: androidDetails),
      payload: data != null ? jsonEncode(data) : null,
    );
  }

  /// Show mission update notification
  Future<void> showMissionNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    final details = AndroidNotificationDetails(
      missionChannelId,
      missionChannelName,
      channelDescription: missionChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'Mission Update',
      visibility: NotificationVisibility.public,
      playSound: true,
      enableVibration: true,
      autoCancel: true,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFF7C3AED),
      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
      ),
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      NotificationDetails(android: details),
      payload: data != null ? jsonEncode(data) : null,
    );
  }

  /// Show system notification (shift reports, etc.)
  Future<void> showSystemNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      systemChannelId,
      systemChannelName,
      channelDescription: systemChannelDesc,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      autoCancel: true,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF7C3AED),
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      const NotificationDetails(android: androidDetails),
    );
  }

  /// Write notification to Firestore
  static Future<void> writeNotificationToFirestore({
    required String responderPhone,
    required String title,
    required String body,
    required String type,
    required String category,
    String? emergencyId,
  }) async {
    if (responderPhone.isEmpty) return;
    try {
      await FirebaseFirestore.instance
          .collection('responders')
          .doc(responderPhone)
          .collection('notifications')
          .add({
        'title': title,
        'body': body,
        'type': type,
        'category': category,
        'emergencyId': emergencyId,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });
    } catch (e) {
      debugPrint('Error writing notification: $e');
    }
  }

  Future<void> cancelAll() async {
    await _localNotifications.cancelAll();
  }
}
