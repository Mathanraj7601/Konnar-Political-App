import 'package:flutter/material.dart';

class AnnouncementsPage extends StatelessWidget {
  const AnnouncementsPage({super.key});

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
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      // 🔹 APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Announcements',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
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
                        item['description'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // READ MORE
                      const Text(
                        "Read More >",
                        style: TextStyle(
                          color: Color(0xFF1E2A78),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
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