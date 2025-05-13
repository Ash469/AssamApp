import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart'; // Required for Firebase.initializeApp in background

// This handler is called when the app is in background
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `Firebase.initializeApp` before using other Firebase services.
  // It's good practice to ensure it's initialized here if this handler might be
  // the first entry point for Firebase in a background isolate.
  await Firebase.initializeApp(); // Ensure Firebase is initialized in this isolate.

  print("BACKGROUND HANDLER: Message received!");
  print("BACKGROUND HANDLER: Message ID: ${message.messageId}");
  print("BACKGROUND HANDLER: Notification Title: ${message.notification?.title}");
  print("BACKGROUND HANDLER: Notification Body: ${message.notification?.body}");
  print("BACKGROUND HANDLER: Data payload: ${message.data}");

  // For "notification" messages received when the app is in the background or terminated,
  // FCM automatically displays the notification in the system tray.
  // This handler is called when the message is received, not necessarily when it's tapped.
  // If you need to show a custom local notification for background messages (e.g. for data-only messages),
  // you would initialize and use flutter_local_notifications here.
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  
  factory NotificationService() => _instance;
  
  NotificationService._internal();
  
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();
  
  String? _fcmToken;
  bool _permissionDenied = false;
  
  bool get permissionDenied => _permissionDenied;
  
  // Initialize notification channels and request permissions
  Future<void> initNotifications() async {
    // Request permission
    final permissionStatus = await _checkNotificationPermissionStatus();
    
    if (permissionStatus == PermissionStatus.granted) {
      await _setupNotificationServices();
    } else {
      _permissionDenied = true;
      print("Notification permission denied or restricted. FCM functionality limited.");
      // Still try to get token, but notifications won't show
      await _getAndStoreToken();
    }
  }
  
  // Check current permission status
  Future<PermissionStatus> _checkNotificationPermissionStatus() async {
    final status = await Permission.notification.status;
    print("Current notification permission status: $status");
    return status;
  }
  
  // Request permission to show notifications
  Future<bool> _requestNotificationPermissions() async {
    try {
      final status = await Permission.notification.request();
      print("Notification permission request result: $status");
      
      if (status.isGranted) {
        // Request FCM authorization for iOS
        NotificationSettings settings = await _firebaseMessaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        );
        
        print('FCM authorization status: ${settings.authorizationStatus}');
        
        // If permissions were previously denied but now granted
        if (_permissionDenied) {
          _permissionDenied = false;
          await _setupNotificationServices();
        }
        
        return true;
      } else {
        _permissionDenied = true;
        return false;
      }
    } catch (e) {
      print("Error requesting notification permissions: $e");
      return false;
    }
  }
  
  // Setup notification services after permissions are granted
  Future<void> _setupNotificationServices() async {
    // Set up foreground notification presentation options
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );
    
    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS = 
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
    
    // Set up handlers for different notification scenarios
    FirebaseMessaging.instance.getInitialMessage().then(_handleInitialMessage);
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Get the token for this device
    await _getAndStoreToken();

    // Explicitly subscribe to the 'all_users' topic to match backend sending
    try {
      await FirebaseMessaging.instance.subscribeToTopic('all_users');
      print("NotificationService: Successfully subscribed to topic 'all_users'");
    } catch (e) {
      print("NotificationService: Failed to subscribe to topic 'all_users': $e");
    }
  }
  
  // Show dialog to request notification permission
  Future<void> showPermissionRequestDialog(BuildContext context) async {
    if (_permissionDenied) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Enable Notifications'),
            content: const Text(
              'Notifications are currently disabled. Would you like to enable them to receive important updates?'
            ),
            actions: [
              TextButton(
                child: const Text('Not Now'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Enable'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  
                  // First try the in-app permission request
                  final granted = await _requestNotificationPermissions();
                  
                  // If still denied, open app settings
                  if (!granted) {
                    await openAppSettings();
                  }
                },
              ),
            ],
          );
        },
      );
    }
  }
  
  // Get FCM token and store it
  Future<void> _getAndStoreToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        _fcmToken = token;
        print("FCM Token (Device ID): $_fcmToken"); // Added log
        
        // Store token in shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcmToken', token);
        
        // TODO: Send this token to your server to associate with the user
      } else {
        print("Failed to get FCM token");
      }
      
      // Listen for token refreshes
      _firebaseMessaging.onTokenRefresh.listen((newToken) async {
        _fcmToken = newToken;
        print("FCM Token Refreshed (Device ID): $_fcmToken"); // Added log
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcmToken', newToken);
        
        // TODO: Send the new token to your server
      });
    } catch (e) {
      print("Error getting FCM token: $e");
    }
  }
  
  // Get token (for internal use only)
  Future<String?> getDeviceToken() async {
    if (_fcmToken != null) return _fcmToken;
    
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      if (_fcmToken != null) {
        print("FCM Token (Device ID) from getDeviceToken: $_fcmToken"); // Added log
      }
      return _fcmToken;
    } catch (e) {
      print("Error getting device token: $e");
      return null;
    }
  }
  
  // Handle initial message (app opened from terminated state by notification)
  void _handleInitialMessage(RemoteMessage? message) {
    if (message != null) {
      print("Application opened from terminated state with message: ${message.notification?.title}");
      // Navigate to specific page based on notification data if needed
    }
  }
  
  // Handle foreground messages (app is open)
  void _handleForegroundMessage(RemoteMessage message) {
    print("Received foreground message. ID: ${message.messageId}");
    print("  Notification Title: ${message.notification?.title}");
    print("  Notification Body: ${message.notification?.body}");
    // Log the string representation of the AndroidNotification object
    if (message.notification?.android != null) {
      print("  Notification Android Specifics: Exists (details like channelId: ${message.notification!.android!.channelId})");
    } else {
      print("  Notification Android Specifics: null");
    }
    print("  Data payload: ${message.data}");
    
    if (message.notification != null) {
      _showLocalNotification(message);
    } else {
      print("  Foreground message has no 'notification' payload. Not showing local notification.");
      // If you expect to show notifications from data-only messages in foreground, handle here.
    }
  }
  
  // Handle when user taps on notification that opened the app from background
  void _handleMessageOpenedApp(RemoteMessage message) {
    print("App opened from background state with message: ${message.notification?.title}");
    // Navigate to specific page based on notification data if needed
  }
  
  // Handle notification response (when user taps on local notification)
  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    print("Local notification tapped: ${response.payload}");
    // Navigate based on payload if needed
  }
  
  // Show a local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final RemoteNotification? notification = message.notification; 
    final AndroidNotification? android = message.notification?.android; // For logging

    print("_showLocalNotification: Attempting to show local notification.");
    print("  Message ID: ${message.messageId}"); // Log message ID
    print("  Notification Title from RemoteMessage: ${notification?.title}"); 
    print("  Notification Body from RemoteMessage: ${notification?.body}");   
    if (android != null) {
      print("  Android Specifics from RemoteMessage: Exists (details like channelId: ${android.channelId})");
    } else {
      print("  Android Specifics from RemoteMessage: null (This is okay, we'll use default local notification settings)");
    }

    // Changed condition: Only require 'notification' to be non-null.
    // 'android' (from message.notification.android) is not strictly needed
    // as we define AndroidNotificationDetails manually for flutter_local_notifications.
    if (notification != null) { 
      print("  Condition (notification != null) is TRUE. Proceeding to show.");
      try {
        await _flutterLocalNotificationsPlugin.show(
          notification.hashCode, // Unique ID for the notification
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel', // Channel ID
              'High Importance Notifications', // Channel Name
              channelDescription: 'This channel is used for important notifications.',
              importance: Importance.high,
              priority: Priority.high,
              ticker: 'ticker',
              // icon: '@mipmap/ic_launcher', // Ensure this icon exists if uncommented
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: message.data['route'], // Optional: data to pass when notification is tapped
        );
        print("  flutter_local_notifications.show() called successfully for notification ID: ${notification.hashCode}.");
      } catch (e) {
        print("  Error calling flutter_local_notifications.show(): $e");
      }
    } else {
      // This case should ideally not be hit if _handleForegroundMessage calls this,
      // as it already checks message.notification != null.
      print("  Condition (notification != null) is FALSE. Local notification NOT shown.");
      print("    Reason: message.notification was null (unexpected at this point if called from _handleForegroundMessage).");
    }
  }
  
  // Subscribe to a topic (for topic-based notifications)
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    print('Subscribed to topic: $topic');
  }
  
  // Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    print('Unsubscribed from topic: $topic');
  }
}
