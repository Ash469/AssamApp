import 'package:endgame/components/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'new_application.dart';
import 'notifications.dart';
import 'application_status.dart';
import 'summary.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('userData');
    if (userDataString != null) {
      final userData = json.decode(userDataString);
      setState(() {
        userName = userData['firstName'] ?? 'User';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(450),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 800,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/app_bar.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 60, 16, 22),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Builder(
                          builder: (context) => GestureDetector(
                            onTap: () {
                              Scaffold.of(context).openDrawer();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const CircleAvatar(
                                radius: 40,
                                backgroundImage: AssetImage('assets/logo.jpg'),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.notifications,
                              color: Colors.white,
                              size: 24,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Notifications(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, $userName',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 26,
                                    letterSpacing: 1.5,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Smart Office, Smarter Workdays',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.white.withOpacity(0.8),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    letterSpacing: 0.8,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 300,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  _buildHomePage(),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            _buildSwiper(),
          ],
        ),
      ),
    );
  }

  Widget _buildHomePage() {
    final screenSize = MediaQuery.of(context).size;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 1),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
            padding: EdgeInsets.symmetric(
              vertical: 8, 
              horizontal: screenSize.width * 0.03,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.blue.withOpacity(0.5),
                width: 2.0,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.blue.shade50.withOpacity(0.3),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.1),
                  blurRadius: 15,
                  spreadRadius: 1,
                  offset: const Offset(0, 5),
                ),
                BoxShadow(
                  color: Colors.indigo.withOpacity(0.05),
                  blurRadius: 30,
                  spreadRadius: 5,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      mainAxisSpacing: constraints.maxWidth < 300 ? 2 : 5,
                      crossAxisSpacing: constraints.maxWidth < 300 ? 5 : 10,
                      childAspectRatio: constraints.maxWidth < 300 ? 1.2 : 0.9,
                      padding: EdgeInsets.all(constraints.maxWidth * 0.02),
                      children: [
                        _buildMenuItem(
                          icon: Image.asset(
                            'assets/new_application.png',
                            height: 38,
                            width: 38,
                          ),
                          label: 'New\nApplication',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NewApplication(),
                            ),
                          ),
                          iconColor: Colors.blue[600]!,
                          bgColor: Colors.blue[50]!,
                        ),
                        _buildMenuItem(
                          icon: Image.asset(
                            'assets/application_status.png',
                            height: 38,
                            width: 38,
                          ),
                          label: 'Application\nStatus',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ApplicationStatusPage(),
                            ),
                          ),
                          iconColor: Colors.indigo[600]!,
                          bgColor: Colors.indigo[50]!,
                        ),
                        _buildMenuItem(
                          icon: Image.asset(
                            'assets/summary.png',
                            height: 38,
                            width: 38,
                          ),
                          label: 'Summary',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SummaryPage(),
                            ),
                          ),
                          iconColor: Colors.indigo[600]!,
                          bgColor: Colors.indigo[50]!,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent updates',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        fontSize: 18,
                      ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Read more',
                    style: TextStyle(
                      color: Colors.blue[600],
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required Widget? icon,
    required String label,
    required VoidCallback onTap,
    required Color iconColor,
    required Color bgColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: icon,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              height: 1.2,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateCard({
    required String image,
    required String title,
    required String date,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(
              image,
              width: double.infinity,
              height: 160,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwiper() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 30),
      height: 220,
      width: double.infinity,
      child: Swiper(
        itemBuilder: (BuildContext context, int index) {
          return _buildEventCard(context, index);
        },
        itemCount: 5,
        viewportFraction: 0.8,
        scale: 0.85,
        pagination: SwiperPagination(
          margin: const EdgeInsets.only(top: 20),
          builder: DotSwiperPaginationBuilder(
            color: Colors.grey[300],
            activeColor: Colors.blue[700],
            size: 6,
            activeSize: 8,
            space: 5,
          ),
        ),
        autoplay: true,
        autoplayDelay: 5000,
        duration: 800,
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, int index) {
    final updates = [
      {
        'image': 'assets/image.jpg',
        'title': 'Judul Informasi Diklat',
        'date': '29 March 2024',
      },
      {
        'image': 'assets/image.jpg',
        'title': 'Judul Informasi Lainnya',
        'date': '29 March 2024',
      },
      {
        'image': 'assets/image.jpg',
        'title': 'Judul Informasi Lainnya',
        'date': '29 March 2024',
      },
      {
        'image': 'assets/image.jpg',
        'title': 'Judul Informasi Lainnya',
        'date': '29 March 2024',
      },
      {
        'image': 'assets/image.jpg',
        'title': 'Judul Informasi Lainnya',
        'date': '29 March 2024',
      },
    ];

    final update = updates[index];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: Image.asset(
              update['image']!,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.image_not_supported_rounded,
                      color: Colors.grey[400],
                      size: 36,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  update['title']!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      update['date']!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

