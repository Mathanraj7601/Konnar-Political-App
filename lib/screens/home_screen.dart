import 'package:flutter/material.dart';
import 'member_card_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // The different tabs for the home screen
  final List<Widget> _tabs = [
    const _HomeDashboardTab(), // New Dedicated Home Tab
    const MemberCardScreen(), // Reusing your existing Profile/Card Screen
    const _VideoFeedTab(title: "நிகழ்வுகள்"),
    const _VideoFeedTab(title: "பிரபலம்"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF1223B3), // Blue Theme Color
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 10,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'முகப்பு',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'என் விவரம்',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_outline),
            activeIcon: Icon(Icons.play_circle_filled),
            label: 'நிகழ்வுகள்',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'பிரபலம்',
          ),
        ],
      ),
    );
  }
}

/// A dedicated Home Dashboard screen with news and updates
class _HomeDashboardTab extends StatelessWidget {
  const _HomeDashboardTab();

  // A list of dummy news data to populate the feed
  final List<Map<String, dynamic>> _newsItems = const [
    {
      "title": "இந்த வார இறுதியில் மாபெரும் பொதுக்கூட்டம்",
      "summary": "இந்த ஆண்டின் மிகப்பெரிய பொதுக்கூட்டத்தில் பங்கேற்க மதுரையில் இணைவோம். அனைத்து உறுப்பினர்களும் கலந்துகொள்ள கேட்டுக்கொள்ளப்படுகிறார்கள்.",
      "date": "2 மணிநேரத்திற்கு முன்",
      "icon": Icons.campaign,
    },
    {
      "title": "இளைஞர்களிடையே கட்சித் தலைவர் உரை",
      "summary": "நவீன அரசியலில் இளைஞர்களின் பங்களிப்பின் முக்கியத்துவத்தை கட்சித் தலைவர் தனது சிறப்புரையில் வலியுறுத்தினார்.",
      "date": "1 நாளுக்கு முன்",
      "icon": Icons.groups,
    },
    {
      "title": "புதிய நலத்திட்டம் அறிவிப்பு",
      "summary": "விவசாயிகள் மற்றும் விவசாயத் தொழிலாளர்களை ஆதரிக்கும் நோக்கில் புதிய நலத்திட்டத்தை நமது உள்ளூர் தலைவர்கள் முன்மொழிந்துள்ளனர்.",
      "date": "3 நாட்களுக்கு முன்",
      "icon": Icons.handshake,
    },
    {
      "title": "மாபெரும் இரத்த தான முகாம்",
      "summary": "இளைஞர் அணியினரால் மாநிலம் முழுவதும் நடத்தப்பட்ட முகாமில் 5,000-க்கும் மேற்பட்ட யூனிட் இரத்தம் சேகரிக்கப்பட்டது.",
      "date": "1 வாரத்திற்கு முன்",
      "icon": Icons.bloodtype,
    },
    {
      "title": "தேர்தல் அறிக்கை வெளியீடு",
      "summary": "வரவிருக்கும் மாநிலத் தேர்தல்களுக்கான நமது முக்கிய வாக்குறுதிகள் மற்றும் வளர்ச்சி இலக்குகளைக் கோடிட்டுக் காட்டும் முழுமையான அதிகாரப்பூர்வ தேர்தல் அறிக்கையைப் படியுங்கள்.",
      "date": "2 வாரங்களுக்கு முன்",
      "icon": Icons.article,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "முகப்பு",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      backgroundColor: Colors.grey.shade100,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1223B3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("வரவேற்கிறோம்!", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text("கட்சியின் சமீபத்திய செய்திகள் மற்றும் உள்ளூர் நிகழ்வுகளுடன் இணைந்திருங்கள்.", style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text("கட்சி செய்திகள் மற்றும் அறிவிப்புகள்", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 12),
          // Generate news cards dynamically
          ..._newsItems.map((news) => Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    // TODO: Navigate to full news article
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: const Color(0xFF1223B3).withValues(alpha: 0.1),
                              child: Icon(news["icon"] as IconData, color: const Color(0xFF1223B3)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                news["title"] as String,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          news["summary"] as String,
                          style: TextStyle(color: Colors.grey.shade700, height: 1.4),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              news["date"] as String,
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                            const Text(
                              "மேலும் படிக்க",
                              style: TextStyle(color: Color(0xFF1223B3), fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

/// A dummy placeholder widget that looks like a YouTube feed for Events/Trending
class _VideoFeedTab extends StatelessWidget {
  final String title;
  
  const _VideoFeedTab({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      backgroundColor: Colors.grey.shade100,
      body: ListView.builder(
        itemCount: 5, // Show 5 dummy videos
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Video Thumbnail Placeholder
                Container(
                  height: 220,
                  width: double.infinity,
                  color: Colors.grey.shade300,
                  child: Center(
                    child: Icon(Icons.play_circle_fill, size: 60, color: Colors.black.withValues(alpha: 0.5)),
                  ),
                ),
                // Video Details
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF1223B3),
                    child: const Icon(Icons.flag, color: Colors.white),
                  ),
                title: Text("$title: அதிகாரப்பூர்வ வீடியோ ${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("ஆயர் புரட்சி கழக ஊடகம் • ${index + 2}K பார்வைகள் • 2 நாட்களுக்கு முன்"),
                  trailing: const Icon(Icons.more_vert),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}