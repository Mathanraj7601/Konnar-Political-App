import 'package:flutter/material.dart';

class HomeDashboardModule extends StatefulWidget {
  final String profileName;
  final String profileDistrict;
  final Function(int)? onNavigate;
  final Function()? onBack;

  const HomeDashboardModule({
    super.key,
    required this.profileName,
    required this.profileDistrict,
    this.onNavigate,
    this.onBack,
  });

  @override
  State<HomeDashboardModule> createState() => _HomeDashboardModuleState();
}

class _HomeDashboardModuleState extends State<HomeDashboardModule> {
  bool isExpanded = false;

  static final List<_ActionItem> _actions = [
    _ActionItem(
      label: 'View Card',
      icon: Icons.credit_card,
      color: Color(0xFF1E2A78),
    ),
    _ActionItem(
      label: 'Announcement',
      icon: Icons.campaign,
      color: Color(0xFF1E2A78),
    ),
    _ActionItem(
      label: 'Updates & Events',
      icon: Icons.update,
      color: Color(0xFFF6A800),
    ),
    _ActionItem(
      label: 'Members',
      icon: Icons.groups,
      color: Color(0xFFCB2C2C),
      extra: '5000',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 🔵 HEADER + PROFILE
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 250,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1E2A78), Color(0xFF2F3FA0)],
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 65, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Vanakkam, Arjun Kumar 👋',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Member ID: A26#MDU0001',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ✅ FINAL PERFECT POSITION
                  Positioned(
                    bottom: -120,
                    left: 16,
                    right: 16,
                    child: _buildProfileCard(
                      widget.profileName,
                      widget.profileDistrict,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 140),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildActionGrid(),
                    const SizedBox(height: 24),
                    _buildAnnouncementsSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🧑 PROFILE CARD
  Widget _buildProfileCard(String name, String district) {
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
          Text(
            name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E2A78),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            district,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // 🔲 GRID
  Widget _buildActionGrid() {
    return GridView.builder(
      itemCount: _actions.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.25,
      ),
      itemBuilder: (context, index) {
        final action = _actions[index];

        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _handleNavigation(context, index),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: action.color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(action.icon, color: Colors.white, size: 22),
                ),
                const SizedBox(height: 10),
                Column(
                  children: [
                    Text(
                      action.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    if (action.extra != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        action.extra!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    // Use callback if provided, otherwise use default navigation
    if (widget.onNavigate != null) {
      widget.onNavigate!(index);
      return;
    }

    // Default navigation for pages that need Navigator.push
    switch (index) {
      case 3:
        // Members - Navigate to Members page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MembersPage()),
        );
        break;
      default:
        // View Card - Navigate to View Card page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ViewCardPage()),
        );
    }
  }

  // ANNOUNCEMENTS
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
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Meeting Reminder',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                isExpanded
                    ? 'Community meeting this Sunday at 5 PM. Please make sure to attend.'
                    : 'Community meeting this Sunday at 5 PM...',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                  child: Text(
                    isExpanded ? 'Show Less' : 'Read More >',
                    style: const TextStyle(
                      color: Color(0xFF1E2A78),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
  final String? extra;

  const _ActionItem({
    required this.label,
    required this.icon,
    required this.color,
    this.extra,
  });
}

// PAGES
class ViewCardPage extends StatelessWidget {
  const ViewCardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("View Card Page")));
  }
}

class MembersPage extends StatelessWidget {
  const MembersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Members Page")));
  }
}
