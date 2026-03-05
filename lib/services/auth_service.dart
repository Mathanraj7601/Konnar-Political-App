import "../models/register_response.dart";
import "../models/registration_request.dart";
import "../models/send_otp_response.dart";
import "../models/verify_otp_response.dart";
import "api_client.dart";

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  Future<SendOtpResponse> sendOtp(String mobile) async {
    final response = await _apiClient.post(
      "/auth/send-otp",
      body: {"mobile": mobile},
    );

    return SendOtpResponse.fromJson(response);
  }

  Future<bool> checkUserExists(String mobile) async {
    final response = await _apiClient.post(
      "/auth/check-user",
      body: {"mobile": mobile},
    );

    return response["exists"] == true;
  }

  Future<VerifyOtpResponse> verifyOtp({
    required String mobile,
    required String otp,
  }) async {
    final response = await _apiClient.post(
      "/auth/verify-otp",
      body: {"mobile": mobile, "otp": otp},
    );

    return VerifyOtpResponse.fromJson(response);
  }

  Future<RegisterResponse> register(RegistrationRequest request) async {
    final response = await _apiClient.post(
      "/auth/register",
      body: request.toJson(),
    );

    return RegisterResponse.fromJson(response);
  }
}
