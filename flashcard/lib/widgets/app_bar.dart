import 'package:flutter/material.dart';
import 'package:flashcard_x/widgets/design_main.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title; // Variable for the title text
  final String? mobileTitle; // Optional mobile title

  const CustomAppBar({
    super.key,
    required this.title,
    this.mobileTitle, // Add optional mobile title parameter
  });

  @override
  Widget build(BuildContext context) {
    // Check if we're on a small screen
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return AppBar(
      elevation: 0,
      title: Align(
        alignment: const Alignment(-0.05, 0),
        child: Stack(
          children: [
            Positioned(
              top: 2.3,
              child: Image.asset(
                DesignMain.getThemeBasedLogo(context),
                fit: BoxFit.cover,
                height: 34,
              ),
            ),
            Container(
                margin: const EdgeInsets.only(left: 32),
                padding: const EdgeInsets.all(8.0),
                child: Text(isSmallScreen ? (mobileTitle ?? title) : title)),
          ],
        ),
      ),
      centerTitle: true,
      leading: Builder(
        builder: (context) => GestureDetector(
          onTap: () => Scaffold.of(context).openDrawer(),
          child: const Icon(Icons.menu),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
