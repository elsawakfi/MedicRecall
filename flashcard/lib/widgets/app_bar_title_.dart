import 'package:flashcard_x/widgets/title_bar.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'drawer_widget.dart';
// import 'package:flashcard_x/screens/exam_answers.dart'; 

AppBar buildAppBar(BuildContext context, bool showBack) {
  final isSmallScreen = MediaQuery.of(context).size.width < 600;
  return AppBar(
    
    title: 
    
    Stack(
      
      children: [
        Positioned(
          top: 3,
          child: Image.asset(
          'assets/newlogo.png',
          fit: BoxFit.cover,
          height: isSmallScreen ? 28 : 34,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 50),
          padding: const EdgeInsets.all(10),
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
AppBar buildAppBarWithTitle(BuildContext context, bool showBack, String appBarTitle) {
  return AppBar(
    titleSpacing: -500,
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
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool? resizeToAvoidBottomInset;
  final Widget? bottomNavigationBar;
  final DateTime? examEndTime;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.showBack,
    this.backgroundColor,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.resizeToAvoidBottomInset,
    this.bottomNavigationBar,
    this.examEndTime,
    });

  @override
  AppScaffoldState createState() => AppScaffoldState();
}

class AppScaffoldState extends State<AppScaffold> {
  Timer? _timer;
  Duration _remainingTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    if (widget.examEndTime != null) {
      _remainingTime = widget.examEndTime!.difference(DateTime.now());
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final diff = widget.examEndTime!.difference(DateTime.now());
        if (diff.inSeconds > 0) {
          setState(() {
            _remainingTime = diff;
          });
        } else {
          timer.cancel();
          if (mounted) {
//           Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (context) => ExamAnswersPage(
//       rankingCorrectList: [],
//       rankingTotalLength: 30,
//       mcCorrectList: [],
//       mcTotalLength: 20,
//     ),
//   ),
// );
          }}
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  
  String get formattedRemainingTime {
    final minutes = _remainingTime.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = _remainingTime.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
   

    return Scaffold(
      drawer: const DrawMain(),
      backgroundColor: widget.backgroundColor ?? theme.scaffoldBackgroundColor,
      appBar: buildAppBar(context, widget.showBack ?? false),
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
      bottomNavigationBar: widget.bottomNavigationBar,
      body: Column(
        children: [
          
          ScreenTitleBar(title: widget.title),
          Expanded(child: widget.body),
        ],
      ),
    );
  }
}