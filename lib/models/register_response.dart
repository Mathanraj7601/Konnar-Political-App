import "user_profile.dart";

class RegisterResponse {
  final String message;
  final String token;
  final UserProfile user;

  const RegisterResponse({
    required this.message,
    required this.token,
    required this.user,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      message: (json["message"] ?? "Registration successful").toString(),
      token: (json["token"] ?? "").toString(),
      user: UserProfile.fromJson(json["user"] as Map<String, dynamic>),
    );
  }
}
