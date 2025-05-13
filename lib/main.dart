import 'package:endgame/homepage.dart';
import 'package:endgame/pages/auth/first_screen.dart';
import 'package:endgame/pages/admin/admin_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:endgame/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize notification service
  await NotificationService().initNotifications();
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Check if user or admin is already logged in
  final prefs = await SharedPreferences.getInstance();
  final String? userToken = prefs.getString('token');
  final String? adminToken = prefs.getString('adminToken');
  
  final bool isUserLoggedIn = userToken != null;
  final bool isAdminLoggedIn = adminToken != null;

  runApp(MyApp(
    isUserLoggedIn: isUserLoggedIn,
    isAdminLoggedIn: isAdminLoggedIn
  ));
}

class MyApp extends StatelessWidget {
  final bool isUserLoggedIn;
  final bool isAdminLoggedIn;
  
  const MyApp({
    super.key, 
    required this.isUserLoggedIn,
    required this.isAdminLoggedIn
  });

  @override
  Widget build(BuildContext context) {
    // Determine initial route based on login status
    String initialRoute;
    if (isAdminLoggedIn) {
      initialRoute = '/admin/home';
    } else if (isUserLoggedIn) {
      initialRoute = '/home';
    } else {
      initialRoute = '/login';
    }
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: initialRoute,
      routes: {
        '/home': (context) => const HomePage(),
        '/login': (context) => const FirstScreen(),
        '/admin/home': (context) => const AdminHome(),
      },
    );
  }
}