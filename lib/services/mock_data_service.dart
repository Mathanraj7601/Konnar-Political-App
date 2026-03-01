import 'dart:async';
import '../models/citizen.dart';

class MockDataService {
  static List<Citizen> _registeredCitizens = [];
  static Map<String, String> _userCredentials = {
    '9876543210': 'password123', // mobile: password
    '9988776655': 'mypassword',
  };

  // Check if user exists
  static Future<bool> checkUserExists(String mobileNumber) async {
    await Future.delayed(Duration(milliseconds: 500)); // Simulate network delay
    return _userCredentials.containsKey(mobileNumber);
  }

  // Validate login
  static Future<bool> validateLogin(
    String mobileNumber,
    String password,
  ) async {
    await Future.delayed(Duration(milliseconds: 800)); // Simulate network delay
    return _userCredentials[mobileNumber] == password;
  }

  // Register new user
  static Future<bool> registerUser(String mobileNumber, String password) async {
    await Future.delayed(Duration(seconds: 1)); // Simulate network delay
    if (!_userCredentials.containsKey(mobileNumber)) {
      _userCredentials[mobileNumber] = password;
      return true;
    }
    return false;
  }

  // Save citizen registration
  static Future<bool> saveCitizenRegistration(Citizen citizen) async {
    await Future.delayed(Duration(seconds: 2)); // Simulate network delay
    _registeredCitizens.add(citizen);
    return true;
  }

  // Get all registered citizens (for admin)
  static Future<List<Citizen>> getAllCitizens() async {
    await Future.delayed(Duration(milliseconds: 500)); // Simulate network delay
    return _registeredCitizens;
  }

  // Get citizen by mobile number
  static Future<Citizen?> getCitizenByMobile(String mobileNumber) async {
    await Future.delayed(Duration(milliseconds: 300)); // Simulate network delay
    try {
      return _registeredCitizens.firstWhere(
        (citizen) => citizen.mobileNumber == mobileNumber,
      );
    } catch (e) {
      return null;
    }
  }

  // Get registration count
  static int getRegistrationCount() {
    return _registeredCitizens.length;
  }
}
