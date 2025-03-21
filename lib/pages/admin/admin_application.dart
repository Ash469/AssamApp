import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Model class for application data
class Application {
  final String id;
  final String fullName;
  final int age;
  final String contactNumber;
  final String gender;
  final String district;
  final String revenueCircle;
  final String category;
  final String villageWard;
  final String remarks;
  final String documentUrl;
  final String status;
  final String date;

  Application({
    required this.id,
    required this.fullName,
    required this.age,
    required this.contactNumber,
    required this.gender,
    required this.district,
    required this.revenueCircle,
    required this.category,
    required this.villageWard,
    required this.remarks,
    required this.documentUrl,
    required this.status,
    required this.date,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      age: json['age'] ?? 0,
      contactNumber: json['contactNumber'] ?? '',
      gender: json['gender'] ?? '',
      district: json['district'] ?? '',
      revenueCircle: json['revenueCircle'] ?? '',
      category: json['category'] ?? '',
      villageWard: json['villageWard'] ?? '',
      remarks: json['remarks'] ?? '',
      documentUrl: json['documentUrl'] ?? '',
      status: json['status'] ?? '',
      date: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']).toString().split('T')[0]
          : '',
    );
  }
}

class AdminApplication extends StatefulWidget {
  const AdminApplication({super.key});

  @override
  State<AdminApplication> createState() => _AdminApplicationState();
}

class _AdminApplicationState extends State<AdminApplication> {
  final String apiBaseUrl = dotenv.env['BACKEND_URL'] ?? 'http://10.150.54.176:3000';
  List<Application> applications = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchApplications();
  }

  Future<void> fetchApplications() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/api/applications'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'] as List<dynamic>;
        
        setState(() {
          applications = data.map((json) => Application.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load applications: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
    }
  }

  // Add this method to show application details
  void _showApplicationDetails(Application application) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Application Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('ID: ${application.id}', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              
              Text('Personal Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Divider(),
              Text('Full Name: ${application.fullName}'),
              SizedBox(height: 4),
              Text('Age: ${application.age}'),
              SizedBox(height: 4),
              Text('Gender: ${application.gender}'),
              SizedBox(height: 4),
              Text('Contact Number: ${application.contactNumber}'),
              SizedBox(height: 12),
              
              Text('Location Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Divider(),
              Text('District: ${application.district}'),
              SizedBox(height: 4),
              Text('Revenue Circle: ${application.revenueCircle}'),
              SizedBox(height: 4),
              Text('Village/Ward: ${application.villageWard}'),
              SizedBox(height: 12),
              
              Text('Application Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Divider(),
              Text('Category: ${application.category}'),
              SizedBox(height: 4),
              Text('Status: ${application.status}'),
              SizedBox(height: 4),
              Text('Submission Date: ${application.date}'),
              SizedBox(height: 4),
              Text('Remarks: ${application.remarks.isEmpty ? 'None' : application.remarks}'),
              SizedBox(height: 8),
              
              if (application.documentUrl.isNotEmpty) 
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Documents:', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    InkWell(
                      onTap: () {
                        // Optional: Add code to open the document URL
                      },
                      child: Text(
                        application.documentUrl,
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  // Add this method to update application status
  Future<void> _updateApplicationStatus(String id, String status) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final response = await http.put(
        Uri.parse('$apiBaseUrl/api/applications'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'applicationId': id,
          'status': status
        }),
      );

      // Pop loading dialog
      Navigator.pop(context);

      if (response.statusCode == 200) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Application $status successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Refresh the list
        fetchApplications();
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update application: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Pop loading dialog
      Navigator.pop(context);
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Applications Management'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchApplications,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: fetchApplications,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : applications.isEmpty
                  ? const Center(child: Text('No applications found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: applications.length,
                      itemBuilder: (context, index) {
                        final application = applications[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 2,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: Colors.deepPurple[100],
                              child: Text('${index + 1}'),
                            ),
                            title: Text('Application #${application.id}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                const SizedBox(height: 4),
                                Text('Submitted by: ${application.fullName}'),
                                const SizedBox(height: 4),
                                Text('Category: ${application.category}'),
                                const SizedBox(height: 4),
                                Text('Status: ${application.status}'),
                                const SizedBox(height: 4),
                                Text('Date: ${application.date.split(" ")[0]}'),
                              ],
                            ),
                            trailing: PopupMenuButton(
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'view',
                                  child: Text('View Details'),
                                ),
                                const PopupMenuItem(
                                  value: 'approve',
                                  child: Text('Approve'),
                                ),
                                const PopupMenuItem(
                                  value: 'reject',
                                  child: Text('Reject'),
                                ),
                              ],
                              onSelected: (value) {
                                switch (value) {
                                  case 'view':
                                    _showApplicationDetails(application);
                                    break;
                                  case 'approve':
                                    _updateApplicationStatus(application.id, 'Approved');
                                    break;
                                  case 'reject':
                                    _updateApplicationStatus(application.id, 'Rejected');
                                    break;
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}