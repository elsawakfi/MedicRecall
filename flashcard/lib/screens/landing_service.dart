class LandingService {
  static final LandingService _instance = LandingService._internal();
  factory LandingService() => _instance;
  LandingService._internal();

  bool onLanding = false; 
  bool stopShowing = false;
}

LandingService landingService = LandingService();