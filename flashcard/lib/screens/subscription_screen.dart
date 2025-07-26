import 'package:flashcard_x/widgets/app_bar_title.dart';
import 'package:flutter/material.dart';
import 'package:flashcard_x/widgets/app_bar.dart';
import 'package:flashcard_x/utils/subscription_service.dart';
import 'package:flashcard_x/widgets/stripe_pricing_table.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_x/screens/landing_screen_new.dart';



class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
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
        title: 'Subscription',
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 50),
              Text(
                subscriptionService.isPaid
                    ? "You are subscribed to the paid plan."
                    : "You are on the free plan.",
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                child: IconButtonCustom(
                  label: 'Subscription Plans',
                  onPressed: () => _launchStripeWithUserId(),
                ),
              ),
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

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            elevation: 4,
            //backgroundColor: themeProvider.isDarkMode ? Colors.black : Color.fromRGBO(44, 44, 44, 1),
            backgroundColor: Colors.black,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Row(
            children: [
              SizedBox(width: 15), 
              if (iconFilePath != null) ...[
                Image.asset(
                  width: 30,
                  iconFilePath!,
                ),
              ],
              Expanded(
                child: Text(
                label,
                textAlign: TextAlign.center,
                  style: textStyle1,
                ),
              ),
            ]
          ),
          )
        ),
      );
  }
}