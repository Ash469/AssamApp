import 'package:flutter/material.dart';
import 'package:endgame/components/app_bar.dart';
import 'package:endgame/components/app_drawer.dart';

class Faq extends StatefulWidget {
  const Faq({super.key});

  @override
  _FaqState createState() => _FaqState();
}

class _FaqState extends State<Faq> {
  final List<FaqItem> _faqItems = [
    FaqItem(
      question: 'How do I create a new application?',
      answer: 'To create a new application, go to the "New Application" section in your dashboard and fill in the required details.',
      icon: Icons.app_registration,
    ),
    FaqItem(
      question: 'How can I check my application status?',
      answer: 'You can check your application status in the "Application Status" tab of your profile.',
      icon: Icons.update,
    ),
    FaqItem(
      question: 'How do I edit my profile?',
      answer: 'Go to the "Profile" section and click "Edit Profile" to update your information.',
      icon: Icons.person,
    ),
    FaqItem(
      question: 'Can I delete my application?',
      answer: 'Yes, you can delete your application from the "My Applications" section by selecting the application and clicking "Delete".',
      icon: Icons.delete,
    ),
    FaqItem(
      question: 'How do I reset my password?',
      answer: 'Go to "Settings" and click on "Change Password" to reset your password.',
      icon: Icons.lock,
    ),
    FaqItem(
      question: 'What if my application gets rejected?',
      answer: 'If your application is rejected, you will receive a detailed email explaining the reasons and possible solutions.',
      icon: Icons.warning,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'FAQ'),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ExpansionPanelList.radio(
              elevation: 2,
              expandedHeaderPadding: const EdgeInsets.all(0),
              children: _faqItems.map<ExpansionPanelRadio>((FaqItem item) {
                return ExpansionPanelRadio(
                  value: item.question, // Unique identifier for each panel
                  headerBuilder: (BuildContext context, bool isExpanded) {
                    return ListTile(
                      leading: Icon(
                        item.icon,
                        color: isExpanded ? Colors.blue : Colors.grey,
                      ),
                      title: Text(
                        item.question,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isExpanded ? Colors.blue : Colors.black87,
                        ),
                      ),
                    );
                  },
                  body: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.blue.shade50,
                    ),
                    child: Text(
                      item.answer,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class FaqItem {
  FaqItem({
    required this.question,
    required this.answer,
    required this.icon,
  });

  final String question;
  final String answer;
  final IconData icon;
}
