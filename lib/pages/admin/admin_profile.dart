import 'package:flutter/material.dart';
import 'package:endgame/components/app_bar.dart';
import 'package:endgame/pages/auth/first_screen.dart';


class AdminProfilePage extends StatelessWidget {
  const AdminProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Admin Profile'),
      body: _buildProfileContent(context),
    );
  }

  Widget _buildProfileContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile avatar
          CircleAvatar(
            radius: 60,
            backgroundColor: const Color.fromRGBO(103, 58, 183, 0.2),
            child: const Text(
              'JD',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(103, 58, 183, 1),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Admin badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(103, 58, 183, 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color.fromRGBO(103, 58, 183, 1)),
            ),
            child: const Text(
              'ADMINISTRATOR',
              style: TextStyle(
                color: Color.fromRGBO(103, 58, 183, 1),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // User name
          const Text(
            'Admin',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(20, 48, 74, 1),
            ),
            textAlign: TextAlign.center,
          ),
          
          // User ID
          Text(
            '@admin123',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          
          const SizedBox(height: 40),
          
          // User details section
          _buildInfoSection(),
          
          const SizedBox(height: 40),
          
          // Logout button
          ElevatedButton.icon(
            onPressed: () => _navigateToLogin(context),
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              minimumSize: const Size(200, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildInfoTile(Icons.person, 'Name', 'Admin'),
          _buildInfoDivider(),
          _buildInfoTile(Icons.phone, 'Phone', '+91 9801589162'),
          _buildInfoDivider(),
          _buildInfoTile(Icons.admin_panel_settings, 'Role', 'Administrator'),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: const Color.fromRGBO(103, 58, 183, 1), size: 26),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(20, 48, 74, 1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoDivider() {
    return Divider(
      color: Colors.grey.shade200,
      thickness: 1,
    );
  }

  void _navigateToLogin(BuildContext context) {
    // Directly navigate to FirstScreen without confirmation dialog
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const FirstScreen()),
      (route) => false
    );
  }
}