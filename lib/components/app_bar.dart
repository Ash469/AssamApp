import 'package:flutter/material.dart';
import 'package:endgame/components/app_drawer.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/app.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
                Scaffold.of(context).openDrawer();
            },
          ),
          title: Text(title),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(138);
}