import 'package:flutter/material.dart';
import 'package:endgame/components/bottom_nav.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int myIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BottomNavBar(currentIndex: myIndex),
    );
  }
}