import 'package:flutter/material.dart';

class HomeDashboardModule extends StatelessWidget {
  const HomeDashboardModule({super.key});

  static const _profileName = 'Arjun Kumar';
  static const _profileDistrict = 'Chennai District';
  static const _memberId = 'TRN4234466';

  static const _actions = [
    _ActionItem(label: 'View Card', icon: Icons.credit_card, color: Color(0xFF1E2A78)),
    _ActionItem(label: 'Announcements', icon: Icons.groups, color: Color(0xFF1E2A78)),
    _ActionItem(label: 'Updates', icon: Icons.arrow_forward_ios, color: Color(0xFFF6A800)),
    _ActionItem(label: 'Events', icon: Icons.diamond, color: Color(0xFFCB2C2C)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 🔵 HEADER + PROFILE
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1E2A78), Color(0xFF2F3FA0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Vanakkam, Arjun 👋',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Member ID: TRN4234466',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    bottom: -90,
                    left: 16,
                    right: 16,
                    child: _buildProfileCard(),
                  ),
                ],
              ),

              const SizedBox(height: 110),

              // ⚪ CONTENT
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildActionGrid(context),
                    const SizedBox(height: 24),
                    _buildAnnouncementsSection(),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // 🧑 PROFILE CARD
  static Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              const CircleAvatar(
                radius: 45,
                backgroundImage: NetworkImage(
                  'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg',
                ),
              ),
              Positioned(
                bottom: 0,
                right: -2,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(Icons.star, size: 14, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            _profileName,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            _profileDistrict,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // 🔲 ACTION GRID (UPDATED)
  Widget _buildActionGrid(BuildContext context) {
    return GridView.builder(
      itemCount: _actions.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.4,
      ),
      itemBuilder: (context, index) {
        final action = _actions[index];

        return GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${action.label} tapped')),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🔷 ICON BOX (Figma Style)
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: action.color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    action.icon,
                    size: 22,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  action.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 📢 ANNOUNCEMENTS (UPDATED)
  Widget _buildAnnouncementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Announcements',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Meeting Reminder',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Community meeting this Sunday at 5 PM. Don\'t miss it!',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF1E2A78),
                  ),
                  child: const Text('Read More >'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionItem {
  final String label;
  final IconData icon;
  final Color color;

  const _ActionItem({
    required this.label,
    required this.icon,
    required this.color,
  });
}