// Sahay Citizen Notification Service
// Handles all local notifications, Android channels, and Firestore persistence.

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Top-level function for background notification tap handling
@pragma('vm:entry-point')
void onDidReceiveBackgroundNotificationResponse(NotificationResponse response) {
  // Background tap handling — navigation is done via getInitialMessage/onMessageOpenedApp
  debugPrint('Background notification tapped: ${response.payload}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // Notification channel IDs
  static const String sosChannelId = 'sos_emergency_channel';
  static const String sosChannelName = 'SOS Emergency Alerts';
  static const String sosChannelDesc = 'Critical emergency SOS notifications with alarm sound';

  static const String updatesChannelId = 'sahay_updates_channel';
  static const String updatesChannelName = 'Status Updates';
  static const String updatesChannelDesc = 'Responder status and emergency updates';

  // Callback for notification tap navigation
  Function(String? payload)? onNotificationTap;

  Future<void> initialize() async {
    // Android initialization
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

    // Create notification channels
    final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      // SOS Emergency Channel — Critical priority
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          sosChannelId,
          sosChannelName,
          description: sosChannelDesc,
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          enableLights: true,
          ledColor: Color(0xFFFF0000),
          showBadge: true,
        ),
      );

      // Updates Channel — Default priority
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          updatesChannelId,
          updatesChannelName,
          description: updatesChannelDesc,
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
          showBadge: true,
        ),
      );
    }
  }

  /// Show a high-priority SOS notification (used in foreground + background)
  Future<void> showSOSNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      sosChannelId,
      sosChannelName,
      channelDescription: sosChannelDesc,
      importance: Importance.max,
      priority: Priority.max,
      ticker: 'SOS Emergency',
      visibility: NotificationVisibility.public,
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: true,
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500, 200, 500]),
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

  /// Show a status update notification (responder accepted, resolved, etc.)
  Future<void> showStatusNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      updatesChannelId,
      updatesChannelName,
      channelDescription: updatesChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'Sahay Update',
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
      NotificationDetails(android: androidDetails),
      payload: data != null ? jsonEncode(data) : null,
    );
  }

  /// Write a notification record to Firestore for persistence
  static Future<void> writeNotificationToFirestore({
    required String userId,
    required String title,
    required String body,
    required String type,
    required String category,
    String? emergencyId,
  }) async {
    if (userId.isEmpty) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
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

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _localNotifications.cancelAll();
  }
}
