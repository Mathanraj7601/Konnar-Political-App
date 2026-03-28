import 'package:flutter/material.dart';
import 'edit_profile_page.dart';
import 'my_details_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
          "Profile",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // 👤 PROFILE IMAGE
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                    "https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg",
                  ),
                ),

                // 🟢 EDIT ICON
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit,
                    size: 14,
                    color: Colors.white,
                  ),
                )
              ],
            ),

            const SizedBox(height: 12),

            // NAME
            const Text(
              "Arjun Kumar",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            // PHONE
            const Text(
              "9876543210",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 24),

            // 📋 MENU LIST
            _buildMenuItem(
              icon: Icons.edit,
              title: "Edit Profile",
              showArrow: false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditProfilePage()),
                );
              },
            ),

            _buildMenuItem(
              icon: Icons.badge,
              title: "My Details",
              showArrow: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyDetailsPage()),
                );
              },
            ),

            _buildMenuItem(
              icon: Icons.credit_card,
              title: "View Member Card",
              showArrow: true,
            ),

            _buildMenuItem(
              icon: Icons.logout,
              title: "Logout",
              iconColor: Colors.red,
              showArrow: true,
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 MENU ITEM
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    bool showArrow = true,
    Color iconColor = const Color(0xFF1E2A78),
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
        child: Row(
          children: [
            Icon(icon, color: iconColor),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            if (showArrow)
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
          ],
        ),
      ),
    );
  }
}