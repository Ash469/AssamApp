import 'package:flutter/material.dart';
import 'package:endgame/components/app_bar.dart';

class Invitation extends StatelessWidget {
  const Invitation({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        appBar: CustomAppBar(title: 'Invitation'),
      body: Center(
        child: Text('Invitation Page'),
      ),
    );
  }
}
