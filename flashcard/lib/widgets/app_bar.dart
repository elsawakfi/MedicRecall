import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;  // Variable for the title text

  const CustomAppBar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
        elevation: 0,
        title: Align(
          alignment: const Alignment(-1.0, 0),
          child: Stack(
            children: [
              Positioned(
                top: 2.3,
                child: Image.asset(
                  'assets/newlogo.png',
                  fit: BoxFit.cover,
                  height: 34,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 32),
                padding: const EdgeInsets.all(8.0),
                child: Text(title,  // Use the variable for the title text
                textAlign: TextAlign.left
                )
              ),
            ],
          ),
        ),
        centerTitle: false,
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
