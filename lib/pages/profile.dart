import 'package:flutter/material.dart';
import 'package:endgame/components/app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:endgame/pages/auth/first_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> _userData = {};
  bool _isLoading = true;
  String? _errorMessage;
  final String apiBaseUrl = dotenv.env['BACKEND_URL'] ?? 'http://10.150.54.176:3000';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        // No token, redirect to login
        _navigateToLogin();
        return;
      }
      
      // Extract user ID from token if possible (similar to jwt_decode in JavaScript)
      String? userId;
      try {
        // Basic parsing of JWT token (simplified version)
        final parts = token.split('.');
        if (parts.length > 1) {
          final payload = parts[1];
          final normalized = base64Url.normalize(payload);
          final decodedPayload = utf8.decode(base64Url.decode(normalized));
          final payloadMap = json.decode(decodedPayload);
          
          // Try different common JWT fields for user ID
          userId = payloadMap['id'] ?? payloadMap['userId'] ?? 
                   payloadMap['_id'] ?? payloadMap['sub'];
        }
      } catch (e) {
        print('Error decoding token: $e');
      }
      
      // Make the API call to get the full user profile
      final response = await http.get(
        Uri.parse('$apiBaseUrl/api/getnewsignup'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['users'] != null && 
            responseData['users'] is List && 
            responseData['users'].isNotEmpty) {
          
          Map<String, dynamic>? loggedInUserData;
          
          // Find the logged-in user by userId if we have it
          if (userId != null) {
            for (var user in responseData['users']) {
              if ((user['_id'] == userId || user['userId'] == userId) && user is Map<String, dynamic>) {
                loggedInUserData = user;
                break;
              }
            }
          }
          
          // If we couldn't find the user by ID, use the first user
          if (loggedInUserData == null) {
            loggedInUserData = responseData['users'][0];
            print('Logged in user not found in user list, showing first user');
          }
          
          // Update the state with the user data
          setState(() {
            _userData = loggedInUserData!;
            _isLoading = false;
          });
          
          // Store the complete user data for future use
          await prefs.setString('userData', json.encode(_userData));
        } else {
          throw Exception('No user data found');
        }
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        await prefs.remove('token');
        await prefs.remove('userData');
        _navigateToLogin();
      } else {
        throw Exception('Failed to fetch user profile: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      
      // Try to load stored data as fallback
      try {
        final prefs = await SharedPreferences.getInstance();
        final userDataString = prefs.getString('userData');
        
        if (userDataString != null) {
          setState(() {
            _userData = json.decode(userDataString);
            _errorMessage = 'Using cached data. Pull down to refresh.';
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to load profile data'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (fallbackError) {
        // If all attempts fail, navigate to login
        _navigateToLogin();
      }
    }
  }

  Future<void> _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('userData');
      
      _navigateToLogin();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logout failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToLogin() {
    // Navigate to FirstScreen which is the authentication entry point
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const FirstScreen()),
      (route) => false
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'My Profile'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUserData,
              child: _errorMessage != null && _userData.isEmpty
                  ? _buildErrorState()
                  : _buildProfileContent(),
            ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'Error: $_errorMessage',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadUserData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(1, 103, 104, 1),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile avatar
          CircleAvatar(
            radius: 60,
            backgroundColor: const Color.fromRGBO(1, 103, 104, 0.2),
            child: Text(
              _getInitials(),
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(1, 103, 104, 1),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // User name
          Text(
            _getFullName(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(20, 48, 74, 1),
            ),
            textAlign: TextAlign.center,
          ),
          
          // User ID
          Text(
            '@${_userData['userId'] ?? ''}',
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
            onPressed: _showLogoutConfirmation,
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
          _buildInfoTile(Icons.person, 'Name', _getFullName()),
          _buildInfoDivider(),
          _buildInfoTile(Icons.phone, 'Phone', _userData['contactNumber'] ?? 'Not provided'),
          _buildInfoDivider(),
          _buildInfoTile(Icons.account_circle, 'User ID', _userData['userId'] ?? 'Not provided'),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: const Color.fromRGBO(1, 103, 104, 1), size: 26),
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

  Future<void> _showLogoutConfirmation() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const SingleChildScrollView(
            child: Text('Are you sure you want to logout?'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
            ),
          ],
        );
      },
    );
  }

  String _getInitials() {
    final firstName = _userData['firstName'] as String? ?? '';
    final lastName = _userData['lastName'] as String? ?? '';
    
    String initials = '';
    if (firstName.isNotEmpty) {
      initials += firstName[0].toUpperCase();
    }
    if (lastName.isNotEmpty) {
      initials += lastName[0].toUpperCase();
    }
    
    return initials.isEmpty ? '?' : initials;
  }

  String _getFullName() {
    final firstName = _userData['firstName'] as String? ?? '';
    final lastName = _userData['lastName'] as String? ?? '';
    
    return '$firstName $lastName'.trim();
  }
}