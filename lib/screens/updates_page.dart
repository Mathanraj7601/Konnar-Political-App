import 'package:flutter/material.dart';
import '../services/navigation_service.dart';
import 'video_player_page.dart';

class UpdatesPage extends StatefulWidget {
  const UpdatesPage({super.key});

  @override
  State<UpdatesPage> createState() => _UpdatesPageState();
}

class _UpdatesPageState extends State<UpdatesPage> {

  // 🔹 VIDEO DATA (LOCAL ASSETS)
  final List<Map<String, dynamic>> videoList = [
    {
      "image": "https://images.pexels.com/photos/3184339/pexels-photo-3184339.jpeg",
      "title": "Community Event 2026",
      "video": "assets/videos/IMG_2026.MOV",
      "date": "April 18, 2025",
    },
    {
      "image": "https://images.pexels.com/photos/274506/pexels-photo-274506.jpeg",
      "title": "Annual Sports Meet",
      "video": "assets/videos/IMG_2302.MOV",
      "date": "April 18, 2025",
    },
    {
      "image": "https://images.pexels.com/photos/1181671/pexels-photo-1181671.jpeg",
      "title": "Temple Festival Highlights",
      "video": "assets/videos/IMG_2777.MOV",
      "date": "April 15, 2025",
    },
    {
      "image": "https://images.pexels.com/photos/3184292/pexels-photo-3184292.jpeg",
      "title": "Youth Leadership Program",
      "video": "assets/videos/IMG_7235.MOV",
      "date": "April 12, 2025",
    },
    {
      "image": "https://images.pexels.com/photos/3184306/pexels-photo-3184306.jpeg",
      "title": "Community Workshop",
      "video": "assets/videos/IMG_7250.MOV",
      "date": "April 10, 2025",
    },
    {
      "image": "https://images.pexels.com/photos/3755755/pexels-photo-3755755.jpeg",
      "title": "Health Awareness Campaign",
      "video": "assets/videos/IMG_7264.MOV",
      "date": "April 08, 2025",
    },
    {
      "image": "https://images.pexels.com/photos/3184357/pexels-photo-3184357.jpeg",
      "title": "Special Event Coverage",
      "video": "assets/videos/InShot_20260401_084848350.mp4",
      "date": "April 01, 2025",
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
          onPressed: () => NavigationService().goBackToHome(),
        ),
        title: const Text(
          "Updates",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            const SizedBox(height: 16),

            // VIDEO LIST
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: videoList.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VideoPlayerPage(
                            videoList: videoList,
                            currentIndex: index,
                          ),
                        ),
                      );
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

                          // IMAGE
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

                              // PLAY ICON
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

                          // CONTENT
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
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}