import 'package:flutter/material.dart';
import 'package:endgame/components/app_bar.dart';
import 'package:endgame/components/app_drawer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  final String apiBaseUrl = dotenv.env['BACKEND_URL'] ?? 'http://10.150.54.176:3000';
  List<Map<String, dynamic>> applications = [];
  bool isLoading = true;
  String errorMessage = '';
  
  // Statistics
  int totalApplications = 0;
  int approvedApplications = 0;
  int pendingApplications = 0;
  int rejectedApplications = 0;
  Map<String, int> categoryDistribution = {};
  Map<String, int> districtDistribution = {};
  
  @override
  void initState() {
    super.initState();
    fetchApplications();
  }
  
  Future<void> fetchApplications() async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/api/applications'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> data = responseData['data'] ?? [];
        setState(() {
          applications = List<Map<String, dynamic>>.from(data);
          calculateStatistics();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load applications';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: ${e.toString()}';
      });
    }
  }
  
  void calculateStatistics() {
    totalApplications = applications.length;
    
    // Count statuses
    approvedApplications = applications.where((app) => 
      app['status']?.toLowerCase() == 'approved').length;
    
    pendingApplications = applications.where((app) => 
      app['status']?.toLowerCase() == 'pending').length;
      
    rejectedApplications = applications.where((app) => 
      app['status']?.toLowerCase() == 'rejected').length;
    
    // Calculate category distribution
    categoryDistribution.clear();
    for (var app in applications) {
      final category = app['category'] as String? ?? 'Unknown';
      categoryDistribution[category] = (categoryDistribution[category] ?? 0) + 1;
    }
    
    // Calculate district distribution
    districtDistribution.clear();
    for (var app in applications) {
      final district = app['district'] as String? ?? 'Unknown';
      districtDistribution[district] = (districtDistribution[district] ?? 0) + 1;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(98),
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/app.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: AppBar(
              title: const Text('Summary'),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red)))
              : _buildDashboard(),
      ),
    );
  }
  
  Widget _buildDashboard() {
    return RefreshIndicator(
      onRefresh: fetchApplications,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Applications Overview',
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 16),
            
            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Applications', 
                    totalApplications.toString(),
                    Icons.assignment,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Approved', 
                    approvedApplications.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Pending', 
                    pendingApplications.toString(),
                    Icons.pending,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Rejected', 
                    rejectedApplications.toString(),
                    Icons.cancel,
                    Colors.red,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            const Text(
              'Application Status',
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 16),
            
            // Status Progress
            _buildProgressIndicators(),
            
            const SizedBox(height: 24),
            const Text(
              'Category Distribution',
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 16),
            
            // Category Chart with fixed height
            _buildCategoryChart(),
            
            // Add some bottom padding to avoid overflow
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
                Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: Colors.grey[900],
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProgressIndicators() {
    final approvalRate = totalApplications > 0 
        ? approvedApplications / totalApplications 
        : 0.0;
        
    final pendingRate = totalApplications > 0 
        ? pendingApplications / totalApplications 
        : 0.0;
        
    final rejectionRate = totalApplications > 0 
        ? rejectedApplications / totalApplications 
        : 0.0;
        
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildLinearProgress('Approved', approvalRate, Colors.green),
            const SizedBox(height: 12),
            _buildLinearProgress('Pending', pendingRate, Colors.orange),
            const SizedBox(height: 12),
            _buildLinearProgress('Rejected', rejectionRate, Colors.red),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLinearProgress(String label, double value, Color color) {
    final percentage = (value * 100).toStringAsFixed(1);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$percentage%',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearPercentIndicator(
          lineHeight: 8.0,
          percent: value,
          backgroundColor: Colors.grey[200],
          progressColor: color,
          barRadius: const Radius.circular(4),
          animation: true,
          animationDuration: 1000,
        ),
      ],
    );
  }
  
  Widget _buildCategoryChart() {
    if (categoryDistribution.isEmpty) {
      return const Center(child: Text('No category data available'));
    }
    
    // Prepare data for chart
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
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
      ),
    );
  }
  
  Widget _buildStatusChip(String? status) {
    Color backgroundColor;
    Color textColor = Colors.white;

    switch (status?.toLowerCase()) {
      case 'approved':
        backgroundColor = Colors.green;
        break;
      case 'pending':
        backgroundColor = Colors.orange;
        break;
      case 'rejected':
        backgroundColor = Colors.red;
        break;
      default:
        backgroundColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status ?? 'Unknown',
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
