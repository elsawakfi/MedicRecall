import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionData {
  final String type;
  final String status;
  final DateTime? expiryDate;

  SubscriptionData({
    required this.type,
    required this.status,
    this.expiryDate,
  });

  bool get isPaid {
    if (type == "paid"){
      if (expiryDate == null){
        return true; // LIFETIME SUBSCRIPTION
      }
      else{
        return DateTime.now().isBefore(expiryDate!); // EXPIRED SUBSCRIPTION
      }
    }
    return false; // FREE SUBSCRIPTION
  }

  bool get isFree {
    return !isPaid;
  }

  Map<String, dynamic> toMap() {
    return {
      "subscriptionType": type,
      "subscriptionStatus": status,
      "subscriptionExpiryDate": expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
    };
  }

  factory SubscriptionData.fromMap(Map<String, dynamic> map) {
    return SubscriptionData(
      type: map['subscriptionType'] ?? 'free',
      status: map['subscriptionStatus'] ?? 'active',  // ✅ Use "status", not "active"
      expiryDate: map['subscriptionExpiryDate'] != null 
          ? (map['subscriptionExpiryDate'] as Timestamp).toDate() 
          : null,
    );
  }

  factory SubscriptionData.free() {
    return SubscriptionData(
      type: "free",
      status: "active",
      expiryDate: null,
    );
  }

  factory SubscriptionData.paid({DateTime? expiryDate}) {
    return SubscriptionData(
      type: "paid",
      status: "active",
      expiryDate: expiryDate,
    );
  }
}