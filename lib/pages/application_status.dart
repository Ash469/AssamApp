import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:endgame/components/app_drawer.dart';
import 'package:endgame/components/app_bar.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart'; // Add this import

class ApplicationStatusPage extends StatefulWidget {
  const ApplicationStatusPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ApplicationStatusPageState createState() => _ApplicationStatusPageState();
}

class _ApplicationStatusPageState extends State<ApplicationStatusPage> {
  final String apiBaseUrl =
      dotenv.env['BACKEND_URL'] ?? 'http://10.150.54.176:3000';
  List<Map<String, dynamic>> applications = [];
  List<Map<String, dynamic>> filteredApplications = [];
  bool isLoading = true;
  String errorMessage = '';
  String? statusFilter;
  String? categoryFilter;

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
          filteredApplications = applications;
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

  void applyFilters() {
    setState(() {
      filteredApplications = applications.where((app) {
        bool matchesStatus = statusFilter == null ||
            app['status']?.toLowerCase() == statusFilter?.toLowerCase();
        bool matchesCategory = categoryFilter == null ||
            app['category']?.toLowerCase() == categoryFilter?.toLowerCase();
        return matchesStatus && matchesCategory;
      }).toList();
    });
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
              title: const Text('Application Status'),
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_list),
                  onSelected: (String value) {
                    setState(() {
                      if (value.startsWith('status_')) {
                        statusFilter = value.substring(7);
                        categoryFilter = null;
                      } else if (value.startsWith('category_')) {
                        categoryFilter = value.substring(9);
                        statusFilter = null;
                      } else if (value == 'clear') {
                        statusFilter = null;
                        categoryFilter = null;
                      }
                      applyFilters();
                    });
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    // Status filters
                    PopupMenuItem<String>(
                      value: 'status_Approved',
                      child: Container(
                        decoration: BoxDecoration(
                          color: statusFilter == 'Approved'
                              ? Colors.blue.withOpacity(0.6)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: const Text('Filter by Approved'),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'status_Pending',
                      child: Container(
                        decoration: BoxDecoration(
                          color: statusFilter == 'Pending'
                              ? Colors.blue.withOpacity(0.6)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: const Text('Filter by Pending'),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'status_Rejected',
                      child: Container(
                        decoration: BoxDecoration(
                          color: statusFilter == 'Rejected'
                              ? Colors.blue.withOpacity(0.6)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: const Text('Filter by Rejected'),
                      ),
                    ),
                    const PopupMenuDivider(),
                    // Category filters matching API data
                    PopupMenuItem<String>(
                      value: 'category_Administration',
                      child: Container(
                        decoration: BoxDecoration(
                          color: categoryFilter == 'Administration'
                              ? Colors.blue.withOpacity(0.6)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: const Text('Filter by Administration'),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'category_Business',
                      child: Container(
                        decoration: BoxDecoration(
                          color: categoryFilter == 'Business'
                              ? Colors.blue.withOpacity(0.6)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: const Text('Filter by Business'),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'category_Education',
                      child: Container(
                        decoration: BoxDecoration(
                          color: categoryFilter == 'Education'
                              ? Colors.blue.withOpacity(0.6)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: const Text('Filter by Education'),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'category_Employment',
                      child: Container(
                        decoration: BoxDecoration(
                          color: categoryFilter == 'Employment'
                              ? Colors.blue.withOpacity(0.6)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: const Text('Filter by Employment'),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'category_Health',
                      child: Container(
                        decoration: BoxDecoration(
                          color: categoryFilter == 'Health'
                              ? Colors.blue.withOpacity(0.6)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: const Text('Filter by Health'),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'category_Disaster Relief',
                      child: Container(
                        decoration: BoxDecoration(
                          color: categoryFilter == 'Disaster Relief'
                              ? Colors.blue.withOpacity(0.6)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: const Text('Filter by Disaster Relief'),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'category_Other',
                      child: Container(
                        decoration: BoxDecoration(
                          color: categoryFilter == 'Other'
                              ? Colors.blue.withOpacity(0.6)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: const Text('Filter by Other'),
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem<String>(
                      value: 'clear',
                      child: Text('Clear Filters'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 6),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : errorMessage.isNotEmpty
                        ? Center(
                            child: Text(errorMessage,
                                style: const TextStyle(color: Colors.red)))
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4), // Reduced overall padding
                            itemCount: filteredApplications.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 16),
                            itemBuilder: (context, index) {
                              final application =
                                  filteredApplications.reversed.toList()[index];
                              final fullName =
                                  application['fullName'] ?? 'No Name';

                              return ListTile(
                                dense: false, // Makes the ListTile more compact
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 6), // Minimal padding
                                onTap: () {
                                  _showApplicationDetails(context, application);
                                },
                                leading: CircleAvatar(
                                  backgroundColor: Colors.teal[100],
                                  radius: 20, // Smaller radius
                                  child: Text('${index + 1}'),
                                ),
                                title: Text(
                                  fullName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18),
                                  overflow: TextOverflow
                                      .ellipsis, // Add ellipsis for long text
                                ),
                                subtitle: Text(
                                  application['category'] ?? 'No Category',
                                  style: TextStyle(
                                      color: Colors.grey[700], fontSize: 14),
                                ),
                                trailing: SizedBox(
                                  width:
                                      140, // Reduced width to prevent overflow
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: _buildStatusChip(
                                            application['status']),
                                      ),
                                      // const SizedBox(width: 2),
                                      IconButton(
                                        padding: EdgeInsets
                                            .zero, // Remove padding from icon button
                                        constraints:
                                            const BoxConstraints(), // Remove constraints
                                        icon: const Icon(Icons.download,
                                            color: Colors.teal, size: 20),
                                        onPressed: () async {
                                          final documentUrl =
                                              application['documentUrl'];
                                          if (documentUrl != null &&
                                              documentUrl.isNotEmpty) {
                                            try {
                                              final Uri url =
                                                  Uri.parse(documentUrl);
                                              await launchUrl(url,
                                                  mode: LaunchMode
                                                      .externalApplication);
                                            } catch (e) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Error opening document: ${e.toString()}')),
                                              );
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status ?? 'Unknown',
        style: TextStyle(
            color: textColor, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  void _showApplicationDetails(
      BuildContext context, Map<String, dynamic> application) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Application Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Application Information',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Divider(),
              Text('Category: ${application['category'] ?? 'Not specified'}'),
              SizedBox(height: 4),
              Text('Status: ${application['status'] ?? 'Unknown'}'),
              SizedBox(height: 4),
              Text(
                  'Created On: ${DateTime.parse(application['createdAt']).toLocal().toString().split('.')[0]}'),
              SizedBox(height: 12),
              Text('Personal Information',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Divider(),
              Text('Full Name: ${application['fullName'] ?? 'Not specified'}'),
              SizedBox(height: 4),
              Text('Age: ${application['age'] ?? 'Not specified'} years'),
              SizedBox(height: 4),
              Text('Gender: ${application['gender'] ?? 'Not specified'}'),
              SizedBox(height: 4),
              Text(
                  'Phone Number: ${application['contactNumber'] ?? 'Not specified'}'),
              SizedBox(height: 12),
              Text('Location Details',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Divider(),
              Text('District: ${application['district'] ?? 'Not specified'}'),
              SizedBox(height: 4),
              Text(
                  'Revenue Circle: ${application['revenueCircle'] ?? 'Not specified'}'),
              SizedBox(height: 4),
              Text(
                  'Village/Ward: ${application['villageWard'] ?? 'Not specified'}'),
              SizedBox(height: 12),
              if (application['remarks'] != null &&
                  application['remarks'].toString().isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Remarks',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Divider(),
                    Text(application['remarks']),
                    SizedBox(height: 12),
                  ],
                ),
            ],
          ),
        ),
        actions: [
          if (application['documentUrl'] != null &&
              application['documentUrl'].toString().isNotEmpty)
            ElevatedButton.icon(
              onPressed: () async {
                final documentUrl = application['documentUrl'];
                if (documentUrl != null && documentUrl.isNotEmpty) {
                  try {
                    final Uri url = Uri.parse(documentUrl);
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Error opening document: ${e.toString()}')),
                    );
                  }
                }
              },
              icon: const Icon(Icons.download),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              label: const Text('Download Document'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class ApplicationDetailPage extends StatelessWidget {
  final Map<String, dynamic> application;

  const ApplicationDetailPage({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [
              Colors.teal[700]!,
              Colors.teal[600]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Application status',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Personal Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildDetailRow(
                                'Full Name',
                                application['fullName'] ?? '',
                              ),
                              _buildDetailRow(
                                  'Age', '${application['age']} years'),
                            ],
                          ),
                          Row(
                            children: [
                              _buildDetailRow(
                                  'Gender', application['gender'] ?? ''),
                              _buildDetailRow(
                                  'Phone Number',
                                  application['contactNumber'] ??
                                      ''), // Changed from phoneNo to contactNumber
                            ],
                          ),
                          Row(
                            children: [
                              _buildDetailRow('Occupation',
                                  application['occupation'] ?? ''),
                              const Expanded(
                                  child:
                                      SizedBox()), // Empty space for alignment
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Location Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildDetailRow(
                                  'District', application['district'] ?? ''),
                              _buildDetailRow('Revenue Circle',
                                  application['revenueCircle'] ?? ''),
                            ],
                          ),
                          Row(
                            children: [
                              _buildDetailRow('Village/Ward',
                                  application['villageWard'] ?? ''),
                              const Expanded(child: SizedBox()),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Application Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildDetailRow(
                                  'Category', application['category'] ?? ''),
                              _buildDetailRow(
                                'Created On',
                                DateTime.parse(application['createdAt'])
                                    .toLocal()
                                    .toString()
                                    .split('.')[0],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              _buildDetailRow(
                                  'Remarks', application['remarks'] ?? ''),
                              const Expanded(child: SizedBox()),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Current Status',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(application['status']),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              application['status'] ?? 'Unknown',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (application['documentUrl'] != null &&
                              application['documentUrl'].isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 24),
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final documentUrl =
                                      application['documentUrl'];
                                  if (documentUrl != null &&
                                      documentUrl.isNotEmpty) {
                                    final Uri url = Uri.parse(documentUrl);
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url,
                                          mode: LaunchMode.externalApplication);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Could not open document')),
                                      );
                                    }
                                  }
                                },
                                icon: const Icon(Icons.download),
                                label: const Text('Download Attached Document'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
