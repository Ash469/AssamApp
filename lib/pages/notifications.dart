import 'package:flutter/material.dart';
import 'package:endgame/components/app_bar.dart';
import 'package:endgame/components/app_drawer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NotificationItem {
  final String id;
  final String title;
  final String content;
  final String createdAt;
  final String avatar;

  NotificationItem({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.avatar,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    // Extract first letter(s) of title for avatar - matching web implementation
    String avatarText = getAvatarText(json['title'] ?? '');
    
    // Format date
    String formattedDate = formatDate(json['createdAt'] ?? '');
    
    return NotificationItem(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      createdAt: formattedDate,
      avatar: avatarText,
    );
  }

  static String getAvatarText(String title) {
    if (title.isEmpty) return 'N';
    
    final words = title.split(' ');
    if (words.length > 1) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return title.substring(0, 1).toUpperCase();
  }

  static String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    } catch (e) {
      return '';
    }
  }
}

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final String apiBaseUrl = dotenv.env['BACKEND_URL'] ?? 'http://10.150.54.176:3000';
  List<NotificationItem> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;
  NotificationItem? _selectedNotification;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Try with different API URL formats to help debug the 404 issue
      final apiUrl = '$apiBaseUrl/api/notification';
      print('Attempting to fetch notifications from: $apiUrl');
      
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Response status code: ${response.statusCode}');
      
      if (response.statusCode == 404) {
        // Handle 404 error specifically
        print('404 Not Found error - API endpoint might be incorrect');
        
        // Try alternative URL format as fallback (without trailing slash)
        final alternativeUrl = apiBaseUrl.endsWith('/') 
            ? '${apiBaseUrl}api/notification' 
            : '$apiBaseUrl/api/notification';
            
        print('Trying alternative URL: $alternativeUrl');
        
        final alternativeResponse = await http.get(
          Uri.parse(alternativeUrl),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );
        
        print('Alternative response status: ${alternativeResponse.statusCode}');
        
        if (alternativeResponse.statusCode == 200) {
          final List<dynamic> data = json.decode(alternativeResponse.body);
          setState(() {
            _notifications = data
                .map((item) => NotificationItem.fromJson(item))
                .toList();
            _isLoading = false;
          });
          return;
        } else {
          setState(() {
            _errorMessage = 'Unable to connect to the notifications service.\n'
                'Status: ${response.statusCode}\n'
                'Please check your network connection and try again.';
            _isLoading = false;
          });
        }
      } else if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _notifications = data
              .map((item) => NotificationItem.fromJson(item))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load notifications: ${response.statusCode}\n'
              'Please check your network connection and try again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Exception caught: ${e.toString()}');
      setState(() {
        _errorMessage = 'Network error: Unable to connect to the notifications service.\n'
            'Please check your network connection and try again.';
        _isLoading = false;
      });
    }
  }

  void _showNotificationDetail(NotificationItem notification) {
    setState(() {
      _selectedNotification = notification;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildNotificationDetailModal(notification),
    );
  }

  Widget _buildNotificationDetailModal(NotificationItem notification) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      padding: const EdgeInsets.only(top: 8),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) {
          return Column(
            children: [
              Container(
                height: 4,
                width: 40,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF115e59), // teal-800 equivalent
                            ),
                          ),
                          Text(
                            notification.createdAt,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      notification.content,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: Colors.grey[50],
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0d9488), // teal-600 equivalent
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Close',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Notifications'),
      drawer: const AppDrawer(),
      body: Column(
        children: [
      
          
          // Main content
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF3F4F6), // gray-100 equivalent
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Recent Notifications',
                            style: TextStyle(
                              fontSize: 16, 
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF115e59), // teal-800 equivalent
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        _buildContent(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Loading notifications...',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      // For 404 errors, show just the status code with minimal text
      if (_errorMessage!.contains("404")) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "404",
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _fetchNotifications,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0d9488),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }
      
      // For other errors, use the existing error display
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchNotifications,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0d9488),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_notifications.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'No notifications available',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: RefreshIndicator(
        onRefresh: _fetchNotifications,
        child: ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: _notifications.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final notification = _notifications[index];
            return InkWell(
              onTap: () => _showNotificationDetail(notification),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 16.0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0d9488), // teal-600 equivalent
                        border: Border.all(
                          color: const Color(0xFF2dd4bf), // teal-400 equivalent
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Center(
                        child: Text(
                          notification.avatar,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Color(0xFF115e59), // teal-800 equivalent
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notification.content,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[800],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          notification.createdAt,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getAvatarColor(String avatar) {
    // Using a consistent teal color to match the web design
    return const Color(0xFF0d9488); // teal-600 equivalent
  }
}
