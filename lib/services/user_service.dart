import "../models/member_card.dart";
import "../models/user_profile.dart";
import "api_client.dart";

class UserService {
  final ApiClient _apiClient;

  UserService(this._apiClient);

  Future<UserProfile> getProfile(String token) async {
    final response = await _apiClient.get("/user/profile", token: token);
    final payload = response["user"];

    if (payload is! Map<String, dynamic>) {
      throw const ApiException(
        statusCode: 500,
        message: "Invalid user profile payload",
      );
    }

    return UserProfile.fromJson(payload);
  }

  Future<MemberCard> getMemberCard(String token) async {
    final response = await _apiClient.get("/user/member-card", token: token);
    final payload = response["memberCard"] ?? response["data"];

    if (payload is! Map<String, dynamic>) {
      throw const ApiException(
        statusCode: 500,
        message: "Invalid member card payload",
      );
    }

    return MemberCard.fromJson(payload);
  }
}
