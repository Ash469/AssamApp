import 'package:flutter/material.dart';

class AdminUser extends StatefulWidget {
  const AdminUser({super.key});

  @override
  State<AdminUser> createState() => _AdminUserState();
}

class _AdminUserState extends State<AdminUser> {
  final List<Map<String, dynamic>> _users = List.generate(
    20,
    (index) => {
      'id': index + 1,
      'name': 'User ${index + 1}',
      'email': 'user${index + 1}@example.com',
      'role': index % 5 == 0 ? 'Admin' : 'User',
      'status': index % 4 == 0 ? 'Inactive' : 'Active',
      'joined': '2025-${(index % 12) + 1}-${(index % 28) + 1}',
    },
  );

  String _searchQuery = '';
  String _selectedRole = 'All Roles';
  String _selectedStatus = 'All Status';

  @override
  Widget build(BuildContext context) {
    // Filter users based on search query, role and status
    final filteredUsers = _users.where((user) {
      // Name or email contains search query
      final matchesSearch = user['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user['email'].toLowerCase().contains(_searchQuery.toLowerCase());
      
      // Filter by role if not "All Roles"
      final matchesRole = _selectedRole == 'All Roles' || 
          user['role'] == _selectedRole.replaceAll(' Roles', '');
      
      // Filter by status if not "All Status"
      final matchesStatus = _selectedStatus == 'All Status' || 
          user['status'] == _selectedStatus.replaceAll(' Status', '');
      
      return matchesSearch && matchesRole && matchesStatus;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
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
                      // Role filter
                      PopupMenuButton<String>(
                        offset: const Offset(0, 30),
                        onSelected: (value) {
                          setState(() {
                            _selectedRole = value;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedRole != 'All Roles' 
                                ? Colors.teal[50] 
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                            border: _selectedRole != 'All Roles'
                                ? Border.all(color: Colors.teal)
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person_outline, 
                                  size: 16, 
                                  color: _selectedRole != 'All Roles' 
                                      ? Colors.teal 
                                      : Colors.teal[700]),
                              const SizedBox(width: 4),
                              Text(_selectedRole, 
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: _selectedRole != 'All Roles' 
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
                            value: 'All Roles',
                            child: Text('All Roles'),
                          ),
                          const PopupMenuItem(
                            value: 'Admin',
                            child: Text('Admin'),
                          ),
                          const PopupMenuItem(
                            value: 'User',
                            child: Text('User'),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
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
                                color: _selectedStatus == 'Active' 
                                    ? Colors.green[700]
                                    : _selectedStatus == 'Inactive'
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
                            value: 'Active',
                            child: Text('Active'),
                          ),
                          const PopupMenuItem(
                            value: 'Inactive',
                            child: Text('Inactive'),
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
                      backgroundColor: user['role'] == 'Admin' 
                          ? Colors.teal[200] 
                          : Colors.blue[100],
                      child: Text(
                        user['name'].substring(0, 1),
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
                            user['name'],
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
                            color: user['status'] == 'Active'
                                ? Colors.green[50]
                                : Colors.red[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            user['status'],
                            style: TextStyle(
                              fontSize: 12,
                              color: user['status'] == 'Active'
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
                        Text('Email: ${user['email']}'),
                        const SizedBox(height: 4),
                        Text('Role: ${user['role']}'),
                        const SizedBox(height: 4),
                        Text('Joined: ${user['joined']}'),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'view',
                          child: Text('View Profile'),
                        ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit User'),
                        ),
                        PopupMenuItem(
                          value: 'status',
                          child: Text(
                            user['status'] == 'Active'
                                ? 'Deactivate User'
                                : 'Activate User',
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete User'),
                        ),
                      ],
                      onSelected: (value) {
                        // Handle menu item selection
                        if (value == 'status') {
                          setState(() {
                            user['status'] = user['status'] == 'Active'
                                ? 'Inactive'
                                : 'Active';
                          });
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show dialog to add new user
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.person_add),
      ),
    );
  }
}