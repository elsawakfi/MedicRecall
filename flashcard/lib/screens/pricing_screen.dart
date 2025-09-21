import 'package:flashcard_x/widgets/app_bar_title.dart';
import 'package:flutter/material.dart';
import 'package:flashcard_x/widgets/app_bar.dart';
import 'package:flashcard_x/utils/subscription_service.dart';
import 'package:flashcard_x/utils/stripe_utils.dart';
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

  Future<void> launchStripeWithUserId() async {
    final String userId = _getCurrentUserId();
    final String baseUrl = 'https://buy.stripe.com/test_dRm3co8B9dDe2pAfOX4ko01';
    //https://buy.stripe.com/test_dRm3co8B9dDe2pAfOX4ko01
    final String urlWithUserId = '$baseUrl?client_reference_id=${Uri.encodeComponent(userId)}';

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
        title: 'MedicRecall',
      ),
      body: subscriptionService.isPaid ? const PaidScreen() : const FreeScreen(),
      );
}

}

class FreeScreen extends StatefulWidget {
  const FreeScreen({super.key});

  @override
  State<FreeScreen> createState() => _FreeScreenState();
}

class _FreeScreenState extends State<FreeScreen> {
  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 35),
              Text(
                "Choose a Plan",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Lato',
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 25),
              Text(
                "All of our plans come with our 100% Money Back Guarantee!\nIf you don’t score in the top 50% of applicants on the Professional Dilemmas paper after using our platform, we will give you a full refund.",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  fontFamily: 'Lato',
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal, 
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PlanBox(
                        planTitle: "Monthly Subscription",
                        planCost: "£10 per month",
                        onCheckout: () => StripeUtils.launchStripeWithUserId(),
                      ),
                      SizedBox(width: 5),
                      PlanBox(
                        planTitle: "3-Month Package",
                        planCost: "£20 one-off payment",
                        onCheckout: () => StripeUtils.launchStripeWithUserId(),
                      ),
                      SizedBox(width: 5),
                      PlanBox(
                        planTitle: "6-Month Package",
                        planCost: "£30 one-off payment",
                        onCheckout: () => StripeUtils.launchStripeWithUserId(),
                      ),
                      SizedBox(width: 5),
                      PlanBox(
                        planTitle: "12-Month Package",
                        planCost: "£40 one-off payment",
                        onCheckout: () => StripeUtils.launchStripeWithUserId(),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        )
      );
  }
}

class PaidScreen extends StatefulWidget {
  const PaidScreen({super.key});

  @override
  State<PaidScreen> createState() => _PaidScreenState();
}

class _PaidScreenState extends State<PaidScreen> {
  
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 50),
            Text(
              "You are already subscribed to the paid plan.",
              style: TextStyle(
                fontSize: 18,
              )
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
            ),
          ],
        ),
      )
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

class PlanBox extends StatelessWidget {
  // PlanBox widget takes title, cost and checkout function
  final Future<void> Function() onCheckout;
  final String planTitle;
  final String planCost;
  const PlanBox({super.key, required this.onCheckout, required this.planTitle, required this.planCost});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Card(
        color: Colors.white,
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              SizedBox(height: 5),
              Text(
                planTitle,
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
                planCost,
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 35),
              IconButtonCustom(
                label: 'CHECKOUT',
                onPressed: onCheckout,
              )
            ]
          ),
        )
      ),
    );
  }
}