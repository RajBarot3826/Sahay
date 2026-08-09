  // Sahay Citizen, Driver & Responder App (Flutter — 24 Screens UI Architecture)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'services/notification_service.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/emergency_provider.dart';
import 'providers/location_provider.dart';

import 'constants/app_colors.dart';
import 'screens/registration_flow_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/ai_camera_scan_screen.dart';
import 'screens/ai_analysis_result_screen.dart';
import 'screens/alert_confirmation_screen.dart';
import 'screens/live_tracking_screen.dart';
import 'screens/nearby_responders_screen.dart';
import 'screens/guided_first_aid_screen.dart';
import 'screens/cpr_voice_guide_screen.dart';
import 'screens/live_ai_first_aid_doctor_screen.dart';
import 'screens/hospitals_nearby_screen.dart';
import 'screens/hospital_pre_alert_screen.dart';
import 'screens/good_samaritan_protection_screen.dart';
import 'screens/learn_train_screen.dart';
import 'screens/community_volunteer_screen.dart';
import 'screens/incident_history_screen.dart';
import 'screens/rewards_badges_screen.dart';
import 'screens/family_sos_screen.dart';
import 'screens/emergency_contacts_screen.dart';
import 'screens/offline_mode_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/impact_dashboard_screen.dart';
import 'screens/user_profile_screen.dart';
import 'screens/ai_scan_screen.dart';
import 'screens/impact_profile_screen.dart';

// Global navigator key for FCM notification tap navigation
final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

// Global scaffold messenger key for foreground notifications
final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Shows an in-app banner when SOS notification arrives while app is open.
void _showForegroundNotification(String title, String body, Map<String, dynamic> data) {
  _scaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.notification_important_rounded, color: Colors.white, size: 20),
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
      duration: const Duration(seconds: 5),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      action: SnackBarAction(
        label: 'VIEW',
        textColor: Colors.white,
        onPressed: () {
          if (data['type'] == 'sos') {
            _navigatorKey.currentState?.pushNamed('/alert_confirmation');
          }
        },
      ),
    ),
  );
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Handling a background message: ${message.messageId}");

  // Show local notification even when app is in background
  final notificationService = NotificationService();
  await notificationService.initialize();

  final title = message.notification?.title ?? message.data['title'] ?? 'Sahay Alert';
  final body = message.notification?.body ?? message.data['body'] ?? 'You have a new notification';
  final type = message.data['type'] ?? '';

  if (type == 'new_emergency' || type == 'sos') {
    await notificationService.showSOSNotification(title: title, body: body, data: message.data);
  } else {
    await notificationService.showStatusNotification(title: title, body: body, data: message.data);
  }

  // Persist to Firestore — use targetUserId from Cloud Function, or fallback to current auth user
  String userId = message.data['targetUserId'] ?? '';
  if (userId.isEmpty) {
    try {
      userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    } catch (_) {}
  }
  if (userId.isNotEmpty) {
    await NotificationService.writeNotificationToFirestore(
      userId: userId,
      title: title,
      body: body,
      type: type,
      category: type == 'sos' || type == 'new_emergency' ? 'Alerts' : 'Updates',
      emergencyId: message.data['emergencyId'],
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Auth State before showing app
  final authProvider = AuthProvider();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await authProvider.checkLoginStatus();

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    // Store FCM token in Firestore for cross-device SOS notifications
    final String? fcmToken = await messaging.getToken();
    if (fcmToken != null) {
      debugPrint('FCM Token obtained for SOS notifications');
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'fcmToken': fcmToken,
            'tokenUpdatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      } catch (_) {
        // Token storage is best-effort
      }
    }

    // Listen for token refresh
    messaging.onTokenRefresh.listen((newToken) async {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'fcmToken': newToken,
            'tokenUpdatedAt': FieldValue.serverTimestamp(),
          });
        }
      } catch (_) {}
    });

    // Initialize local notification service
    final notificationService = NotificationService();
    await notificationService.initialize();

    // Handle notification tap navigation
    notificationService.onNotificationTap = (payload) {
      if (payload != null) {
        try {
          final data = jsonDecode(payload);
          final type = data['type'] ?? '';
          if (type == 'responder_accepted' || type == 'sos' || type == 'new_emergency') {
            _navigatorKey.currentState?.pushNamed('/alert_confirmation');
          } else if (type == 'emergency_resolved') {
            _navigatorKey.currentState?.pushNamed('/notifications');
          }
        } catch (_) {}
      }
    };

    // Handle foreground messages — show local notification + SnackBar
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground FCM: ${message.notification?.title}');
      final title = message.notification?.title ?? message.data['title'] ?? 'SOS Alert';
      final body = message.notification?.body ?? message.data['body'] ?? 'Emergency nearby!';
      final type = message.data['type'] ?? '';

      // Show system notification (appears in tray even if app is open)
      if (type == 'new_emergency' || type == 'sos') {
        notificationService.showSOSNotification(title: title, body: body, data: message.data);
      } else {
        notificationService.showStatusNotification(title: title, body: body, data: message.data);
      }

      // Also show in-app SnackBar
      _showForegroundNotification(title, body, message.data);

      // Persist notification
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        NotificationService.writeNotificationToFirestore(
          userId: currentUser.uid,
          title: title,
          body: body,
          type: type,
          category: type == 'sos' || type == 'new_emergency' ? 'Alerts' : 'Updates',
          emergencyId: message.data['emergencyId'],
        );
      }
    });

    // Handle notification tap when app is in background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification tap opened app: ${message.data}');
      // Navigate to relevant screen based on data
      if (message.data['type'] == 'sos') {
        _navigatorKey.currentState?.pushNamed('/alert_confirmation');
      }
    });

    // Handle notification that launched a killed app
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('App opened from terminated via notification: ${initialMessage.data}');
      // Will navigate after app is built — using a delayed callback
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final type = initialMessage.data['type'] ?? '';
        if (type == 'responder_accepted' || type == 'sos') {
          _navigatorKey.currentState?.pushNamed('/alert_confirmation');
        } else if (type == 'emergency_resolved') {
          _navigatorKey.currentState?.pushNamed('/notifications');
        }
      });
    }

  } catch (e) {
    debugPrint("Firebase init exception (handled gracefully): $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => EmergencyProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
      ],
      child: const SahayCitizenApp(),
    ),
  );
}

