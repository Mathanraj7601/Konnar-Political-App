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

            // 🔷 HEADER
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1E2A78), Color(0xFF2F3FA0)],
                    ),
                  ),
                ),

                // 🧑 PROFILE IMAGE (NO WHITE BORDER)
                Positioned(
                  top: 50,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      // 🔥 OUTER GLOW
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFC107)
                                  .withOpacity(0.6),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(5), // ring thickness
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFFE082),
                                Color(0xFFF9A825),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const CircleAvatar(
                            radius: 48,
                            backgroundImage: NetworkImage(
                              "https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg",
                            ),
                          ),
                        ),
                      ),

                      // 📷 CAMERA ICON
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFF3E0),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: Color(0xFF1E2A78),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 🔘 BUTTONS
                Positioned(
                  bottom: -25,
                  left: 40,
                  right: 40,
                  child: Row(
                    children: [
                      Expanded(
                        child: _headerBtn(Icons.camera_alt, "Take Photo"),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _headerBtn(Icons.image, "Gallery"),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 50),

            // 🔥 FORM CARD
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ✅ MOBILE NUMBER (FIGMA STYLE)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Mobile Number",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 50,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Color(0xFFE5E7EB),
                            ),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.phone,
                                  size: 20,
                                  color: Color(0xFF1E2A78)),
                              SizedBox(width: 10),
                              Text(
                                "9876543210",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // OTHER FIELDS
                    _label("Full Name"),
                    _inputField(Icons.person, "Arjun Kumar"),

                    const SizedBox(height: 16),

                    _label("Date of Birth"),
                    Row(
                      children: [
                        Expanded(
                          child: _inputField(
                              Icons.calendar_today, "15 Mar 2001"),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _dropdownField("25"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _label("Gender"),
                    _dropdownField("Male", icon: Icons.person),

                    const SizedBox(height: 16),

                    _label("Blood Group"),
                    _dropdownField("O+", icon: Icons.bloodtype),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔘 UPDATE BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFDB913), Color(0xFFF59E0B)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                alignment: Alignment.center,
                child: const Text(
                  "Update Profile",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
    );
  }

  Widget _inputField(IconData icon, String value) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF1E2A78)),
          const SizedBox(width: 10),
          Text(value),
        ],
      ),
    );
  }

  Widget _dropdownField(String value, {IconData? icon}) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (icon != null)
            Icon(icon, size: 20, color: const Color(0xFF1E2A78)),
          if (icon != null) const SizedBox(width: 10),
          Expanded(child: Text(value)),
          const Icon(Icons.keyboard_arrow_down),
        ],
      ),
    );
  }

  Widget _headerBtn(IconData icon, String text) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F2F6),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF1E2A78)),
          const SizedBox(width: 6),
          Text(text),
        ],
      ),
    );
  }
}