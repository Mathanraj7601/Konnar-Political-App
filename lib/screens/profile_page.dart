import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'edit_profile_page.dart';
import 'my_details_page.dart';
import '../services/navigation_service.dart';
import 'login_screen.dart';

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
          "Profile",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        titleSpacing: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // � PROFILE IMAGE
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                    "https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg",
                  ),
                ),

                // � STAR ICON
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star,
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
                print("Edit Profile button clicked!");
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
              onTap: () {
                _showLogoutDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Logout"),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  // � MENU ITEM
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    bool showArrow = true,
    Color iconColor = const Color(0xFF1E2A78),
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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