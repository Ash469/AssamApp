// import 'package:flutter/material.dart';

// // import '../pages/home.dart';
// import '../pages/about.dart';
// import '../pages/faq.dart';
// import '../pages/contact.dart';

// class BottomNavBar extends StatefulWidget {
//   const BottomNavBar({super.key, required this.currentIndex});

//   final int currentIndex;

//   @override
//   State<BottomNavBar> createState() => _BottomNavBarState();
// }

// class _BottomNavBarState extends State<BottomNavBar> {
//   int myIndex = 0;

//   final List<Widget> pages = [
//     // const Home(),
//     const About(),
//     const Faq(),
//     const Contact(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: pages[myIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: myIndex,
//         type: BottomNavigationBarType.fixed,
//         selectedItemColor: const Color.fromARGB(255, 7, 96, 230),
//         unselectedItemColor: const Color.fromARGB(255, 131, 151, 170),
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.info),
//             label: 'About',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.question_answer),
//             label: 'FAQ',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: 'Contact',
//           ),
//         ],
//         onTap: (index) {
//           setState(() {
//             myIndex = index;
//           });
//         },
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:motion_tab_bar/MotionBadgeWidget.dart';
import 'package:motion_tab_bar/MotionTabBar.dart';
import 'package:motion_tab_bar/MotionTabBarController.dart';

import '../pages/home.dart';
import '../pages/about.dart';
import '../pages/faq.dart';
import '../pages/contact.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key, required this.currentIndex});

  final int currentIndex;

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> with SingleTickerProviderStateMixin {
  late MotionTabBarController _motionTabBarController;
  int myIndex = 0;

  @override
  void initState() {
    super.initState();
    _motionTabBarController = MotionTabBarController(vsync: this, length: 4); // Update length to 5
  }

  @override
  void dispose() {
    _motionTabBarController.dispose();
    super.dispose();
  }

  final List<Widget> pages = [
    const Home(),
    const About(),
    const Faq(),
    const Contact(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[myIndex],
      bottomNavigationBar: MotionTabBar(
        controller: _motionTabBarController,
        initialSelectedTab: "Home",
        useSafeArea: true,
        labels: const ["Home", "About", "FAQ", "Contact"],
        icons: const [
          Icons.home,
          Icons.info,
          Icons.question_answer,
          Icons.person,
        ],
        badges: const [
          MotionBadgeWidget(
            textColor: Colors.white,
            color: Colors.red,
            size: 18,
          ),
          null,
          null,
          null,
          // null,  // No badge for Campus Ambassador
        ],
        tabSize: 50,
        tabBarHeight: 55,
        textStyle: const TextStyle(
          fontSize: 12,
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
        tabIconColor: Colors.blue[600],
        tabIconSize: 28.0,
        tabIconSelectedSize: 28.0,
        tabSelectedColor: Colors.blue[900],
        tabIconSelectedColor: Colors.white,
        tabBarColor: Colors.white,
        onTabItemSelected: (int value) {
          setState(() {
            _motionTabBarController.index = value;
            myIndex = value;
          });
        },
      ),
    );
  }
}