import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Model class for user data
class User {
  final String id;
  final String firstName;
  final String middleName;
  final String lastName;
  final String userId;
  final String email;
  final String contactNumber;
  final int age;
  final String gender;
  final bool verified;
  final String createdAt;

  User({
    required this.id,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.userId,
    required this.email,
    required this.contactNumber,
    required this.age,
    required this.gender,
    required this.verified,
    required this.createdAt,
  });

  String get fullName {
    if (middleName.isNotEmpty) {
      return '$firstName $middleName $lastName';
    }
    return '$firstName $lastName';
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      firstName: json['firstName'] ?? '',
      middleName: json['middleName'] ?? '',
      lastName: json['lastName'] ?? '',
      userId: json['userId'] ?? '',
      email: json['email'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      age: json['age'] ?? 0,
      gender: json['gender'] ?? '',
      verified: json['verified'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']).toString().split('T')[0]
          : '',
    );
  }
}

class AdminUser extends StatefulWidget {
  const AdminUser({super.key});

  @override
  State<AdminUser> createState() => _AdminUserState();
}

class _AdminUserState extends State<AdminUser> {
   final String apiBaseUrl = dotenv.env['BACKEND_URL'] ?? 'http://10.150.54.176:3000';
  List<User> users = [];
  bool isLoading = true;
  String? error;
  
  String _searchQuery = '';
  String _selectedStatus = 'All Status';

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/api/getnewsignup'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['users'] as List<dynamic>;
        
        setState(() {
          users = data.map((json) => User.fromJson(json)).toList()
            ..sort((a, b) => DateTime.parse(b.createdAt)
                .compareTo(DateTime.parse(a.createdAt)));
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load users: ${response.statusCode}';
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

  Future<void> _verifyUser(String userId) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final response = await http.patch(
        Uri.parse('$apiBaseUrl/api/approve'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'_id': userId}),
      );

      // Pop loading dialog
      Navigator.pop(context);

      if (response.statusCode == 200) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User verified successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Refresh the list
        fetchUsers();
        
        // Close the details dialog if it's open
        Navigator.of(context).pop();
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to verify user: ${response.statusCode}'),
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

  void _showUserDetails(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('User Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('ID: ${user.id}', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              
              Text('Personal Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Divider(),
              Text('Full Name: ${user.fullName}'),
              SizedBox(height: 4),
              Text('User ID: ${user.userId}'),
              SizedBox(height: 4),
              Text('Age: ${user.age}'),
              SizedBox(height: 4),
              Text('Gender: ${user.gender}'),
              SizedBox(height: 12),
              
              Text('Contact Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Divider(),
              Text('Email: ${user.email}'),
              SizedBox(height: 4),
              Text('Phone: ${user.contactNumber}'),
              SizedBox(height: 12),
              
              Text('Account Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Divider(),
              Row(
                children: [
                  Text('Verified: ${user.verified ? 'Yes' : 'No'}'),
                  if (!user.verified)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        child: Text(
                          'Pending',
                          style: TextStyle(
                            color: Colors.red[800],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 4),
              Text('Joined: ${user.createdAt}'),
            ],
          ),
        ),
      actions: [
        if (!user.verified)
          ElevatedButton(
            onPressed: () => _verifyUser(user.id),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text('Verify User'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close'),
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    // Filter users based on search query and status
    final filteredUsers = users.where((user) {
      // Name or email contains search query
      final matchesSearch = user.userId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.fullName.toLowerCase().contains(_searchQuery.toLowerCase());
      
      // Filter by status if not "All Status"
      final matchesStatus = _selectedStatus == 'All Status' || 
          (_selectedStatus == 'Verified' && user.verified) ||
          (_selectedStatus == 'Unverified' && !user.verified);
      
      return matchesSearch && matchesStatus;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchUsers,
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
                        onPressed: fetchUsers,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search users...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${filteredUsers.length} Users Found',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                // Status filter
                                PopupMenuButton<String>(
                                  offset: const Offset(0, 30),
                                  onSelected: (value) {
                                    setState(() {
                                      _selectedStatus = value;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: _selectedStatus != 'All Status' 
                                          ? Colors.teal[50] 
                                          : Colors.grey[200],
                                      borderRadius: BorderRadius.circular(20),
                                      border: _selectedStatus != 'All Status'
                                          ? Border.all(color: Colors.teal)
                                          : null,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.circle, 
                                          size: 8, 
                                          color: _selectedStatus == 'Verified' 
                                              ? Colors.green[700]
                                              : _selectedStatus == 'Unverified'
                                                  ? Colors.red[700]
                                                  : Colors.green[700],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(_selectedStatus, 
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: _selectedStatus != 'All Status' 
                                                  ? Colors.teal 
                                                  : Colors.black87,
                                            )),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.arrow_drop_down, size: 16),
                                      ],
                                    ),
                                  ),
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'All Status',
                                      child: Text('All Status'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'Verified',
                                      child: Text('Verified'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'Unverified',
                                      child: Text('Unverified'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 2,
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                backgroundColor: Colors.teal[200],
                                child: Text(
                                  user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '?',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      user.userId,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: user.verified
                                          ? Colors.green[50]
                                          : Colors.red[50],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      user.verified ? 'Verified' : 'Unverified',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: user.verified
                                            ? Colors.green[800]
                                            : Colors.red[800],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  Text('Email: ${user.email}'),
                                  const SizedBox(height: 4),
                                  Text('Joined: ${user.createdAt}'),
                                ],
                              ),
                              onTap: () => _showUserDetails(user),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}