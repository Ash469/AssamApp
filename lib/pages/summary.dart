import 'package:flutter/material.dart';
import 'package:endgame/components/app_bar.dart';

class SummaryPage extends StatelessWidget {
  const SummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: 'SummaryPage'),
      body: Center(
        child: Text('Summary Page'),
      ),
    );
  }
}