class SahayCitizenApp extends StatelessWidget {
  const SahayCitizenApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return MaterialApp(
      navigatorKey: _navigatorKey,
      scaffoldMessengerKey: _scaffoldMessengerKey,
      title: 'Sahay Citizen & Driver',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.brandPurple,
        scaffoldBackgroundColor: AppColors.bgLight,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.brandPurple,
          primary: AppColors.brandPurple,
          secondary: AppColors.emergencyRed,
        ),
        fontFamily: 'Plus Jakarta Sans',
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (!auth.isAuthenticated || auth.isFirstLaunch) {
            return const RegistrationFlowScreen();
          } else {
            return const DashboardScreen();
          }
        },
      ),
      routes: {
        '/registration': (context) => const RegistrationFlowScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/ai_scan': (context) => const AiCameraScanScreen(),
        '/ai_result': (context) => const AiAnalysisResultScreen(),
        '/alert_confirmation': (context) => const AlertConfirmationScreen(),
        '/live_tracking': (context) => const LiveTrackingScreen(),
        '/nearby_responders': (context) => const NearbyRespondersScreen(),
        '/guided_first_aid': (context) => const GuidedFirstAidScreen(),
        '/cpr_voice_guide': (context) => const CprVoiceGuideScreen(),
        '/hospitals_nearby': (context) => const HospitalsNearbyScreen(),
        '/hospital_pre_alert': (context) => const HospitalPreAlertScreen(),
        '/good_samaritan_protection': (context) => const GoodSamaritanProtectionScreen(),
        '/learn_train': (context) => const LearnTrainScreen(),
        '/community_volunteer': (context) => const CommunityVolunteerScreen(),
        '/incident_history': (context) => const IncidentHistoryScreen(),
        '/rewards_badges': (context) => const RewardsBadgesScreen(),
        '/family_sos': (context) => const FamilySosScreen(),
        '/emergency_contacts': (context) => const EmergencyContactsScreen(),
        '/offline_mode': (context) => const OfflineModeScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/impact_dashboard': (context) => const ImpactDashboardScreen(),
        '/user_profile': (context) => const UserProfileScreen(),
        '/ai_scan_old': (context) => const AiScanScreen(),
        '/impact_profile': (context) => const ImpactProfileScreen(),
        '/ai_doctor': (context) => const LiveAiFirstAidDoctorScreen(),
      },
    );
  }
}
