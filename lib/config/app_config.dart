class AppConfig {
  static const String partyName = "SS Nantha Konnar Porpadai";
  static const String profileImageAsset = "assets/logo.png";
  static const String splashBackgroundAsset = "assets/splash_bg.png";

  static const bool useMockBackend = bool.fromEnvironment(
    "USE_MOCK_BACKEND",
    defaultValue: true,
  );

  static const String apiBaseUrl = String.fromEnvironment(
    "API_BASE_URL",
    defaultValue: "http://10.0.2.2:4000",
  );

  static const String demoOtp = String.fromEnvironment(
    "DEMO_OTP",
    defaultValue: "123456",
  );

  static const String _defaultDemoExistingMobile = "1234512345";

  static const String demoExistingMobile = String.fromEnvironment(
    "DEMO_EXISTING_MOBILE",
    defaultValue: _defaultDemoExistingMobile,
  );

  static String get effectiveDemoExistingMobile {
    final digitsOnly = demoExistingMobile.replaceAll(RegExp(r"\D"), "");

    if (digitsOnly.length == 10) {
      return digitsOnly;
    }

    if (digitsOnly.length == 11 && digitsOnly.startsWith("0")) {
      return digitsOnly.substring(1);
    }

    if (digitsOnly.length == 12 && digitsOnly.startsWith("91")) {
      return digitsOnly.substring(2);
    }

    return _defaultDemoExistingMobile;
  }

  static const int splashSeconds = 3;
  static const int otpExpirySeconds = 120;
}
