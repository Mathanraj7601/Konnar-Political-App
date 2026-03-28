import 'package:flutter/material.dart';
import '../services/navigation_service.dart';
import 'video_player_page.dart';

class UpdatesPage extends StatefulWidget {
  const UpdatesPage({super.key});

  @override
  State<UpdatesPage> createState() => _UpdatesPageState();
}

class _UpdatesPageState extends State<UpdatesPage> {
  int selectedTab = 0;

  // 🔹 NEWS DATA (EXTENDED)
  final List<Map<String, dynamic>> newsList = [
    {
      "image": "https://images.pexels.com/photos/161251/south-india-temple-161251.jpeg",
      "title": "Temple Renovation Initiative",
      "description":
          "Community-led renovation of historic Konar temple in Madurai successfully completed.",
      "date": "April 22, 2025",
    },
    {
      "image": "https://images.pexels.com/photos/3184338/pexels-photo-3184338.jpeg",
      "title": "Youth Wing Formation",
      "description":
          "Youth wing launched to empower and engage community youth members.",
      "date": "April 20, 2025",
    },
    {
      "image": "https://images.pexels.com/photos/6646918/pexels-photo-6646918.jpeg",
      "title": "Free Medical Camp",
      "description":
          "A free health check-up camp was conducted with specialist doctors.",
      "date": "April 18, 2025",
    },
    {
      "image": "https://images.pexels.com/photos/1181406/pexels-photo-1181406.jpeg",
      "title": "Scholarship Distribution",
      "description":
          "Scholarships distributed to deserving students for higher education.",
      "date": "April 15, 2025",
    },
    {
      "image": "https://images.pexels.com/photos/3184465/pexels-photo-3184465.jpeg",
      "title": "Women Empowerment Program",
      "description":
          "Workshops conducted to support women entrepreneurship and growth.",
      "date": "April 12, 2025",
    },
    {
      "image": "https://images.pexels.com/photos/3184357/pexels-photo-3184357.jpeg",
      "title": "Cleanliness Drive",
      "description":
          "Community volunteers participated in a city-wide cleanliness drive.",
      "date": "April 10, 2025",
    },
    {
      "image": "https://images.pexels.com/photos/3755755/pexels-photo-3755755.jpeg",
      "title": "Health Awareness Campaign",
      "description":
          "Awareness sessions conducted on preventive healthcare practices.",
      "date": "April 08, 2025",
    },
  ];

  // 🔹 VIDEO DATA (EXTENDED)
  final List<Map<String, dynamic>> videoList = [
    {
      "image": "https://images.pexels.com/photos/3184339/pexels-photo-3184339.jpeg",
      "title": "Community Meeting – Madurai",
      "video": "https://samplelib.com/lib/preview/mp4/sample-5s.mp4",
      "date": "April 18, 2025",
    },
    {
      "image": "https://images.pexels.com/photos/274506/pexels-photo-274506.jpeg",
      "title": "Annual Sports Day 2025",
      "video": "https://samplelib.com/lib/preview/mp4/sample-10s.mp4",
      "date": "April 18, 2025",
    },
    {
      "image": "https://images.pexels.com/photos/1181671/pexels-photo-1181671.jpeg",
      "title": "Temple Festival Highlights",
      "video": "https://samplelib.com/lib/preview/mp4/sample-15s.mp4",
      "date": "April 15, 2025",
    },
    {
      "image": "https://images.pexels.com/photos/3184292/pexels-photo-3184292.jpeg",
      "title": "Youth Leadership Program",
      "video": "https://samplelib.com/lib/preview/mp4/sample-20s.mp4",
      "date": "April 12, 2025",
    },
    {
      "image": "https://images.pexels.com/photos/3184306/pexels-photo-3184306.jpeg",
      "title": "Community Workshop",
      "video": "https://samplelib.com/lib/preview/mp4/sample-30s.mp4",
      "date": "April 10, 2025",
    },
    {
      "image": "https://images.pexels.com/photos/3755755/pexels-photo-3755755.jpeg",
      "title": "Health Awareness Campaign",
      "video": "https://samplelib.com/lib/preview/mp4/sample-5mb.mp4",
      "date": "April 08, 2025",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isNews = selectedTab == 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      // 🔹 APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => NavigationService().goBackToHome(),
        ),
        title: const Text(
          "Updates",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
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

                return GestureDetector(
                  onTap: () {
                    if (!isNews) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VideoPlayerPage(
                            videoUrl: item["video"],
                            title: item["title"],
                          ),
                        ),
                      );
                    }
                  },
                  child: Container(
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

                        // 🖼 IMAGE
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

                                // ✅ FIX: LOADING
                                loadingBuilder:
                                    (context, child, progress) {
                                  if (progress == null) return child;
                                  return Container(
                                    height: 170,
                                    alignment: Alignment.center,
                                    child:
                                        const CircularProgressIndicator(),
                                  );
                                },

                                // ✅ FIX: ERROR
                                errorBuilder:
                                    (context, error, stackTrace) {
                                  return Container(
                                    height: 170,
                                    color: Colors.grey.shade300,
                                    alignment: Alignment.center,
                                    child: const Icon(Icons.image,
                                        size: 40),
                                  );
                                },
                              ),
                            ),

                            // ▶ PLAY ICON
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

                        // 📄 CONTENT
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                item["title"],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 6),

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
            color: isSelected
                ? const Color(0xFF1E2A78)
                : Colors.transparent,
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