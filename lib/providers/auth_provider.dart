import "package:flutter/material.dart";

import "../models/member_card.dart";
import "../models/register_response.dart";
import "../models/registration_request.dart";
import "../models/send_otp_response.dart";
import "../models/user_profile.dart";
import "../models/verify_otp_response.dart";
import "../services/api_client.dart";
import "../services/auth_service.dart";
import "../services/local_storage_service.dart";
import "../services/user_service.dart";

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final UserService _userService;
  final LocalStorageService _localStorageService;

  AuthProvider({
    required AuthService authService,
    required UserService userService,
    required LocalStorageService localStorageService,
  }) : _authService = authService,
       _userService = userService,
       _localStorageService = localStorageService;

  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;
  String? _authToken;
  String? _registrationVerificationToken;
  String? _pendingMobile;
  String? _debugOtp;
  String? _profileImagePath;
  UserProfile? _currentUser;
  MemberCard? _memberCard;

  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get isAuthenticated => _authToken != null && _authToken!.isNotEmpty;
  String? get errorMessage => _errorMessage;
  String? get authToken => _authToken;
  String? get registrationVerificationToken => _registrationVerificationToken;
  String? get pendingMobile => _pendingMobile;
  String? get debugOtp => _debugOtp;
  String? get profileImagePath => _profileImagePath;
  UserProfile? get currentUser => _currentUser;
  MemberCard? get memberCard => _memberCard;

  Future<void> initializeSession() async {
    if (_isInitialized) {
      return;
    }

    _setLoading(true);

    try {
      final savedToken = await _localStorageService.getAuthToken();

      if (savedToken != null && savedToken.isNotEmpty) {
        _authToken = savedToken;

        try {
          _currentUser = await _userService.getProfile(savedToken);
          _memberCard = await _userService.getMemberCard(savedToken);
        } catch (_) {
          await _localStorageService.clearAuthToken();
          _authToken = null;
        }
      }
    } finally {
      _isInitialized = true;
      _setLoading(false);
    }
  }

  Future<bool?> checkUserExists(String mobile) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      return await _authService.checkUserExists(mobile);
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return null;
    } catch (_) {
      _errorMessage = "Unable to validate mobile number. Please try again.";
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> registerUser({
    required String name,
    required String email,
    required String mobile,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final userExists = await _authService.checkUserExists(mobile);

      if (userExists) {
        _errorMessage = "User already exists. Please login with OTP.";
        return false;
      }

      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = "Registration failed. Please try again.";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> sendOtp(String mobile) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final SendOtpResponse response = await _authService.sendOtp(mobile);
      _pendingMobile = mobile;
      _debugOtp = response.debugOtp;
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = "Unable to send OTP. Please try again.";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<VerifyOtpResponse?> verifyOtp({
    required String mobile,
    required String otp,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await _authService.verifyOtp(mobile: mobile, otp: otp);

      if (response.isNewUser) {
        _registrationVerificationToken = response.verificationToken;
        _pendingMobile = mobile;
      } else {
        _authToken = response.token;
        _registrationVerificationToken = null;
        _pendingMobile = null;
        _profileImagePath = null;

        if (_authToken != null && _authToken!.isNotEmpty) {
          await _localStorageService.saveAuthToken(_authToken!);
          _currentUser =
              response.user ?? await _userService.getProfile(_authToken!);
          _memberCard = await _userService.getMemberCard(_authToken!);
        }
      }

      _debugOtp = null;
      return response;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return null;
    } catch (_) {
      _errorMessage = "OTP verification failed. Please try again.";
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> registerMember(RegistrationRequest request) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final RegisterResponse response = await _authService.register(request);
      _authToken = response.token;
      _currentUser = response.user;
      _registrationVerificationToken = null;
      _pendingMobile = null;
      await _localStorageService.saveAuthToken(response.token);
      _memberCard = await _userService.getMemberCard(response.token);
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = "Registration failed. Please try again.";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchMemberCard() async {
    if (!isAuthenticated) {
      return;
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      _currentUser = await _userService.getProfile(_authToken!);
      _memberCard = await _userService.getMemberCard(_authToken!);
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    if (!isAuthenticated) return false;

    _setLoading(true);
    _errorMessage = null;

    try {
      // Assuming _userService.updateProfile exists. You will need to implement it in UserService.
      // final updatedUser = await _userService.updateProfile(_authToken!, data);
      // _currentUser = updatedUser;
      await fetchMemberCard(); // Refresh local data after update
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = "Failed to update profile. Please try again.";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _authToken = null;
    _registrationVerificationToken = null;
    _pendingMobile = null;
    _debugOtp = null;
    _profileImagePath = null;
    _currentUser = null;
    _memberCard = null;
    _errorMessage = null;
    await _localStorageService.clearAuthToken();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void setProfileImagePath(String? imagePath) {
    _profileImagePath = imagePath;
    notifyListeners();
  }

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }

    _isLoading = value;
    notifyListeners();
  }
}
