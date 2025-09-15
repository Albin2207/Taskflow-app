import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

// Top-level function to handle background messages
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
  print('Message data: ${message.data}');
  print('Message notification: ${message.notification?.title}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  // Navigation callback - will be set from the main app
  void Function(String route, Map<String, dynamic> data)? onNotificationTap;
  
  // Token callback - for sending to your backend
  void Function(String token)? onTokenReceived;
  
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      print('=== INITIALIZING NOTIFICATION SERVICE ===');
      
      // Request permission for notifications
      await _requestPermission();
      
      // Initialize local notifications
      await _initializeLocalNotifications();
      
      // Configure Firebase messaging
      await _configureFirebaseMessaging();
      
      // Get FCM token
      await _getFCMToken();
      
      _initialized = true;
      print('=== NOTIFICATION SERVICE INITIALIZED SUCCESSFULLY ===');
    } catch (e) {
      print('=== NOTIFICATION SERVICE INITIALIZATION ERROR: $e ===');
      rethrow;
    }
  }

  Future<void> _requestPermission() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print('User granted notification permission: ${settings.authorizationStatus}');
      
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        throw Exception('Notification permissions denied');
      }
    } catch (e) {
      print('Error requesting notification permission: $e');
      rethrow;
    }
  }

  Future<void> _initializeLocalNotifications() async {
    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      final didInit = await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      if (!didInit!) {
        throw Exception('Failed to initialize local notifications');
      }

      // Create notification channel for Android
      if (!kIsWeb) {
        const channel = AndroidNotificationChannel(
          'taskflow_channel',
          'TaskFlow Notifications',
          description: 'Notifications for TaskFlow app',
          importance: Importance.high,
          playSound: true,
        );

        await _localNotifications
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(channel);
      }
          
      print('Local notifications initialized successfully');
    } catch (e) {
      print('Error initializing local notifications: $e');
      rethrow;
    }
  }

  Future<void> _configureFirebaseMessaging() async {
    try {
      // Set background message handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification taps when app is in background/terminated
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // Handle notification tap when app is terminated
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpenedApp(initialMessage);
      }
      
      print('Firebase messaging configured successfully');
    } catch (e) {
      print('Error configuring Firebase messaging: $e');
      rethrow;
    }
  }

  Future<String?> _getFCMToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        print('FCM Token: $token');
        onTokenReceived?.call(token);
        
        // Listen for token refresh
        _firebaseMessaging.onTokenRefresh.listen((newToken) {
          print('FCM Token refreshed: $newToken');
          onTokenReceived?.call(newToken);
        });
      }
      
      return token;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
      
      // Show local notification when app is in foreground
      await _showLocalNotification(
        title: message.notification?.title ?? 'TaskFlow',
        body: message.notification?.body ?? '',
        data: message.data,
      );
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    print('A new onMessageOpenedApp event was published!');
    print('Message data: ${message.data}');
    
    // Handle navigation based on message data
    _handleNotificationNavigation(message.data);
  }

  void _onNotificationTap(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    
    if (response.payload != null) {
      try {
        // Simple parsing - you can make this more sophisticated
        final data = <String, dynamic>{'payload': response.payload};
        _handleNotificationNavigation(data);
      } catch (e) {
        print('Error parsing notification payload: $e');
      }
    }
  }

  void _handleNotificationNavigation(Map<String, dynamic> data) {
    String route = '/home'; // Default route
    
    // Determine route based on notification type
    if (data.containsKey('type')) {
      switch (data['type']) {
        case 'user_created':
        case 'user_updated':
        case 'user_deleted':
        case 'sync_complete':
          route = '/users';
          break;
        case 'profile_update':
          route = '/profile';
          break;
        case 'welcome':
        case 'test':
        case 'network_restored':
        default:
          route = '/home';
      }
    }
    
    // Call navigation callback
    onNotificationTap?.call(route, data);
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'taskflow_channel',
        'TaskFlow Notifications',
        channelDescription: 'Notifications for TaskFlow app',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        platformDetails,
        payload: data != null ? data.toString() : null,
      );
      
      print('Local notification shown: $title - $body');
    } catch (e) {
      print('Error showing local notification: $e');
    }
  }

  // Public methods for sending notifications
  Future<void> showUserCreatedNotification(String userName) async {
    await _showLocalNotification(
      title: '✅ User Created',
      body: 'New user $userName has been added successfully',
      data: {'type': 'user_created', 'action': 'view_users'},
    );
  }

  Future<void> showUserUpdatedNotification(String userName) async {
    await _showLocalNotification(
      title: '📝 User Updated',
      body: 'User $userName information has been updated',
      data: {'type': 'user_updated', 'action': 'view_users'},
    );
  }

  Future<void> showUserDeletedNotification(String userName) async {
    await _showLocalNotification(
      title: '🗑️ User Deleted',
      body: 'User $userName has been removed',
      data: {'type': 'user_deleted', 'action': 'view_users'},
    );
  }

  Future<void> showWelcomeNotification() async {
    await _showLocalNotification(
      title: '🎉 Welcome to TaskFlow!',
      body: 'Start managing your users efficiently',
      data: {'type': 'welcome', 'action': 'open_home'},
    );
  }

  Future<void> showSyncNotification(int userCount) async {
    await _showLocalNotification(
      title: '🔄 Data Synchronized',
      body: '$userCount users have been synchronized successfully',
      data: {'type': 'sync_complete', 'action': 'view_users'},
    );
  }

  Future<void> showNetworkRestoredNotification() async {
    await _showLocalNotification(
      title: '📶 Connection Restored',
      body: 'Internet connection restored. Data synchronized.',
      data: {'type': 'network_restored', 'action': 'open_home'},
    );
  }

  Future<void> showDailySummaryNotification(int userCount) async {
    await _showLocalNotification(
      title: '📊 Daily Summary',
      body: 'You have $userCount users in your system',
      data: {'type': 'daily_summary', 'action': 'view_users'},
    );
  }

  // Test notification method
  Future<void> showTestNotification() async {
    await _showLocalNotification(
      title: '🧪 Test Notification',
      body: 'This is a test notification from TaskFlow - Working perfectly! 🎯',
      data: {'type': 'test', 'action': 'open_home'},
    );
  }

  Future<void> cancelAllNotifications() async {
    try {
      await _localNotifications.cancelAll();
      print('All notifications cancelled');
    } catch (e) {
      print('Error cancelling notifications: $e');
    }
  }

  Future<String?> getFCMToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }
  
  void dispose() {
    _initialized = false;
    onNotificationTap = null;
    onTokenReceived = null;
  }
}