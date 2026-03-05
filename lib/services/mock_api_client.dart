import "../config/app_config.dart";
import "api_client.dart";

class MockApiClient extends ApiClient {
  static int _userIdCounter = 2;
  static int _memberCounter = 1001;

  static final Map<String, _MockUserRecord> _usersByMobile = _seedUsers();

  static final Map<String, String> _verificationTokenByMobile = {};
  static final Map<String, String> _mobileByAuthToken = {};

  static Map<String, _MockUserRecord> _seedUsers() {
    const fallbackMobile = "1234512345";
    final primaryMobile = AppConfig.effectiveDemoExistingMobile;

    final users = <String, _MockUserRecord>{
      primaryMobile: _buildSeedUser(primaryMobile),
    };

    if (primaryMobile != fallbackMobile) {
      users[fallbackMobile] = _buildSeedUser(fallbackMobile);
    }

    return users;
  }

  static _MockUserRecord _buildSeedUser(String mobile) {
    return _MockUserRecord(
      id: "mock-user-1",
      name: "Arun Kumar",
      mobile: mobile,
      dob: DateTime(1992, 5, 14),
      age: _calculateAge(DateTime(1992, 5, 14)),
      street: "Anna Salai",
      doorNumber: "12A",
      village: "Salem",
      taluk: "Salem",
      pincode: "636001",
      memberId: "KPP-2026-001000",
      createdAt: DateTime(2026, 1, 10),
    );
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final payload = body ?? <String, dynamic>{};

    switch (path) {
      case "/auth/check-user":
        final mobile = _readMobile(payload);
        return {"exists": _usersByMobile.containsKey(mobile)};
      case "/auth/send-otp":
        _readMobile(payload);
        return {
          "message": "OTP sent successfully",
          "expiresInSeconds": AppConfig.otpExpirySeconds,
          "debugOtp": AppConfig.demoOtp,
        };
      case "/auth/verify-otp":
        final mobile = _readMobile(payload);
        _validateOtp(payload["otp"]);

        final user = _usersByMobile[mobile];
        if (user != null) {
          final authToken = _issueAuthToken(mobile);
          return {
            "isNewUser": false,
            "message": "OTP verified successfully",
            "token": authToken,
            "user": user.toUserJson(),
          };
        }

        final verificationToken = _issueVerificationToken(mobile);
        return {
          "isNewUser": true,
          "message": "OTP verified. Continue registration.",
          "verificationToken": verificationToken,
        };
      case "/auth/register":
        return _handleRegister(payload);
      default:
        throw ApiException(
          statusCode: 404,
          message: "Mock endpoint not found: $path",
        );
    }
  }

  @override
  Future<Map<String, dynamic>> get(String path, {String? token}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    switch (path) {
      case "/user/profile":
        final user = _findUserByToken(token);
        return {"user": user.toUserJson()};
      case "/user/member-card":
        final user = _findUserByToken(token);
        return {"memberCard": user.toMemberCardJson()};
      default:
        throw ApiException(
          statusCode: 404,
          message: "Mock endpoint not found: $path",
        );
    }
  }

  Map<String, dynamic> _handleRegister(Map<String, dynamic> payload) {
    final mobile = _readMobile(payload);
    final verificationToken = _readText(
      payload["verification_token"] ?? payload["verificationToken"],
    );

    final expectedToken = _verificationTokenByMobile[mobile];
    if (expectedToken == null || verificationToken != expectedToken) {
      throw const ApiException(
        statusCode: 401,
        message: "OTP verification expired. Please verify OTP again.",
      );
    }

    if (_usersByMobile.containsKey(mobile)) {
      throw const ApiException(
        statusCode: 409,
        message: "User already exists. Please login with OTP.",
      );
    }

    final name = _readText(payload["name"]);
    final dobText = _readText(payload["dob"]);
    final dob = DateTime.tryParse(dobText);
    if (dob == null) {
      throw const ApiException(statusCode: 400, message: "Invalid date of birth");
    }

    final age = _calculateAge(dob);
    if (age < 18) {
      throw const ApiException(
        statusCode: 400,
        message: "Member must be at least 18 years old",
      );
    }

    final now = DateTime.now();
    final memberId =
        "KPP-${now.year}-${_memberCounter.toString().padLeft(6, "0")}";
    _memberCounter += 1;

    final user = _MockUserRecord(
      id: "mock-user-$_userIdCounter",
      name: name,
      mobile: mobile,
      dob: dob,
      age: age,
      street: _readText(payload["street"]),
      doorNumber: _readText(payload["door_number"] ?? payload["doorNumber"]),
      village: _readText(payload["village"]),
      taluk: _readText(payload["taluk"]),
      pincode: _readText(payload["pincode"]),
      memberId: memberId,
      createdAt: now,
    );
    _userIdCounter += 1;

    _usersByMobile[mobile] = user;
    _verificationTokenByMobile.remove(mobile);

    final authToken = _issueAuthToken(mobile);
    return {
      "message": "Registration successful",
      "token": authToken,
      "user": user.toUserJson(),
    };
  }

