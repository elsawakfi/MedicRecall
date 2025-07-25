import 'package:flashcard_x/widgets/app_bar_title.dart';
import 'package:flutter/material.dart';
import 'package:flashcard_x/widgets/app_bar.dart';
import 'package:flashcard_x/utils/subscription_service.dart';
import 'package:flashcard_x/widgets/stripe_pricing_table.dart';


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
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              Text(
                subscriptionService.isPaid
                    ? "You are subscribed to the paid plan."
                    : "You are on the free plan.",
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: SubscriptionPricingTable(),
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}