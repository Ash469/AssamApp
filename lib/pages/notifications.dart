import 'package:flutter/material.dart';
import 'package:endgame/components/app_bar.dart';

class NotificationItem {
  final String title;
  final String subtitle;
  final String description;
  final String date;
  final String avatar;
  final bool hasAdv;

  NotificationItem({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.date,
    required this.avatar,
    this.hasAdv = false,
  });
}

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  static final List<NotificationItem> notifications = [
    NotificationItem(
      title: 'Deliveroo',
      subtitle: 'Ontdek vandaag nog de beste resta',
      description: 'Lekker eten en lokale ondernemingen steunen',
      date: '11-3-2022',
      avatar: 'D',
    ),
    NotificationItem(
      title: 'YouTube',
      subtitle: "Updates to YouTube's Terms of Se",
      description: 'We updated our Terms of Service',
      date: '25-11-2021',
      avatar: 'Y',
    ),
    NotificationItem(
      title: 'Microsoft Outlook',
      subtitle: 'Outlook overal bij de hand',
      description: 'Outlook overal bij de hand',
      date: '',
      avatar: 'O',
      hasAdv: true,
    ),
    NotificationItem(
      title: 'Mailchimp Legal',
      subtitle: 'An important update about change',
      description: 'An important update about changes to Mailchimp’s legal terms',
      date: '29-10-2020',
      avatar: 'ML',
    ),
    NotificationItem(
      title: 'Deliveroo',
      subtitle: 'Ontdek vandaag nog de beste resta',
      description: 'Lekker eten en lokale ondernemingen steunen',
      date: '11-3-2022',
      avatar: 'D',
    ),
    NotificationItem(
      title: 'YouTube',
      subtitle: "Updates to YouTube's Terms of Se",
      description: 'We updated our Terms of Service',
      date: '25-11-2021',
      avatar: 'Y',
    ),
    NotificationItem(
      title: 'Microsoft Outlook',
      subtitle: 'Outlook overal bij de hand',
      description: 'Outlook overal bij de hand',
      date: '',
      avatar: 'O',
      hasAdv: true,
    ),
  ];

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  int myIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Notifications'),
      body: 
       Column(
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.all(0),
                  itemCount: Notifications.notifications.length,
                  itemBuilder: (context, index) {
                    final notification = Notifications.notifications[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getAvatarColor(notification.avatar),
                        child: Text(
                          notification.avatar,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                           
                          ),
                        ),
                      ),
                      title: Text(
                        notification.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                           fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.subtitle,
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            notification.description,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 10,
                            ),
                          ),
                          if (notification.subtitle.contains('On January'))
                            Text(
                              "On January 5, 2022, we're updating our Terms",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 10,
                              ),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (notification.date.isNotEmpty)
                            Text(
                              notification.date,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          if (notification.hasAdv)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Adv',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          if (notification.hasAdv)
                            Icon(
                              Icons.more_horiz,
                              color: Colors.grey[400],
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
          
        ),
    );
  }

  Color _getAvatarColor(String avatar) {
    switch (avatar) {
      case 'D':
        return Colors.blue;
      case 'Y':
        return Colors.blue[700]!;
      case 'O':
        return Colors.blue[300]!;
      case 'ML':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }
}
