import 'package:endgame/components/app_drawer.dart';
import 'package:endgame/pages/edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';

import 'new_application.dart';
import 'notifications.dart';
import 'application_status.dart';
import 'summary.dart';
import 'appointment.dart';
import 'invitation.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
                                'Hello, Rajesh',
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
              top: 250,
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
            const SizedBox(height: 90),
            _buildSwiper(),
          ],
        ),
      ),
      
     
    );
  }

  Widget _buildHomePage() {
    return SizedBox(
      height: 350,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 18),
            padding: const EdgeInsets.fromLTRB(10,2,10,2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
                boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  // blurRadius: 0,
                  // spreadRadius: 5,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 0,
                  childAspectRatio: 1.0,
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
                    _buildMenuItem(
                      icon: Image.asset(
                        'assets/appointment.png',
                        height: 38,
                        width: 38,
                      ),
                      label: 'Appointments',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AppointmentPage(),
                        ),
                      ),
                      iconColor: Colors.red[600]!,
                      bgColor: Colors.red[50]!,
                    ),
                    _buildMenuItem(
                      icon: Image.asset(
                        'assets/invitation.png',
                        height: 38,
                        width: 38,
                      ),
                      label: 'Invitations',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Invitation(),
                        ),
                      ),
                      iconColor: Colors.purple[600]!,
                      bgColor: Colors.purple[50]!,
                    ),
                    _buildMenuItem(
                      icon: Image.asset(
                        'assets/edit_profile.png',
                        height: 38,
                        width: 38,
                      ),
                      label: 'Edit Profile',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfile(),
                        ),
                      ),
                      iconColor: Colors.teal[600]!,
                      bgColor: Colors.teal[50]!,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 5),
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
      // borderRadius: BorderRadius.circular(36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(36),
            ),
            child: icon,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              height: 1.2,
              fontWeight: FontWeight.w500,
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
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              image,
              width: double.infinity,
              height: 150,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
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
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      height: 196,
      width: double.infinity,
      child: Swiper(
        itemBuilder: (BuildContext context, int index) {
          return _buildEventCard(context, index);
        },
        itemCount: 5,
        viewportFraction: 0.7, // Adjusted to center the first card
        scale: 0.75, // Adjusted for better scaling effect
        pagination: SwiperPagination(
          margin: const EdgeInsets.only(top: 16),
          builder: DotSwiperPaginationBuilder(
            color: Colors.grey[300],
            activeColor: Colors.blue[600],
            size: 4,
            activeSize: 6,
            space: 4,
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, int index) {
    final updates = [
      {
        'image': 'assets/image.jpg',
        'title': 'Judul Informasi Diklat',
        'date': '29 March 2024 14:31 IST',
      },
      {
        'image': 'assets/image.jpg',
        'title': 'Judul Informasi Lainnya',
        'date': '29 March 2024 14:31 IST',
      },
      {
        'image': 'assets/image.jpg',
        'title': 'Judul Informasi Lainnya',
        'date': '29 March 2024 14:31 IST',
      },
      {
        'image': 'assets/image.jpg',
        'title': 'Judul Informasi Lainnya',
        'date': '29 March 2024 14:31 IST',
      },
      {
        'image': 'assets/image.jpg',
        'title': 'Judul Informasi Lainnya',
        'date': '29 March 2024 14:31 IST',
      },
    ];

    final update = updates[index];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(
              update['image']!,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 120,
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.grey[400],
                    size: 32,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  update['title']!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  update['date']!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

