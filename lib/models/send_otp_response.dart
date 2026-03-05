class SendOtpResponse {
  final String message;
  final int expiresInSeconds;
  final String? debugOtp;

  const SendOtpResponse({
    required this.message,
    required this.expiresInSeconds,
    this.debugOtp,
  });

  factory SendOtpResponse.fromJson(Map<String, dynamic> json) {
    return SendOtpResponse(
      message: (json["message"] ?? "OTP sent").toString(),
      expiresInSeconds:
          int.tryParse((json["expiresInSeconds"] ?? "120").toString()) ?? 120,
      debugOtp: json["debugOtp"]?.toString(),
    );
  }
}
