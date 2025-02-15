import 'homepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:endgame/pages/front_page.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter binding is initialized
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage()
          );
  }
}