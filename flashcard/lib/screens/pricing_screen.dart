import 'package:flashcard_x/widgets/app_bar_title.dart';
import 'package:flashcard_x/widgets/drawer_widget2.dart';
import 'package:flutter/material.dart';
import 'package:flashcard_x/widgets/app_bar.dart';
import 'package:flashcard_x/utils/subscription_service.dart';
import 'package:flashcard_x/utils/stripe_utils.dart';
import 'package:flashcard_x/widgets/stripe_pricing_table.dart';
import 'package:intl/intl.dart';
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
      drawer: const DrawMain2(),
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
              SizedBox(height: 35),
              Text(
                "All our plans come with a *24-hour Free Trial and **Money Back Guarantee",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  fontFamily: 'Lato',
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal, 
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PlanBox(
                        planTitle: "3-Month Package",
                        planCost: "£20 one-off payment",
                        onCheckout: () => StripeUtils.launchStripeWithUserId(3),
                      ),
                      SizedBox(width: 5),
                      PlanBox(
                        planTitle: "6-Month Package",
                        planCost: "£30 one-off payment",
                        onCheckout: () => StripeUtils.launchStripeWithUserId(6),
                      ),
                      SizedBox(width: 5),
                      PlanBox(
                        planTitle: "12-Month Package",
                        planCost: "£40 one-off payment",
                        onCheckout: () => StripeUtils.launchStripeWithUserId(12),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 25),
              Text(
               "*24-hour Free Trial: Cancel your subscription within 24 hours and receive a refund."
                  ,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w300,
                  fontFamily: 'Lato',
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,),
                SizedBox(height: 10),
              Text(
               "**Money Back Guarantee: Receive a full refund if you do not score above average in the PD paper."
                  ,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w300,
                  fontFamily: 'Lato',
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,)
            ],
          ),
        )
      );
  }
  // 
                
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
            SizedBox(height: 15),
            Text(
              "My Plan: ",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                fontFamily: 'Lato',
              ),
            ),
            SizedBox(height: 25),
            Text(
              "Your subscription expires on: ${DateFormat("d MMMM y").format(subscriptionService.subscriptionExpiry!)}",
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w300,
              ),
                textAlign: TextAlign.center,),
             SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                    children: [
                      TextSpan(text: "Visit our "),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () async {
                            final Uri url = Uri.parse('https://medicrecall.com/terms-and-conditions/');
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url, mode: LaunchMode.externalApplication);
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Could not open Terms and Conditions page'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          child: Text(
                            "Terms and Conditions",
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      TextSpan(text: " page for more information on how to claim our 24-Hour free trial and Money Back Guarantee."),
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
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
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

class PlanBoxViewOnly extends StatelessWidget {
  // PlanBox widget takes title, cost and checkout function
  final String planTitle;
  final String planCost;
  const PlanBoxViewOnly({super.key, required this.planTitle, required this.planCost});

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
              SizedBox(height: 30)
            ]
          ),
        )
      ),
    );
  }
}