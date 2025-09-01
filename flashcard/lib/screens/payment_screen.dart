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
    // Mark payment screen as seen
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
      child: AspectRatio(
        aspectRatio: 1.05, // Width:Height = 1.05:1
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // First line - bold, 30px
          Text(
            title1,
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          // Second line - bold, 30px
          Text(
            title2,
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 30),
          
          Text(
            price,
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
            ],
          ),
      
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                'CHECKOUT',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ),
        ],
          ),
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
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              width: double.infinity,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Choose a plan title
                    const Text(
                      'Choose a plan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize:42, // 36 * 2 = 72
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Money back guarantee text
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        children: [
                          Text(
                            'All plans come with a 100% money back guarantee. If you don\'t score above average',
                            textAlign: TextAlign.justify,
                            style: const TextStyle(
                              fontSize: 25, 
                              color: Colors.white,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'on the Professional Dilemmas Paper, we will give you a full refund.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 25, 
                              color: Colors.white,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Subscription cards - horizontal layout
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSubscriptionCard(
                          title1: 'Monthly',
                          title2: 'Subscription',
                          price: '£10 per month',
                          onCheckout: _navigateToHome,
                        ),
                        
                        const SizedBox(width: 5),
                        
                        _buildSubscriptionCard(
                          title1: '3-Month',
                          title2: 'Package',
                          price: '£20 one-off payment',
                          onCheckout: _navigateToHome,
                        ),
                        
                        const SizedBox(width: 5),
                        
                        _buildSubscriptionCard(
                          title1: '6-Month',
                          title2: 'Package',
                          price: '£30 one-off Payment',
                          onCheckout: _navigateToHome,
                        ),
                        
                        const SizedBox(width: 5),
                        
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