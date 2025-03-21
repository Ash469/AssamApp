import 'package:flutter/material.dart';

class AdminApplication extends StatefulWidget {
  const AdminApplication({super.key});

  @override
  State<AdminApplication> createState() => _AdminApplicationState();
}

class _AdminApplicationState extends State<AdminApplication> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Applications Management'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10, // Example count
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: Colors.deepPurple[100],
                child: Text('${index + 1}'),
              ),
              title: Text('Application #${1000 + index}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('Submitted by: User${100 + index}'),
                  const SizedBox(height: 4),
                  Text('Status: ${index % 3 == 0 ? "Pending" : index % 3 == 1 ? "Approved" : "Rejected"}'),
                  const SizedBox(height: 4),
                  Text('Date: ${DateTime.now().subtract(Duration(days: index)).toString().substring(0, 10)}'),
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
                  // Handle menu item selection
                },
              ),
            ),
          );
        },
      ),
    );
  }
}