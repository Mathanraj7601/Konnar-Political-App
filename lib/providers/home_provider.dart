import 'package:flutter/material.dart';
import '../models/announcement.dart';
import '../models/update_event.dart';

class HomeProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  
  List<Announcement> _announcements = [];
  List<UpdateEvent> _updates = [];
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Announcement> get announcements => _announcements;
  List<UpdateEvent> get updates => _updates;

  // Replace mock code with real API calls using your ApiClient
  Future<void> fetchHomeData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // final response = await apiClient.get('/api/home');
      
      _announcements = [
        Announcement(id: '1', title: 'Meeting Reminder', description: 'Community meeting this Sunday at 5 PM.', date: DateTime.now()),
        Announcement(id: '2', title: 'Health Camp', description: 'Free medical checkup camp organized at community hall.', date: DateTime.now().subtract(const Duration(days: 2))),
      ];
      
      _updates = [
        UpdateEvent(
          id: '1', 
          title: 'Community Event 2026', 
          description: 'Join us for an inspiring community event.', 
          date: DateTime.now(), 
          imageUrl: 'https://images.pexels.com/photos/3184339/pexels-photo-3184339.jpeg',
        ),
      ];
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}