import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StripeUtils {
  static String _getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  static Future<void> launchStripeWithUserId() async {
    final String userId = _getCurrentUserId();
    final String baseUrl = 'https://buy.stripe.com/test_dRm3co8B9dDe2pAfOX4ko01';
    final String urlWithUserId = '$baseUrl?client_reference_id=${Uri.encodeComponent(userId)}';

    final Uri uri = Uri.parse(urlWithUserId);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $uri');
    }
  }
}