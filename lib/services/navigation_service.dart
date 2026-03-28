import 'package:flutter/material.dart';
import '../screens/home_screen.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  // Store the home screen state reference
  HomeScreenState? homeScreenState;

  void goBackToHome() {
    homeScreenState?.goBackToPreviousTab();
  }
}
