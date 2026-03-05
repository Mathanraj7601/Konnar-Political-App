import "user_profile.dart";

class VerifyOtpResponse {
  final bool isNewUser;
  final String? token;
  final String? verificationToken;
  final UserProfile? user;
  final String message;

  const VerifyOtpResponse({
    required this.isNewUser,
    required this.message,
    this.token,
    this.verificationToken,
    this.user,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      isNewUser: json["isNewUser"] == true,
      message: (json["message"] ?? "OTP verified").toString(),
      token: json["token"]?.toString(),
      verificationToken: json["verificationToken"]?.toString(),
      user: json["user"] is Map<String, dynamic>
          ? UserProfile.fromJson(json["user"] as Map<String, dynamic>)
          : null,
    );
  }
}
