import 'package:flutter/material.dart';
import 'package:endgame/components/app_bar.dart';
import 'package:endgame/components/app_drawer.dart';

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: 'About'),
      drawer: AppDrawer(),
      body: Center(
        child: Text('This is the About Page.'),
      ),
    );
  }
}
