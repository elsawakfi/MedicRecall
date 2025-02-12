class LandingService {
  static final LandingService _instance = LandingService._internal();
  factory LandingService() => _instance;
  LandingService._internal();

  bool onLanding = false; // Default to false
}

LandingService landingService = LandingService();