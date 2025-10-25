import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:collection';
import 'package:web/web.dart' as web;

class StripeUtils {
  static String _getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  static Future<void> launchStripeWithUserId(int months) async {

    HashMap<int, String> urls = HashMap.from({

      //TEST VERSIONS
     // 1 : "https://buy.stripe.com/test_cNidR28B99mY1lwauD4ko06",//"https://buy.stripe.com/test_5kQ7sE9FdeHi4xI32b4ko02",
    //  3 : "https://buy.stripe.com/test_cNi28sd4dfaS6wCb2G1sQ02", //changed to dr.harris'
    //   6 : "https://buy.stripe.com/test_cNicN6aW5geW9IOfiW1sQ01", //changed to dr. harris' stripe
    //   12 : "https://buy.stripe.com/test_4gM3cwggp0fYaMS4Ei1sQ03" //changed to dr.harris'

      //Real Payments
      3 : "https://buy.stripe.com/cNi4gA2pz7Iq4ou6Mq1sQ04", 
      6: "https://buy.stripe.com/dRm6oI0hraUC8EKfiW1sQ05",
      12: "https://buy.stripe.com/4gM3cwggp0fYaMS4Ei1sQ03"
    });
    final String baseUrl = urls[months]!;
    final String userId = _getCurrentUserId();
    //final String baseUrl = 'https://buy.stripe.com/test_dRm3co8B9dDe2pAfOX4ko01';
    final String urlWithUserId = '$baseUrl?client_reference_id=${Uri.encodeComponent(userId)}';
    //some warnings about this package:web will need thorough testing to ensure it works. 
    web.window.location.assign(urlWithUserId);
    // final Uri uri = Uri.parse(urlWithUserId);
    // if (!await launchUrl(uri, mode: LaunchMode.inAppWebView)) {
      
    //   throw Exception('Could not launch $uri');
    // }
  }
}