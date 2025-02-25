class LandingService {
  static final LandingService _instance = LandingService._internal();
  factory LandingService() => _instance;
  LandingService._internal();

  bool onLanding = false; 
}

LandingService landingService = LandingService();