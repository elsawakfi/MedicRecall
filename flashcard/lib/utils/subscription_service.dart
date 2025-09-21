import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_x/utils/subscription_data.dart';

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  SubscriptionData _subscription = SubscriptionData.free();
  bool _isLoaded = false;

  // Getters
  bool get isPaid => _subscription.isPaid;
  bool get isFree => _subscription.isFree;
  SubscriptionData get subscription => _subscription;
  String get subscriptionType => _subscription.type;
  String get subscriptionStatus => _subscription.status;

  // Load subscription from Firebase
  Future<void> loadSubscription() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where("userID", isEqualTo: user.uid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        Map<String, dynamic> userData = querySnapshot.docs.first.data() as Map<String, dynamic>;
        
        if (userData.containsKey("subscription")) {
          _subscription = SubscriptionData.fromMap(userData["subscription"]);
        } else {
          _subscription = SubscriptionData.free();
        }
        
        // Check if subscription has expired
        if (_subscription.expiryDate != null && 
            DateTime.now().isAfter(_subscription.expiryDate!) && 
            _subscription.type == "paid") {
          await _expireSubscription();
        }
        
        _isLoaded = true;
      }
    } catch (e) {
      print("Error loading subscription: $e");
      _subscription = SubscriptionData.free();
    }
  }

  // Upgrade to paid subscription
  Future<bool> upgradeToPaid(int monthsAdded) async {
    try {
      DateTime counterDate = DateTime.now();
      for (int i = 0; i < monthsAdded; i++){
        counterDate = addOneCalendarMonth(counterDate); 
      }
      DateTime expiryDate = counterDate;
      _subscription = SubscriptionData.paid(expiryDate: expiryDate);
      await _updateDatabase();
      return true;
    } catch (e) {
      print("Error upgrading subscription: $e");
      return false;
    }
  }

  // HELPER FUNCTION: Adds one calendar month
  DateTime addOneCalendarMonth(DateTime date) {
  int year = date.year;
  int month = date.month + 1;
  int day = date.day;

  // Handle overflow: if December, go to January of next year
  if (month > 12) {
    year += 1;
    month = 1;
  }

  // Get the last valid day of the target month
  int lastDayOfTargetMonth = DateTime(year, month, 0).day;

  // Clamp day to avoid overflow (e.g., Jan 31 → Feb 28/29)
  if (day > lastDayOfTargetMonth) {
    day = lastDayOfTargetMonth;
  }

  return DateTime(year, month, day);
}


  // Cancelled means they've cancelled auto-renew but still have access until expiry
  // Cancel subscription
  Future<bool> cancelSubscription() async {
    try {
      _subscription = SubscriptionData(
        type: _subscription.type,
        status: "cancelled",
        expiryDate: _subscription.expiryDate,
      );
      await _updateDatabase();
      return true;
    } catch (e) {
      print("Error cancelling subscription: $e");
      return false;
    }
  }

  // Expire subscription
  Future<void> _expireSubscription() async {
    _subscription = SubscriptionData(
      type: "free",
      status: "expired",
      expiryDate: _subscription.expiryDate,
    );
    await _updateDatabase();
  }

  // Save subscription to Firebase
  Future<void> _updateDatabase() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where("userID", isEqualTo: user.uid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(querySnapshot.docs.first.id)
            .update({
          "subscription": _subscription.toMap(),
          "stripeID": null
        });
      }
    } catch (e) {
      print("Error saving subscription: $e");
    }
  }


}

// Global instance
final subscriptionService = SubscriptionService();