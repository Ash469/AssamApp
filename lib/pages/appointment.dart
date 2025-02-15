import 'package:flutter/material.dart';
import 'package:endgame/components/app_bar.dart';

class AppointmentPage extends StatelessWidget {
  const AppointmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: 'Appointment'),
      body: Center(
        child: Text('Appointment Page'),
      ),
    );
  }
}