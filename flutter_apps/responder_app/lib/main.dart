// Sahay Responder App — Real-World Emergency Response
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'screens/responder_login_screen.dart';
import 'screens/responder_dashboard.dart';
import 'constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'providers/responder_state.dart';
import 'services/firebase_dispatch_service.dart';
import 'services/location_tracking_service.dart';
import 'dart:convert';
import 'services/notification_service.dart';

// Global keys for notification navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Background SOS message: ${message.messageId}");

  final notificationService = NotificationService();
  await notificationService.initialize();

  final title = message.notification?.title ?? message.data['title'] ?? '🚨 SOS Alert';
  final body = message.notification?.body ?? message.data['body'] ?? 'New emergency nearby!';
  final type = message.data['type'] ?? '';

  if (type == 'new_emergency') {
    await notificationService.showEmergencyNotification(title: title, body: body, data: message.data);
  } else if (type == 'emergency_resolved' || type == 'emergency_cancelled') {
    await notificationService.showMissionNotification(title: title, body: body, data: message.data);
  } else {
    await notificationService.showMissionNotification(title: title, body: body, data: message.data);
  }

  // Persist to Firestore — read phone from SharedPreferences since Provider isn't available
  try {
    final prefs = await SharedPreferences.getInstance();
    final responderPhone = prefs.getString('resp_phone') ?? '';
    if (responderPhone.isNotEmpty) {
      await NotificationService.writeNotificationToFirestore(
        responderPhone: responderPhone,
        title: title,
        body: body,
        type: type,
        category: type == 'new_emergency' ? 'Emergency' : 'Mission Updates',
        emergencyId: message.data['emergencyId'],
      );
    }
  } catch (e) {
    debugPrint('Background notification persistence error: $e');
  }
}

/// Show foreground SOS notification banner
void _showForegroundNotification(String title, String body) {
  scaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.white)),
                Text(body, style: const TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.emergencyRed,
      duration: const Duration(seconds: 8),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      action: SnackBarAction(
        label: 'VIEW',
        textColor: Colors.white,
        onPressed: () {
          // Navigate to dashboard where emergency popup will auto-show
          navigatorKey.currentState?.pushNamedAndRemoveUntil('/dashboard', (_) => false);
        },
      ),
    ),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create responderState EARLY so it's available for FCM listener closures
  final firebaseService = FirebaseDispatchService();
  final responderState = ResponderState();
  await responderState.loadProfile();

  // Inject dependencies
  final locationService = LocationTrackingService(firebaseService, responderState);
  responderState.setLocationService(locationService);
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // FCM Setup
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      criticalAlert: true,
      sound: true,
    );

    final notificationService = NotificationService();
    await notificationService.initialize();

    notificationService.onNotificationTap = (payload) {
      if (payload != null) {
        try {
          final data = jsonDecode(payload);
          if (data['type'] == 'new_emergency') {
            navigatorKey.currentState?.pushNamedAndRemoveUntil('/dashboard', (_) => false);
          }
        } catch (_) {}
      }
    };

    // Foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground FCM: ${message.notification?.title}');
      final title = message.notification?.title ?? '🚨 SOS Alert';
      final body = message.notification?.body ?? 'New emergency nearby!';
      final type = message.data['type'] ?? '';

      // Show system notification in tray
      if (type == 'new_emergency') {
        notificationService.showEmergencyNotification(title: title, body: body, data: message.data);
      } else {
        notificationService.showMissionNotification(title: title, body: body, data: message.data);
      }

      // Also show in-app SnackBar
      _showForegroundNotification(title, body);

      // Persist to Firestore — use responderState directly (not Provider.of)
      if (responderState.phone.isNotEmpty) {
        NotificationService.writeNotificationToFirestore(
          responderPhone: responderState.phone,
          title: title,
          body: body,
          type: type,
          category: type == 'new_emergency' ? 'Emergency' : 'Mission Updates',
          emergencyId: message.data['emergencyId'],
        );
      }
    });

    // Notification tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      navigatorKey.currentState?.pushNamedAndRemoveUntil('/dashboard', (_) => false);
    });

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('App opened from terminated via notification');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigatorKey.currentState?.pushNamedAndRemoveUntil('/dashboard', (_) => false);
      });
    }

    // Store FCM token if registered
    if (responderState.isRegistered && responderState.phone.isNotEmpty) {
      try {
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          await FirebaseFirestore.instance
              .collection('responders')
              .doc(responderState.phone)
              .set({'fcmToken': token}, SetOptions(merge: true));
        }
      } catch (_) {}

      // Listen for token refresh — keep Firestore token in sync
      messaging.onTokenRefresh.listen((newToken) async {
        try {
          await FirebaseFirestore.instance
              .collection('responders')
              .doc(responderState.phone)
              .update({
            'fcmToken': newToken,
            'tokenUpdatedAt': FieldValue.serverTimestamp(),
          });
        } catch (_) {}
      });
    }
  } catch (e) {
    debugPrint('Firebase init fallback: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: responderState),
        Provider.value(value: firebaseService),
      ],
      child: const SahayResponderApp(),
    ),
  );
}

class SahayResponderApp extends StatelessWidget {
  const SahayResponderApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: scaffoldMessengerKey,
      title: 'Sahay Responder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        primaryColor: AppColors.primaryPurple,
        scaffoldBackgroundColor: AppColors.backgroundWhite,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primaryPurple,
          secondary: AppColors.emergencyRed,
        ),
      ),
      home: Consumer<ResponderState>(
        builder: (context, state, _) {
          if (state.isRegistered) {
            return const ResponderDashboard();
          }
          return const ResponderLoginScreen();
        },
      ),
      routes: {
        '/login': (context) => const ResponderLoginScreen(),
        '/dashboard': (context) => const ResponderDashboard(),
      },
    );
  }
}
