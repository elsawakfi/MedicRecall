import 'package:flutter/material.dart';

import 'drawer_widget.dart';

class AppBarTitle extends StatelessWidget {
  const AppBarTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/firebase_logo.png',
          height: 20,
        ),
        const SizedBox(width: 8),
        const Text(
          'FlutterFire',
          style: TextStyle(
            color: Colors.yellow,
            fontSize: 18,
          ),
        ),
        const Text(
          ' Authentication',
          style: TextStyle(
            color: Colors.deepOrange,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}


AppBar buildAppBar(BuildContext context, bool showBack) {
  return AppBar(
    title: Stack(
      children: [
        Positioned(
          top: 2.3,
          child: Image.asset(
            'assets/app_logo4.png',
            fit: BoxFit.cover,
            height: 34,
            colorBlendMode: BlendMode.srcIn,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 32),
          padding: const EdgeInsets.all(8.0),
          child: const Text('MedicRecall'),
        ),
      ],
    ),
    centerTitle: true,
    elevation: 0,
    leading: Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return GestureDetector(
          onTap: showBack
              ? () => Navigator.of(context).pop()
              : () => Scaffold.of(context).openDrawer(),
          child: Icon(
            showBack ? Icons.arrow_back_rounded : Icons.menu,
            color: theme.iconTheme.color,
          ),
        );
      },
    ),
  );
}


AppBar buildAppBarWithTitle(
    BuildContext context, bool showBack, String appBarTitle) {
  return AppBar(
    title: Text(appBarTitle),
    centerTitle: true,
    elevation: 0,
    leading: Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return GestureDetector(
          onTap: showBack
              ? () => Navigator.of(context).pop()
              : () => Scaffold.of(context).openDrawer(),
          child: Icon(
            showBack ? Icons.arrow_back_rounded : Icons.menu,
            color: theme.iconTheme.color,
          ),
        );
      },
    ),
  );
}

class AppScaffold extends StatefulWidget {
  final String title;
  final Widget body;
  final Color? backgroundColor;
  final bool? showBack;
  final Widget? floatingActionButton;
  final bool? resizeToAvoidBottomInset;
  final Widget? bottomNavigationBar;


  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.showBack,
    this.backgroundColor,
    this.floatingActionButton,
    this.resizeToAvoidBottomInset,
    this.bottomNavigationBar,
  });

  @override
  AppScaffoldState createState() => AppScaffoldState();
}

class AppScaffoldState extends State<AppScaffold> {
  

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      drawer: const DrawMain(),
      backgroundColor: widget.backgroundColor ?? theme.scaffoldBackgroundColor,
      appBar: buildAppBar(context, widget.showBack ?? false),
      floatingActionButton: widget.floatingActionButton,
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
      bottomNavigationBar: widget.bottomNavigationBar,
      body: Column(
        children: [
          
          Expanded(child: widget.body),
        ],
      ),
    );
  }
}
