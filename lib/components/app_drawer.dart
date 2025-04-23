import 'package:endgame/pages/about.dart';
import 'package:flutter/material.dart';
import 'package:endgame/homepage.dart' as home_page;
import 'package:endgame/pages/new_application.dart';
import 'package:endgame/pages/application_status.dart';
// import 'package:endgame/pages/appointment.dart';
import 'package:endgame/pages/contact.dart';
import 'package:endgame/pages/profile.dart';


class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade100, Colors.white],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildDrawerHeader(),
            const SizedBox(height: 10),
            _buildDrawerListTile(
              context,
              const Icon(Icons.home, color: Colors.blue),
              'Home',
              const home_page.HomePage(),
            ),
            _buildDrawerListTile(
              context,
              const Icon(Icons.info, color: Colors.blue),
              'New Application',
              const NewApplication(),
            ),
            _buildDrawerListTile(
              context,
              const Icon(Icons.group, color: Colors.blue),
              'Application Status',
              const ApplicationStatusPage(),
            ),
            _buildDrawerListTile(
              context,
              const Icon(Icons.contact_support, color: Colors.blue),
              'Contact',
              const Contact(),
            ),
            _buildDrawerListTile(
              context,
              const Icon(Icons.info, color: Colors.blue),
              'About US',
              const About(),
            ),
            _buildDrawerListTile(
              context,
              const Icon(Icons.person, color: Colors.blue),
              'Profile',
              const ProfilePage(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      margin: const EdgeInsets.all(0),
      child: DrawerHeader(
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('assets/app.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black26,
              BlendMode.darken,
            ),
          ),
          borderRadius: BorderRadius.circular(0),
        ),
        padding: EdgeInsets.zero,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 45,
              backgroundImage: AssetImage('assets/logo.jpg'),
              backgroundColor: Colors.white,
            ),
            SizedBox(height: 10),
            Text(
              'AshTech',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 3.0,
                    color: Colors.black45,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerListTile(
      BuildContext context, Icon leadingIcon, String title, Widget page) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white.withOpacity(0.7),
      ),
      child: ListTile(
        leading: leadingIcon,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  static void openDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }
}
