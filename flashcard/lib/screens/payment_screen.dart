import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_x/screens/landing_screen_new.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentScreen extends StatefulWidget {
  static String id = 'payment';

  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String userName = '';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _getUserName();
  }

  Future<void> _getUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userName = user.displayName ?? user.email?.split('@')[0] ?? 'User';
        loading = false;
      });
    }
  }

  void _navigateToHome() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('payment_screen_seen', true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const NewLanding(),
      ),
    );
  }

  Widget _buildSubscriptionCard({
    required String title1,
    required String title2,
    required String price,
    required VoidCallback onCheckout,
  }) {
    return Expanded(
      child: Container(
        height: 250, // Fixed height
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title1,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title2,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      price,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 40, // Fixed button height
              child: ElevatedButton(
                onPressed: onCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'CHECKOUT',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: const Alignment(-0.06, 0),
          child: Stack(
            children: [
              Positioned(
                top: 4,
                child: Image.asset(
                  'assets/dashboard_assets/app_logo4.png',
                  fit: BoxFit.cover,
                  height: 34,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 30),
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Payment",
                  style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              width: double.infinity,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                    top: 40, left: 20, right: 20, bottom: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Choose a plan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        children: [
                          Text.rich(
                            TextSpan(
                              text:
                                  'All plans come with a 100% money back guarantee. If you don\'t score above average on the Professional Dilemmas Paper, we will give you a full refund.',
                              style: const TextStyle(
                                fontSize: 25,
                                color: Colors.white,
                              ),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          /*const Text(
                            'on the Professional Dilemmas Paper, we will give you a full refund.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 25,
                              color: Colors.white,
                              height: 1.5,
                            ),
                          ),*/
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSubscriptionCard(
                          title1: 'Monthly',
                          title2: 'Subscription',
                          price: '£10 per month',
                          onCheckout: _navigateToHome,
                        ),
                        const SizedBox(width: 10),
                        _buildSubscriptionCard(
                          title1: '3-Month',
                          title2: 'Package',
                          price: '£20 one-off payment',
                          onCheckout: _navigateToHome,
                        ),
                        const SizedBox(width: 10),
                        _buildSubscriptionCard(
                          title1: '6-Month',
                          title2: 'Package',
                          price: '£30 one-off Payment',
                          onCheckout: _navigateToHome,
                        ),
                        const SizedBox(width: 10),
                        _buildSubscriptionCard(
                          title1: '12-Month',
                          title2: 'Package',
                          price: '£40 one-off payment',
                          onCheckout: _navigateToHome,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