  _MockUserRecord _findUserByToken(String? token) {
    final authToken = _readText(token);
    final mobile = _mobileByAuthToken[authToken];

    if (mobile == null) {
      throw const ApiException(
        statusCode: 401,
        message: "Session expired. Please login again.",
      );
    }

    final user = _usersByMobile[mobile];
    if (user == null) {
      throw const ApiException(statusCode: 404, message: "User not found");
    }

    return user;
  }

  static int _calculateAge(DateTime dob) {
    final today = DateTime.now();
    var age = today.year - dob.year;
    final beforeBirthday =
        today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day);
    if (beforeBirthday) {
      age -= 1;
    }
    return age;
  }

  String _readMobile(Map<String, dynamic> payload) {
    final mobileInput = _readText(payload["mobile"]);
    final normalizedMobile = _normalizeMobile(mobileInput);
    if (normalizedMobile == null) {
      throw const ApiException(
        statusCode: 400,
        message: "Enter a valid 10-digit mobile number",
      );
    }
    return normalizedMobile;
  }

  String? _normalizeMobile(String value) {
    final digitsOnly = value.replaceAll(RegExp(r"\D"), "");

    if (digitsOnly.length == 10) {
      return digitsOnly;
    }

    if (digitsOnly.length == 11 && digitsOnly.startsWith("0")) {
      return digitsOnly.substring(1);
    }

    if (digitsOnly.length == 12 && digitsOnly.startsWith("91")) {
      return digitsOnly.substring(2);
    }

    return null;
  }

  void _validateOtp(dynamic value) {
    final otp = _readText(value);
    if (!RegExp(r"^\d{6}$").hasMatch(otp)) {
      throw const ApiException(
        statusCode: 400,
        message: "Enter a valid 6-digit OTP",
      );
    }

    if (otp != AppConfig.demoOtp) {
      throw ApiException(
        statusCode: 400,
        message: "Invalid OTP. Use demo OTP ${AppConfig.demoOtp}",
      );
    }
  }

  String _issueVerificationToken(String mobile) {
    final token = "mock-verify-$mobile-${DateTime.now().millisecondsSinceEpoch}";
    _verificationTokenByMobile[mobile] = token;
    return token;
  }

  String _issueAuthToken(String mobile) {
    final token = "mock-auth-$mobile-${DateTime.now().millisecondsSinceEpoch}";
    _mobileByAuthToken[token] = mobile;
    return token;
  }

  String _readText(dynamic value) {
    final text = (value ?? "").toString().trim();
    if (text.isEmpty) {
      throw const ApiException(statusCode: 400, message: "Required field is missing");
    }
    return text;
  }
}

class _MockUserRecord {
  final String id;
  final String name;
  final String mobile;
  final DateTime dob;
  final int age;
  final String street;
  final String doorNumber;
  final String village;
  final String taluk;
  final String pincode;
  final String memberId;
  final DateTime createdAt;

  const _MockUserRecord({
    required this.id,
    required this.name,
    required this.mobile,
    required this.dob,
    required this.age,
    required this.street,
    required this.doorNumber,
    required this.village,
    required this.taluk,
    required this.pincode,
    required this.memberId,
    required this.createdAt,
  });

  String get address => "$doorNumber, $street, $village, $taluk - $pincode";

  Map<String, dynamic> toUserJson() {
    return {
      "id": id,
      "name": name,
      "mobile": mobile,
      "dob": dob.toIso8601String(),
      "age": age,
      "street": street,
      "doorNumber": doorNumber,
      "village": village,
      "taluk": taluk,
      "pincode": pincode,
      "memberId": memberId,
      "createdAt": createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toMemberCardJson() {
    return {
      "partyName": AppConfig.partyName,
      "memberName": name,
      "memberId": memberId,
      "mobileNumber": mobile,
      "address": address,
      "dob": dob.toIso8601String(),
      "age": age,
      "memberQrPayload": "$memberId|$mobile|$name",
      "profileImageUrl": null,
    };
  }
}
