import 'package:flutter/material.dart';

class UpdatesPage extends StatefulWidget {
  const UpdatesPage({super.key});

  @override
  State<UpdatesPage> createState() => _UpdatesPageState();
}

class _UpdatesPageState extends State<UpdatesPage> {
  int selectedTab = 0;

  final List<Map<String, dynamic>> newsList = [
    {
      "image": "https://images.pexels.com/photos/161251/south-india-temple-161251.jpeg",
      "title": "Temple Renovation Initiative",
      "description":
          "Community-led renovation of historic Konar temple in Madurai successfully completed with grand ceremony.",
      "date": "April 22, 2025",
    },
    {
      "image": "https://images.pexels.com/photos/3184338/pexels-photo-3184338.jpeg",
      "title": "Youth Wing Formation",
      "description":
          "Konar Yuva Shakti – Youth wing launched to empower and engage our young community members.",
      "date": "April 20, 2025",
    },
    {
      "image": "https://images.pexels.com/photos/274506/pexels-photo-274506.jpeg",
      "title": "Annual Sports Day 2025",
      "description": "Registration open for the Annual Sports Day.",
      "date": "April 18, 2025",
    },
  ];

  final List<Map<String, dynamic>> videoList = [
    {
      "image": "https://images.pexels.com/photos/3184339/pexels-photo-3184339.jpeg",
      "title": "Community Meeting – Madurai",
      "date": "April 18, 2025",
    },
    {
      "image": "https://images.pexels.com/photos/274506/pexels-photo-274506.jpeg",
      "title": "Annual Sports Day 2025",
      "date": "April 18, 2025",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isNews = selectedTab == 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Updates",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 10),

          // 🔘 TABS
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                _buildTab("News", 0),
                _buildTab("Videos", 1),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 🔹 LIST
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: isNews ? newsList.length : videoList.length,
              itemBuilder: (context, index) {
                final item = isNews ? newsList[index] : videoList[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🖼 IMAGE + PLAY (for videos)
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16)),
                            child: Image.network(
                              item["image"],
                              height: 170,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),

                          // ▶ PLAY BUTTON (ONLY VIDEO TAB)
                          if (!isNews)
                            Container(
                              width: 60,
                              height: 60,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow,
                                size: 32,
                                color: Color(0xFF1E2A78),
                              ),
                            ),
                        ],
                      ),

                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // TITLE
                            Text(
                              item["title"],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 6),

                            // DESCRIPTION (ONLY NEWS)
                            if (isNews)
                              Text(
                                item["description"],
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),

                            const SizedBox(height: 8),

                            // DATE
                            Text(
                              item["date"],
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 🔘 TAB WIDGET
  Widget _buildTab(String text, int index) {
    final isSelected = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1E2A78) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}