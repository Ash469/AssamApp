import 'package:endgame/components/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fl_chart/fl_chart.dart';

import 'admin_application.dart';
import 'admin_notification.dart';
import 'admin_user.dart';
import 'admin_profile.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final String apiBaseUrl = dotenv.env['BACKEND_URL'] ?? 'http://10.150.54.176:3000';
  String adminName = '';
  int totalUsers = 0;
  int verifiedUsers = 0;
  int totalApplications = 0;
  int approvedApplications = 0;
  int pendingApplications = 0;
  int rejectedApplications = 0;
  bool isLoading = true;
  Map<String, int> categoryDistribution = {};

  @override
  void initState() {
    super.initState();
    _loadAdminData();
    _fetchUserData();
    _fetchApplicationData();
  }

  Future<void> _loadAdminData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('userData');
    if (userDataString != null) {
      final userData = json.decode(userDataString);
      setState(() {
        adminName = userData['firstName'] ?? 'Admin';
      });
    }
  }

  Future<void> _fetchUserData() async {
    try {
      final response = await http.get(Uri.parse('$apiBaseUrl/api/getnewsignup'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> users = data['users'];
        
        int verified = 0;
        for (var user in users) {
          if (user['verified'] == true) {
            verified++;
          }
        }
        
        setState(() {
          totalUsers = users.length;
          verifiedUsers = verified;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching user data: $e');
    }
  }

  Future<void> _fetchApplicationData() async {
    try {
      final response = await http.get(Uri.parse('$apiBaseUrl/api/applications'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> data = responseData['data'] ?? [];
        
        // Reset distributions
        categoryDistribution.clear();
        int approved = 0, pending = 0, rejected = 0;
        
        for (var app in data) {
          // Status counting
          switch (app['status']?.toLowerCase()) {
            case 'approved': approved++; break;
            case 'pending': pending++; break;
            case 'rejected': rejected++; break;
          }
          
          // Category counting
          final category = app['category'] as String? ?? 'Unknown';
          categoryDistribution[category] = (categoryDistribution[category] ?? 0) + 1;
        }
        
        setState(() {
          totalApplications = data.length;
          approvedApplications = approved;
          pendingApplications = pending;
          rejectedApplications = rejected;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching application data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(380), 
        child: Stack(
          clipBehavior: Clip.none,
          children: [      
            Container(
              height: 800,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/app_bar.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 60, 16, 22),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Builder(
                          builder: (context) => GestureDetector(
                            onTap: () {
                              Scaffold.of(context).openDrawer();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const CircleAvatar(
                                radius: 40,
                                backgroundImage: AssetImage('assets/logo.jpg'),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.settings,
                              color: Colors.white,
                              size: 24,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AdminProfilePage(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome Admin',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 26,
                                    letterSpacing: 1.5,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Admin Dashboard',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.white.withOpacity(0.8),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    letterSpacing: 0.8,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 250, // Reduced from 300
              left: 0,
              right: 0,
              child: Column(
                children: [
                  _buildAdminDashboard(),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildStatCards(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminDashboard() {
    return SizedBox(
      height: 160, // Fixed height instead of 350
      child: Column(
        mainAxisSize: MainAxisSize.min, // Added this
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 18),
            padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.0,
                  children: [
                    _buildMenuItem(
                      icon: const Icon(
                        Icons.description,
                        size: 38,
                        color: Colors.deepPurple,
                      ),
                      label: 'Application\nManagement',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminApplication(),
                        ),
                      ),
                      iconColor: Colors.deepPurple[600]!,
                      bgColor: Colors.deepPurple[50]!,
                    ),
                    _buildMenuItem(
                      icon: const Icon(
                        Icons.notifications_active,
                        size: 38,
                        color: Colors.amber,
                      ),
                      label: 'Notification\nManagement',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminNotification(),
                        ),
                      ),
                      iconColor: Colors.amber[800]!,
                      bgColor: Colors.amber[50]!,
                    ),
                    _buildMenuItem(
                      icon: const Icon(
                        Icons.people,
                        size: 38,
                        color: Colors.teal,
                      ),
                      label: 'User\nManagement',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminUser(),
                        ),
                      ),
                      iconColor: Colors.teal[600]!,
                      bgColor: Colors.teal[50]!,
                    ),
                  ],
                ),
              ],
            ),
          ),
        
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required Widget icon,
    required String label,
    required VoidCallback onTap,
    required Color iconColor,
    required Color bgColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(36),
            ),
            child: icon,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              height: 1.2,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), // Removed top padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Total Users',
                  value: isLoading ? 'Loading...' : totalUsers.toString(),
                  icon: Icons.people,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: 'Verified Users',
                  value: isLoading ? 'Loading...' : verifiedUsers.toString(),
                  icon: Icons.verified_user,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Total Applications',
                  value: totalApplications.toString(),
                  icon: Icons.description,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: 'Approved',
                  value: approvedApplications.toString(),
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Pending',
                  value: pendingApplications.toString(),
                  icon: Icons.pending_actions,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: 'Rejected',
                  value: rejectedApplications.toString(),
                  icon: Icons.cancel,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // if (!isLoading && totalApplications > 0)
          //   _buildCategoryChart(),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChart() {
    if (categoryDistribution.isEmpty) {
      return const Center(child: Text('No category data available'));
    }
    
    final List<PieChartSectionData> sections = [];
    final List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.purple,
      Colors.amber,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    
    int colorIndex = 0;
    categoryDistribution.forEach((category, count) {
      final double percentage = count / totalApplications;
      sections.add(
        PieChartSectionData(
          color: colors[colorIndex % colors.length],
          value: percentage * 100,
          title: '${(percentage * 100).toStringAsFixed(1)}%',
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      colorIndex++;
    });
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category Distribution',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 1.5,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 8,
            children: categoryDistribution.entries.map((entry) {
              final index = categoryDistribution.keys.toList().indexOf(entry.key);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[index % colors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${entry.key} (${entry.value})',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}