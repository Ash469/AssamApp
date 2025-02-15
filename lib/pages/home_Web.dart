import 'package:endgame/pages/edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:endgame/components/app_drawer.dart';
import 'new_application.dart';
import 'notifications.dart';
import 'application_status.dart';
import 'summary.dart';
import 'appointment.dart';
import 'invitation.dart';

class HomeWeb extends StatefulWidget {
  const HomeWeb({super.key});

  @override
  State<HomeWeb> createState() => _HomeState();
}

class _HomeState extends State<HomeWeb> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          // Web layout
          return _buildWebLayout(context);
        } else {
          // Mobile layout
          return _buildMobileLayout(context);
        }
      },
    );
  }

  Widget _buildWebLayout(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Notifications(),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Side menu with constraints
          Container(
            constraints: const BoxConstraints(maxWidth: 300),
            child: _buildSideMenu(),
          ),
          // Main content
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildWebHeader(context),
                ),
                SliverToBoxAdapter(
                  child: _buildHomePage(),
                ),
                SliverToBoxAdapter(
                  child: _buildSwiper(),
                ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(450), // Increase height for overlap
        child: Stack(
          clipBehavior: Clip.none, // Allow overlap
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
                        GestureDetector(
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
            // Overlapping effect using Positioned
            Positioned(
              top: 250, // Moves part of _buildHomePage above AppBar
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
      body: Column(  // Changed from SingleChildScrollView to Column
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 60), // reduced from 90
                  _buildHomePage(),
                ],
              ),
            ),
          ),
          // Fixed swiper section at bottom
          Container(
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 8), // reduced padding
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Updates',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Add your read more navigation here
                        },
                        child: Text(
                          'Read More',
                          style: TextStyle(
                            color: Colors.blue[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 180, // reduced height
                  child: Swiper(
                    itemBuilder: (BuildContext context, int index) {
                      return _buildEventCard(context, index);
                    },
                    itemCount: 5,
                    viewportFraction: 0.85,
                    scale: 0.9,
                    pagination: SwiperPagination(
                      margin: const EdgeInsets.only(top: 16),
                      builder: DotSwiperPaginationBuilder(
                        color: Colors.grey[300],
                        activeColor: Colors.blue[600],
                        size: 8,
                        activeSize: 10,
                        space: 4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8), // reduced bottom padding
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideMenu() {
    return ListView(
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
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 450,
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
    );
  }

  Widget _buildHomePage() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1200),
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 12), // reduced vertical margin
      padding: const EdgeInsets.all(16), // reduced padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth > 600 ? 6 : 3;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
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
              );
            },
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(36),
            ),
            child: icon,
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                height: 1.1,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwiper() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double height = constraints.maxWidth > 600 ? 300 : 196;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recent Updates header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Updates',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Add your read more navigation here
                    },
                    child: Text(
                      'Read More',
                      style: TextStyle(
                        color: Colors.blue[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Swiper with fixed height container
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              height: height,
              child: Swiper(
                itemBuilder: (BuildContext context, int index) {
                  return _buildEventCard(context, index);
                },
                itemCount: 5,
                viewportFraction: constraints.maxWidth > 600 ? 0.3 : 0.85,
                scale: 0.9,
                pagination: SwiperPagination(
                  margin: const EdgeInsets.only(top: 16),
                  builder: DotSwiperPaginationBuilder(
                    color: Colors.grey[300],
                    activeColor: Colors.blue[600],
                    size: 8,
                    activeSize: 10,
                    space: 4,
                  ),
                ),
                control: constraints.maxWidth > 600
                    ? const SwiperControl(
                        color: Colors.blue,
                        padding: EdgeInsets.all(16),
                      )
                    : null,
              ),
            ),
          ],
        );
      },
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
    final isWeb = MediaQuery.of(context).size.width > 600;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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
              height: isWeb ? 160 : 100, // Increased height for web
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: isWeb ? 160 : 100, // Increased height for web
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.grey[400],
                    size: isWeb ? 48 : 32, // Larger icon for web
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isWeb ? 16 : 8), // Increased padding for web
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  update['title']!,
                  style: TextStyle(
                    fontSize: isWeb ? 16 : 13, // Larger font for web
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: isWeb ? 2 : 1, // Two lines for web
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isWeb ? 8 : 4), // More spacing for web
                Text(
                  update['date']!,
                  style: TextStyle(
                    fontSize: isWeb ? 14 : 11, // Larger font for web
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebHeader(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/app_bar.png'),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.1),
                ],
              ),
            ),
          ),
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome, Rajesh',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Smart Office, Smarter Workdays',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white.withOpacity(0.9),
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

