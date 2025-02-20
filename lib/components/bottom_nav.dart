// import 'package:flutter/material.dart';
// import '../pages/home_Web.dart';
// import '../pages/home.dart';
// import '../pages/about.dart';
// import '../pages/faq.dart';
// import '../pages/contact.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;

// class BottomNavBar extends StatefulWidget {
//   const BottomNavBar({super.key, required this.currentIndex});

//   final int currentIndex;

//   @override
//   State<BottomNavBar> createState() => _BottomNavBarState();
// }

// class _BottomNavBarState extends State<BottomNavBar> {
//   int myIndex = 0;

//  final List<Widget> pages = [
//     kIsWeb ? const HomeWeb() : const Home(),
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
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../pages/home_Web.dart';
import '../pages/home.dart';
import '../pages/about.dart';
import '../pages/faq.dart';
import '../pages/contact.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key, required this.currentIndex});

  final int currentIndex;

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int myIndex = 0;
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  late final List<Widget> pages = [
    kIsWeb ? const HomeWeb() : const Home(),
    const About(),
    const Faq(),
    const Contact(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[myIndex],
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: 0,
        height: 50, // Increased height
        items: const <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.home, size: 28), // Increased icon size
              Text('Home', style: TextStyle(fontSize: 12)), // Increased text size
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info, size: 28),
              Text('About', style: TextStyle(fontSize: 12)),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.question_answer, size: 28),
              Text('FAQ', style: TextStyle(fontSize: 12)),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person, size: 28),
              Text('Contact', style: TextStyle(fontSize: 12)),
            ],
          ),
        ],
        color: Colors.white,
        buttonBackgroundColor: Colors.white,
        backgroundColor: Colors.blueAccent,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 600),
        onTap: (int index) {
          setState(() {
            myIndex = index;
          });
        },
      ),
    );
  }
}
