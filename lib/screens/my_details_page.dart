import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Color(0xFFF4F6FB),
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyDetailsPage(),
    );
  }
}

class MyDetailsPage extends StatelessWidget {
  const MyDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Make status bar transparent for full blue header coverage
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFFF4F6FB),
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),

      // ✅ FIX: SCROLLABLE LAYOUT
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // 🔷 BLUE HEADER CARD - FULL WIDTH
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16, // Status bar height
                left: 16,
                right: 16,
                bottom: 20,
              ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E2A78), Color(0xFF2F3FA0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // BACK BUTTON AND TITLE
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "My Details",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // PROFILE INFO
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 35,
                          backgroundImage: NetworkImage(
                            "https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg",
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Arjun Kumar",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "+91 9876543210",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // WHITE CONTENT AREA
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF4F6FB),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    
                    _profileCard(),

                    const SizedBox(height: 16),

                    _baseCard(
                      children: [
                        _row(Icons.person, "Full Name", "Arjun Kumar"),
                        _divider(),
                        _row(Icons.phone, "Mobile Number", "9876543210"),
                        _divider(),
                        _row(Icons.calendar_today, "Date of Birth", "15 Mar 2001"),
                        _divider(),
                        _row(Icons.people, "Gender", "Male"),
                        _divider(),
                        _row(Icons.person_outline, "Father / Guardian Name", "R. Sekar"),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _baseCard(
                      children: [
                        _sectionTitle(Icons.location_on, "Address"),
                        _divider(),
                        _row(Icons.location_on, "Street", "New Street, Chennai"),
                        _divider(),
                        _row(Icons.home, "Door No", "123"),
                        _divider(),
                        _row(Icons.location_city, "City / Village", "Kanchipuram"),
                        _divider(),
                        _row(Icons.map, "District", "Menai"),
                        _divider(),
                        _row(Icons.place, "Constituency", "Kanchipuram"),
                      ],
                    ),

                    const SizedBox(height: 20),

                    _button(),

                    const SizedBox(height: 20), // bottom safe spacing
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  }

  Widget _profileCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _card(),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(
              "https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg",
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("Arjun Kumar",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              SizedBox(height: 4),
              Text("+91 9876543210",
                  style: TextStyle(color: Colors.grey)),
            ],
          )
        ],
      ),
    );
  }

  Widget _baseCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: _card(),
      child: Column(children: children),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F5FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF1E2A78), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Divider(color: Colors.grey.shade200),
    );
  }

  Widget _sectionTitle(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange),
          const SizedBox(width: 8),
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _button() {
    return Container(
      height: 55,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E2A78), Color(0xFF2F3FA0)],
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      alignment: Alignment.center,
      child: const Text(
        "Edit Profile",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }

  BoxDecoration _card() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}