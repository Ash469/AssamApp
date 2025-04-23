import 'package:flutter/material.dart';
import 'package:endgame/components/app_bar.dart';
import 'package:endgame/components/app_drawer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: const CustomAppBar(title: 'About'),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [

            // About Content - Improved for mobile
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Our Story',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF115E59),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Founded in 2023, our office dashboard platform was created to address the challenges of modern workplace management. We recognized that organizations needed a centralized solution to handle applications, requests, and administrative tasks efficiently.',
                    style: TextStyle(
                      color: Colors.black87,
                      height: 1.5,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Our Mission',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF115E59),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'We are committed to transforming office management through technology. Our mission is to provide organizations with tools that reduce administrative burden, increase transparency, and improve employee satisfaction.',
                    style: TextStyle(
                      color: Colors.black87,
                      height: 1.5,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Feature Cards - Optimized for mobile
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              color: Colors.grey.shade50, // Lighter background for mobile
              child: Column(
                children: [
                  const Text(
                    'What Sets Us Apart',
                    style: TextStyle(
                      fontSize: 22, 
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF115E59),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // Feature cards in a more mobile-friendly format
                  _buildMobileFeatureCard(
                    FontAwesomeIcons.building, 
                    'Streamlined Workflows',
                    'We simplify complex office processes into intuitive, user-friendly workflows.',
                    theme,
                  ),
                  const SizedBox(height: 16),
                  _buildMobileFeatureCard(
                    FontAwesomeIcons.users, 
                    'User-Centered Design',
                    'Our platform is designed with users in mind, ensuring a smooth and intuitive experience.',
                    theme,
                  ),
                  const SizedBox(height: 16),
                  _buildMobileFeatureCard(
                    FontAwesomeIcons.headset, 
                    'Dedicated Support',
                    'Our team is always ready to help you get the most out of our platform.',
                    theme,
                  ),
                  const SizedBox(height: 16), // Bottom padding
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Redesigned feature card that's more mobile-appropriate
  Widget _buildMobileFeatureCard(IconData icon, String title, String description, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon container
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF115E59),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
