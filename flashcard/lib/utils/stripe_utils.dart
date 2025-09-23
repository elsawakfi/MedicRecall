import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:collection';

class StripeUtils {
  static String _getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  static Future<void> launchStripeWithUserId(int months) async {

    HashMap<int, String> urls = HashMap.from({
      1 : "https://buy.stripe.com/test_cNidR28B99mY1lwauD4ko06",//"https://buy.stripe.com/test_5kQ7sE9FdeHi4xI32b4ko02",
      3 : "https://buy.stripe.com/test_7sY3co7x5gPq9S21Y74ko03",
      6 : "https://buy.stripe.com/test_3cI5kw3gPcza7JU46f4ko04",
      12 : "https://buy.stripe.com/test_9B63coeZx2YAe8ifOX4ko05"
    });

    final String baseUrl = urls[months]!;
    final String userId = _getCurrentUserId();
    //final String baseUrl = 'https://buy.stripe.com/test_dRm3co8B9dDe2pAfOX4ko01';
    final String urlWithUserId = '$baseUrl?client_reference_id=${Uri.encodeComponent(userId)}';

    final Uri uri = Uri.parse(urlWithUserId);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $uri');
    }
  }
}