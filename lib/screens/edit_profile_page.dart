import 'package:flutter/material.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // 🔷 HEADER CARD
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _headerCard(),
            ),

            const SizedBox(height: 20),

            // 🔥 BASE CARD (OUTER LAYER)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF1F7), // light grey base
                  borderRadius: BorderRadius.circular(30),
                ),

                // 🔲 INNER WHITE CARD
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Column(
                    children: [
                      _smallCard(Icons.phone, "Mobile Number", "9876543210"),

                      _smallCard(Icons.person, "Full Name", "Arjun Kumar",
                          isActive: true),

                      Row(
                        children: [
                          Expanded(
                            child: _smallCard(Icons.calendar_today,
                                "Date of Birth", "15 Mar 2001"),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: _ageCard()),
                        ],
                      ),

                      _smallCard(Icons.person, "Gender", "Male",
                          isDropdown: true),

                      _smallCard(Icons.bloodtype, "Blood Group", "O+",
                          isDropdown: true),

                      const SizedBox(height: 10),

                      _buttonCard(),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 🔷 HEADER CARD
  Widget _headerCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E2A78), Color(0xFF2F3FA0)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFDB913).withOpacity(0.7),
                      blurRadius: 25,
                      spreadRadius: 4,
                    )
                  ],
                ),
                child: const CircleAvatar(
                  radius: 45,
                  backgroundImage: NetworkImage(
                    "https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg",
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt, size: 16),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _headerBtn(Icons.camera_alt, "Take Photo"),
              const SizedBox(width: 12),
              _headerBtn(Icons.image, "Gallery"),
            ],
          ),
        ],
      ),
    );
  }

  // 🔲 SMALL CARD
  Widget _smallCard(IconData icon, String label, String value,
      {bool isActive = false, bool isDropdown = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FC),
          borderRadius: BorderRadius.circular(18),
          border: isActive
              ? Border.all(color: const Color(0xFFFDB913), width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF1E2A78)),
            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 2),
                  Text(value,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Color(0xFF1E2A78),
                      )),
                ],
              ),
            ),

            if (isDropdown)
              const Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }

  // 🔢 AGE CARD
  Widget _ageCard() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(18),
      ),
      alignment: Alignment.center,
      child: const Text(
        "25",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E2A78),
        ),
      ),
    );
  }

  // 🔘 BUTTON CARD
  Widget _buttonCard() {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFDB913), Color(0xFFF59E0B)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 10,
          )
        ],
      ),
      alignment: Alignment.center,
      child: const Text(
        "Update Profile",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  // 🔘 HEADER BUTTON
  Widget _headerBtn(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}