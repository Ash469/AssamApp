import 'package:endgame/pages/about.dart';
import 'package:flutter/material.dart';
import 'package:endgame/homepage.dart' as home_page;
import 'package:endgame/pages/new_application.dart';
import 'package:endgame/pages/application_status.dart';
import 'package:endgame/pages/appointment.dart';
import 'package:endgame/pages/contact.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildDrawerHeader(),
            _buildDrawerListTile(
              context,
              const Icon(Icons.home),
              'Home',
              const home_page.HomePage(),
            ),
            _buildDrawerListTile(
              context,
              const Icon(Icons.info),
              'New Application',
              const NewApplication(),
            ),
            _buildDrawerListTile(
              context,
              const Icon(Icons.group),
              'Application Status',
              const ApplicationStatusPage(),
            ),
            _buildDrawerListTile(
              context,
              const Icon(Icons.calendar_month),
              'Appointment',
              const AppointmentPage(),
            ),
            _buildDrawerListTile(
              context,
              const Icon(Icons.contact_support),
              'Contact',
              const Contact(),
            ),
            _buildDrawerListTile(
              context,
              const Icon(Icons.info),
              'About US',
              const About(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      margin: const EdgeInsets.all(0), 
      child: const DrawerHeader(
        decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/app.png'), 
          fit: BoxFit.fitHeight,
        ),
      ),
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            SizedBox(
              width: 90,
              height: 90,
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/logo.jpg'),
              ),
            ),
            SizedBox(width: 40),
            Text(
              'AshTech',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Colors.lightBlueAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  ListTile _buildDrawerListTile(
      BuildContext context, Icon leadingIcon, String title, Widget page) {
    return ListTile(
      leading: leadingIcon,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
    );
  }
}
