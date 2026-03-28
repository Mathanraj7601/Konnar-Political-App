import 'package:flutter/material.dart';
import '../services/navigation_service.dart';

class AnnouncementsPage extends StatefulWidget {
  const AnnouncementsPage({super.key});

  @override
  State<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  // Track expanded state for each announcement
  final List<bool> _expandedStates = [];

  @override
  void initState() {
    super.initState();
    // Initialize all announcements as not expanded
    _expandedStates.addAll(List.filled(_announcements.length, false));
  }

  static const List<Map<String, dynamic>> _announcements = [
    {
      'date': 'APR 20, 2024',
      'title': 'Meeting Reminder',
      'description': 'Community meeting this Sunday at 5 PM. Don\'t miss it!',
    },
    {
      'date': 'APR 18, 2024',
      'title': 'New Event Planned',
      'description': 'We have planned a blood donation camp next Saturday. Volunteer if you can!',
    },
    {
      'date': 'APR 15, 2024',
      'title': 'Election Campaign Kickoff',
      'description': 'Join us for the election campaign kickoff this Friday. Let\'s work together!',
    },
    {
      'date': 'APR 10, 2024',
      'title': 'System Maintenance',
      'description': 'Scheduled maintenance this weekend. Services may be temporarily unavailable.',
    },

    // 🔥 NEW MOCK DATA BELOW

    {
      'date': 'APR 05, 2024',
      'title': 'Health Camp',
      'description': 'Free medical checkup camp organized at community hall from 9 AM to 2 PM.',
    },
    {
      'date': 'APR 01, 2024',
      'title': 'Membership Drive',
      'description': 'New membership registration drive has started. Invite your friends and family to join.',
    },
    {
      'date': 'MAR 28, 2024',
      'title': 'Volunteer Meeting',
      'description': 'All volunteers are requested to attend the meeting regarding upcoming events.',
    },
    {
      'date': 'MAR 25, 2024',
      'title': 'Training Session',
      'description': 'Leadership training session will be conducted this Saturday at 4 PM.',
    },
    {
      'date': 'MAR 20, 2024',
      'title': 'Community Cleanup',
      'description': 'Join us in cleaning the local park this Sunday morning. Let\'s keep our area clean.',
    },
    {
      'date': 'MAR 15, 2024',
      'title': 'Festival Celebration',
      'description': 'Celebrate the upcoming festival with us. Food, music, and fun activities included!',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      // 🔹 APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) {
            final screenWidth = MediaQuery.of(context).size.width;
            final isSmallScreen = screenWidth < 360;
            final isTablet = screenWidth >= 768;
            
            return IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black87,
                size: isTablet ? 26 : (isSmallScreen ? 20 : 24),
              ),
              onPressed: () {
                // Use navigation service to go back to home tab
                NavigationService().goBackToHome();
              },
              padding: EdgeInsets.all(isTablet ? 16 : 12),
              constraints: BoxConstraints(
                minWidth: isTablet ? 56 : 48,
                minHeight: isTablet ? 56 : 48,
              ),
            );
          },
        ),
        title: const Text(
          'Announcements',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        titleSpacing: 0,
      ),

      // 🔹 BODY
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _announcements.length,
        itemBuilder: (context, index) {
          final item = _announcements[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),

            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔸 LEFT CONTENT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // DATE
                      Text(
                        item['date'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // TITLE
                      Text(
                        item['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // DESCRIPTION
                      Text(
                        _expandedStates[index]
                            ? item['description']
                            : '${item['description'].substring(0, item['description'].length > 50 ? 50 : item['description'].length)}${item['description'].length > 50 ? '...' : ''}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // READ MORE / SHOW LESS
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _expandedStates[index] = !_expandedStates[index];
                            });
                          },
                          child: Text(
                            _expandedStates[index] ? 'Show Less' : 'Read More >',
                            style: const TextStyle(
                              color: Color(0xFF1E2A78),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 🔸 RIGHT CHEVRON
                const Padding(
                  padding: EdgeInsets.only(left: 8, top: 4),
                  child: Icon(
                    Icons.chevron_right,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}