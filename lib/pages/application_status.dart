import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:endgame/components/app_drawer.dart';
import 'package:endgame/components/app_bar.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:endgame/utils/download_helper.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:endgame/utils/pdf_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String? userId;
  bool isFirebaseInitialized = true; 

  Set<int> selectedApplications = {};
  bool isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _initPageData();
  }


  Future<void> _initPageData() async {
    // Clear error state when retrying
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });
    }
    await _getUserIdAndFetchApplications();
  }

  Future<void> _getUserIdAndFetchApplications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('userData');
      
      print('Checking for user data in SharedPreferences...');
      if (userDataString != null) {
        print('User data found in SharedPreferences!');
        final userData = json.decode(userDataString);
        print('Decoded user data: ${userData.toString()}');
        
        // Use userId or _id field depending on what's available
        userId = userData['userId'] ?? userData['_id'];
        print('Using userId: $userId');
        
        if (userId == null || userId!.isEmpty) {
          print('User ID is null or empty after parsing userData');
          setState(() {
            isLoading = false;
            errorMessage = 'User ID not found. Please login again.';
          });
          return;
        }
      } else {
        print('No user data found in SharedPreferences, checking for token...');
        // If no user data in SharedPreferences, try to get it from token
        final token = prefs.getString('token');
        if (token != null) {
          print('Token found, attempting to fetch user profile...');
          // Try to fetch user profile data
          try {
            final response = await http.get(
              Uri.parse('$apiBaseUrl/api/getnewsignup'),
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
            ).timeout(const Duration(seconds: 10));
            
            print('API response status code: ${response.statusCode}');
            
            if (response.statusCode == 200) {
              final responseData = json.decode(response.body);
              if (responseData['users'] != null && responseData['users'] is List && responseData['users'].isNotEmpty) {
                // Get first user (assuming this is the logged in user)
                final userData = responseData['users'][0];
                print('Retrieved user data from API: ${userData.toString()}');
                await prefs.setString('userData', json.encode(userData));
                userId = userData['userId'] ?? userData['_id'];
                print('Set userId: $userId');
              } else {
                throw Exception('No user data found in profile API response');
              }
            } else {
              throw Exception('Failed to fetch user profile: ${response.statusCode}');
            }
          } catch (e) {
            print('Error fetching user profile: $e');
            // Try the token decode approach to get userId
            try {
              final parts = token.split('.');
              if (parts.length > 1) {
                final payload = base64Url.normalize(parts[1]);
                final decoded = utf8.decode(base64Url.decode(payload));
                final payloadMap = json.decode(decoded);
                userId = payloadMap['id'] ?? payloadMap['userId'] ?? payloadMap['sub'] ?? payloadMap['_id'];
                print('Extracted userId from token: $userId');
                
                if (userId != null && userId!.isNotEmpty) {
                  // We have a userId, let's continue with that
                  final basicUserData = {'userId': userId};
                  await prefs.setString('userData', json.encode(basicUserData));
                } else {
                  throw Exception('Could not extract user ID from token');
                }
              } else {
                throw Exception('Invalid token format');
              }
            } catch (tokenError) {
              print('Error decoding token: $tokenError');
              setState(() {
                isLoading = false;
                errorMessage = 'Unable to authenticate. Please login again.';
              });
              return;
            }
          }
        } else {
          print('No token found in SharedPreferences');
          setState(() {
            isLoading = false;
            errorMessage = 'You are not logged in. Please login to continue.';
          });
          return;
        }
      }
      
      // Now fetch applications with the userId
      await fetchApplications();
    } catch (e) {
      print('Error in _getUserIdAndFetchApplications: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Error loading user data: ${e.toString()}';
        });
      }
    }
  }

  Future<void> fetchApplications() async {
    try {
      if (userId == null || userId!.isEmpty) {
        setState(() {
          isLoading = false;
          errorMessage = 'Unable to fetch applications: User ID not found';
        });
        return;
      }

      // Updated URL for the new endpoint
      final url = '$apiBaseUrl/api/getapplicationByUserId';
      print('Fetching applications with URL: $url');
      
      // Changed to POST request with createdBy in the body
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'createdBy': userId}),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          return http.Response('{"error":"Request timed out"}', 408);
        },
      );

      if (!mounted) return;

      print('Response status code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> data = responseData['data'] ?? [];
        
        if (mounted) {
          setState(() {
            applications = List<Map<String, dynamic>>.from(data);
            filteredApplications = applications;
            isLoading = false;
          });
        }
        
        print('Loaded ${applications.length} applications');
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        final String errorMsg = errorData['error'] ?? 'Unknown error occurred';
        
        if (mounted) {
          setState(() {
            isLoading = false;
            errorMessage = 'Failed to load applications: $errorMsg';
          });
        }
      }
    } catch (e) {
      print('Error fetching applications: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Error: ${e.toString()}';
        });
      }
    }
  }

  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      // Request storage permission for Android < 13
      final storageStatus = await Permission.storage.request();
      if (storageStatus.isGranted) {
        return true;
      }

      // For Android 13+, request media permissions
      final photos = await Permission.photos.request();
      final videos = await Permission.videos.request();
      final audio = await Permission.audio.request();

      return photos.isGranted || videos.isGranted || audio.isGranted;
    }
    return true;
  }

  Future<void> _handleDownload(String? documentUrl, Map<String, dynamic> application) async {
    if (documentUrl == null || documentUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No document available')),
      );
      return;
    }

    print('Attempting to create PDF with image: $documentUrl');

    bool hasPermission = await _requestPermissions();
    if (!hasPermission) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage permission is required to download files'),
            duration: Duration(seconds: 2),
          ),
        );
        await openAppSettings();
      }
      return;
    }

    // Show progress dialog
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generating PDF...'),
              ],
            ),
          );
        },
      );
    }

    try {
      if (context.mounted) {
        await PdfHelper.generateAndDownloadPdf(application, documentUrl, context);
      }
    } finally {
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context); // Close progress dialog
      }
    }
  }

  Future<void> downloadSelectedApplications() async {
    if (selectedApplications.isEmpty) return;

    // Show progress dialog
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Generating PDFs...'),
            ],
          ),
        );
      },
    );

    try {
      for (int index in selectedApplications) {
        final application = filteredApplications.reversed.toList()[index];
        final documentUrl = application['documentUrl'];
        if (documentUrl != null && documentUrl.isNotEmpty) {
          await PdfHelper.generateAndDownloadPdf(application, documentUrl, context);
        }
      }
    } finally {
      if (context.mounted) {
        Navigator.pop(context); // Close progress dialog
        setState(() {
          selectedApplications.clear();
          isSelectionMode = false;
        });
      }
    }
  }

  void toggleSelection(int index) {
    setState(() {
      if (selectedApplications.contains(index)) {
        selectedApplications.remove(index);
        if (selectedApplications.isEmpty) {
          isSelectionMode = false;
        }
      } else {
        selectedApplications.add(index);
        isSelectionMode = true;
      }
    });
  }

  void selectAll() {
    setState(() {
      if (selectedApplications.length == filteredApplications.length) {
        // If all are selected, deselect all
        selectedApplications.clear();
        isSelectionMode = false;
      } else {
        // Select all
        selectedApplications = Set.from(
          List.generate(filteredApplications.length, (index) => index),
        );
        isSelectionMode = true;
      }
    });
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
                if (isSelectionMode) ...[
                  IconButton(
                    icon: Icon(
                      selectedApplications.length == filteredApplications.length
                          ? Icons.select_all
                          : Icons.deselect,
                    ),
                    onPressed: selectAll,
                    tooltip: selectedApplications.length == filteredApplications.length
                        ? 'Deselect All'
                        : 'Select All',
                  ),
                  IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: downloadSelectedApplications,
                  ),
                ],
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
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  errorMessage,
                                  style: const TextStyle(color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: _initPageData,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : filteredApplications.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'No applications found',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: _initPageData,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.teal,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Refresh'),
                                    ),
                                  ],
                                ),
                              )
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
                                    dense: false,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 6), // Minimal padding
                                    onTap: () {
                                      if (isSelectionMode) {
                                        toggleSelection(index);
                                      } else {
                                        _showApplicationDetails(context, application);
                                      }
                                    },
                                    onLongPress: () {
                                      toggleSelection(index);
                                    },
                                    leading: isSelectionMode
                                      ? Checkbox(
                                          value: selectedApplications.contains(index),
                                          onChanged: (_) => toggleSelection(index),
                                          activeColor: Colors.teal,
                                        )
                                      : CircleAvatar(
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
                                    trailing: Padding(
                                      padding: const EdgeInsets.only(right: 8.0),
                                      child: SizedBox(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                        Flexible(
                                          child: _buildStatusChip(
                                            application['status']),
                                        ),
                                        ],
                                      ),
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
                  await DownloadHelper.downloadFile(documentUrl, context);
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