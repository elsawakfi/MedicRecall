import 'package:flashcard_x/widgets/app_bar_title.dart';
import 'package:flutter/material.dart';
import 'package:flashcard_x/widgets/app_bar.dart';
import 'package:flashcard_x/utils/subscription_service.dart';
import 'package:flashcard_x/widgets/stripe_pricing_table.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_x/screens/landing_screen_new.dart';



class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key});

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSubscription();
  }

  Future<void> _loadSubscription() async {
    await subscriptionService.loadSubscription();
    setState(() {
      _loading = false;
    });
  }

  String _getCurrentUserId() {
  return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  Future<void> _launchStripeWithUserId() async {
    final String userId = _getCurrentUserId();
    final String baseUrl = 'https://billing.stripe.com/p/login/test_eVqfZa8B98iU5BM7ir4ko00';
    final String urlWithUserId = '$baseUrl?client_reference_id=$userId';

    final Uri uri = Uri.parse(urlWithUserId);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $uri');
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Plan',
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 25),
              Text(
                "Choose a Plan",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Lato',
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 25),
              Text(
                "All plans come with a 100% money back guarantee.\nIf you don't score above average on the Professional Dilemmas Paper, we will give you a full refund.",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  fontFamily: 'Lato',
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    SizedBox(height: 100),
                    Card(
                      color: Colors.white,
                      elevation: 15,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:[
                            SizedBox(height: 5),
                            Text(
                              "Monthly\nSubscription",
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w900,
                                fontSize: 24,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            SizedBox(height: 5),
                            Text(
                              "£10 per month",
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            SizedBox(height: 10),
                            IconButtonCustom(
                              label: 'CHECKOUT',
                              onPressed: () => _launchStripeWithUserId(),
                            )
                          ]
                        ),
                      )
                    ),
                  ]
                ),
              )
            ],
          ),
        )
      ),
    );
}
}

class IconButtonCustom extends StatelessWidget {
  
  const IconButtonCustom({super.key, 
    required this.label,
    required this.onPressed,
    this.iconFilePath,
  });

  final String label;
  final Future<void> Function() onPressed;
  final String? iconFilePath;

  @override
  Widget build(BuildContext context) {
    //final theme = Theme.of(context);
    //final themeProvider = Provider.of<ThemeProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          //backgroundColor: themeProvider.isDarkMode ? Colors.black : Color.fromRGBO(44, 44, 44, 1),
          backgroundColor: Colors.black,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconFilePath != null) ...[
              Image.asset(
                width: 30,
                iconFilePath!,
              ),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Text(
              label,
              textAlign: TextAlign.center,
                style: textStyle1,
              ),
            ),
          ]
        ),
        )
      );
  }
}