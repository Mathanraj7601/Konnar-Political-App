import "dart:io";
import "package:flutter/material.dart";
import "package:flutter/foundation.dart" show kIsWeb;
import "package:provider/provider.dart";
import "package:qr_flutter/qr_flutter.dart";

import "../config/app_config.dart";
import "../providers/auth_provider.dart";
import "login_screen.dart";

class MemberCardScreen extends StatefulWidget {
  const MemberCardScreen({super.key});

  @override
  State<MemberCardScreen> createState() => _MemberCardScreenState();
}

class _MemberCardScreenState extends State<MemberCardScreen> {
  // Colors sampled from your uploaded image
  final Color _darkBlue = const Color(0xFF1E3264); // Main Theme Color
  final Color _goldColor = const Color(0xFFD4AF37); // Yellow/Gold accents
  final Color _cardBackground = const Color(0xFFF9F6EE); // Off-white/Beige
  final Color _textColor = const Color(0xFF1E3264); // Dark blue text for details

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthProvider>().fetchMemberCard();
      }
    });
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final memberCard = authProvider.memberCard;
    final user = authProvider.currentUser;

    if (!authProvider.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text("அமர்வு முடிந்தது")),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text("உள்நுழையவும்"),
          ),
        ),
      );
    }

    // Fallback data mapping
    final effectiveName = memberCard?.memberName ?? user?.name ?? "Ijju";
    final effectiveMemberId = memberCard?.memberId ?? user?.memberId ?? "A26#MDU0001";
    final effectiveMobile = memberCard?.mobileNumber ?? user?.mobile ?? "N/A";
    
    // You can replace these with actual API data fields if they exist in your model
    final effectiveFatherName = "R. Selvapandian"; 
    final effectiveAge = "23";
    final effectiveDoj = "01 Jan 2024";
    final effectiveConstituency = "Kancheepuram";
    final effectiveDistrict = "Kancheepuram";

    final effectiveProfileImagePath = authProvider.profileImagePath;
    final effectiveProfileImageUrl = memberCard?.profileImageUrl;
    final effectiveQr = memberCard?.memberQrPayload ??
        "${AppConfig.partyName}|$effectiveMemberId|$effectiveMobile|$effectiveName";

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: const Text(
          "எனது அடையாள அட்டை",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: "வெளியேறு",
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<AuthProvider>().fetchMemberCard(),
        color: _darkBlue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            children: [
              if (authProvider.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    authProvider.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              // --- THE PHYSICAL CARD UI ---
              Center(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _darkBlue, width: 2), // Outer Blue Border
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1. HEADER SECTION (Dark Blue)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                        decoration: BoxDecoration(
                          color: _darkBlue,
                          border: Border(bottom: BorderSide(color: _goldColor, width: 3)), // Inner gold line
                        ),
                        child: Row(
                          children: [
                            // Small Leader Portraits (Placeholders)
                            _buildLeaderPortraits(),
                            const SizedBox(width: 8),
                            // Party Title & Subtitle
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "ஆயர் புரட்சி கழகம்",
                                    style: TextStyle(
                                      color: _goldColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(height: 1, width: 20, color: _goldColor),
                                      const SizedBox(width: 8),
                                      const Text(
                                        "கோனார் - வன்னியர் - அமைப்பு",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(height: 1, width: 20, color: _goldColor),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 2. BODY SECTION (Off-white / Details)
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left: Profile Photo
                                Container(
                                  width: 90,
                                  height: 110,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: _goldColor, width: 2),
                                    color: Colors.grey.shade300,
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: _buildProfileImage(
                                    context,
                                    localPath: effectiveProfileImagePath,
                                    remoteUrl: effectiveProfileImageUrl,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                
                                // Center: Text Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildDetailText("Name: ", effectiveName, isBold: true),
                                      const SizedBox(height: 4),
                                      _buildDetailText("Father's Name: ", effectiveFatherName),
                                      const SizedBox(height: 4),
                                      _buildDetailText("Age: ", effectiveAge),
                                      const SizedBox(height: 4),
                                      _buildDetailText("Date of Joining: ", effectiveDoj),
                                      const SizedBox(height: 4),
                                      _buildDetailText("Constituency: ", effectiveConstituency),
                                      const SizedBox(height: 4),
                                      _buildDetailText("District: ", effectiveDistrict),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Right: QR Code
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: QrImageView(
                                    data: effectiveQr,
                                    version: QrVersions.auto,
                                    size: 65,
                                    padding: EdgeInsets.zero,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Membership ID Pill
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: Colors.grey.shade400, width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _darkBlue,
                                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(30)),
                                    ),
                                    child: const Text(
                                      "Membership ID",
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(30)),
                                    ),
                                    child: Text(
                                      effectiveMemberId,
                                      style: TextStyle(color: _darkBlue, fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 3. FOOTER SECTION (Dark Blue)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                        decoration: BoxDecoration(
                          color: _darkBlue,
                          border: Border(top: BorderSide(color: _goldColor, width: 3)), // Inner gold line
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "இயக்கத்தின் அலுவலகம்: 261, எச்.என்.எச்.சாலை, கோமாப்பாட்டன், சென்னை - 600102",
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            // Social Media Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildSocialItem(Icons.camera_alt, "konar_youth_leader", Colors.pinkAccent),
                                _buildSocialItem(Icons.facebook, "konaryouthofficial", Colors.blueAccent),
                                _buildSocialItem(Icons.flutter_dash, "KonarYouthOrg", Colors.lightBlue), // Placeholder for Twitter
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
              const Text(
                "அட்டையை தெளிவாகப் பார்க்க உங்கள் மொபைலைத் திருப்பவும்",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              if (authProvider.isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper for the inline Text Details (Label: Value)
  Widget _buildDetailText(String label, String value, {bool isBold = false}) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 12,
          color: _textColor,
          height: 1.4, // Good line spacing
        ),
        children: [
          TextSpan(
            text: label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          TextSpan(
            text: value,
            style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.w500, fontSize: isBold ? 14 : 12),
          ),
        ],
      ),
    );
  }

  // Helper for the Social Media footer row
  Widget _buildSocialItem(IconData icon, String handle, Color iconColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 14),
        const SizedBox(width: 4),
        Text(
          handle,
          style: const TextStyle(color: Colors.white, fontSize: 9),
        ),
      ],
    );
  }

  // Helper to generate the 5 overlapping/adjacent small leader portraits in the header
  Widget _buildLeaderPortraits() {
    // Note: Replace these Image.assets with your actual leader images. 
    // Using simple colored circles with person icons as placeholders.
    return SizedBox(
      width: 70, // Constraints for the small group
      child: Wrap(
        spacing: 2,
        runSpacing: 2,
        children: List.generate(5, (index) {
          return Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _goldColor, width: 1),
              color: Colors.grey.shade400,
            ),
            child: const Icon(Icons.person, size: 12, color: Colors.white),
          );
        }),
      ),
    );
  }

  Widget _buildProfileImage(BuildContext context, {String? localPath, String? remoteUrl}) {
    Widget fallback() => const Icon(Icons.person, size: 40, color: Colors.grey);

    if (localPath != null && localPath.isNotEmpty) {
      try {
        if (kIsWeb) {
          return Image.network(
            localPath,
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) => fallback(),
          );
        }
        return Image.file(
          File(localPath),
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) {
            if (remoteUrl != null && remoteUrl.isNotEmpty) {
              return Image.network(
                remoteUrl,
                fit: BoxFit.cover,
                errorBuilder: (c2, e2, s2) => fallback(),
              );
            }
            return fallback();
          },
        );
      } catch (e) {
        if (remoteUrl != null && remoteUrl.isNotEmpty) {
          return Image.network(
            remoteUrl,
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) => fallback(),
          );
        }
        return fallback();
      }
    }

    if (remoteUrl != null && remoteUrl.isNotEmpty) {
      return Image.network(
        remoteUrl,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => fallback(),
      );
    }

    return Image.asset(
      AppConfig.profileImageAsset,
      fit: BoxFit.cover,
      errorBuilder: (c, e, s) => fallback(),
    );
  }
}