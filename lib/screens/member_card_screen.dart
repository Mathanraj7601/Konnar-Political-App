import "dart:io";
import "package:flutter/material.dart";
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
  // Exact Colors from your uploaded image
  final Color _maroonHeader = const Color(0xFF1223B3); // Blue Header
  final Color _yellowText = const Color(0xFFFFD100); // Yellow Text
  final Color _cardBackground = const Color(0xFFFAF9F6); // Off-white Card bg
  final Color _textColor = const Color(0xFF2C2C2C);

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
    final effectivePartyName = memberCard?.partyName ?? AppConfig.partyName;
    final effectiveName = memberCard?.memberName ?? user?.name ?? "N/A";
    final effectiveMemberId = memberCard?.memberId ?? user?.memberId ?? "N/A";
    final effectiveMobile = memberCard?.mobileNumber ?? user?.mobile ?? "N/A";
    final effectiveAddress = memberCard?.address ?? user?.address ?? "N/A";
    
    final effectiveProfileImagePath = authProvider.profileImagePath;
    final effectiveProfileImageUrl = memberCard?.profileImageUrl;
    final effectiveQr = memberCard?.memberQrPayload ??
        "${AppConfig.partyName}|$effectiveMemberId|$effectiveMobile|$effectiveName";

    return Scaffold(
      backgroundColor: Colors.grey.shade200, // Background behind the card
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
        color: _maroonHeader,
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
                // Removed AspectRatio to prevent bottom clipping!
                // Using a regular Container allows it to grow vertically based on content.
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias, // Keeps header inside rounded corners
                  child: Stack(
                    children: [
                      // 1. MAIN CONTENT STRUCTURE
                      Column(
                        mainAxisSize: MainAxisSize.min, // Hugs content perfectly
                        children: [
                          // BLUE HEADER
                          Container(
                            height: 60,
                            width: double.infinity,
                            color: _maroonHeader,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  effectivePartyName,
                                  style: TextStyle(
                                    color: _yellowText,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 6), // Push text up slightly for badge
                              ],
                            ),
                          ),

                          // BODY SECTION
                          Padding(
                            // Added plenty of padding at the bottom so QR code doesn't touch the edge
                            padding: const EdgeInsets.only(
                              left: 12,
                              right: 12,
                              top: 24, // Space for the overlapping badge
                              bottom: 20, 
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start, // Align to top
                              children: [
                                // LEFT COLUMN: Photo & QR
                                SizedBox(
                                  width: 75,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Profile Image Box
                                      Container(
                                        height: 80,
                                        width: 75,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.black87, width: 1.5),
                                          color: Colors.grey.shade300,
                                        ),
                                        child: _buildProfileImage(
                                          context,
                                          localPath: effectiveProfileImagePath,
                                          remoteUrl: effectiveProfileImageUrl,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      // QR Code
                                      Container(
                                        padding: const EdgeInsets.all(2),
                                        color: Colors.white,
                                        child: QrImageView(
                                          data: effectiveQr,
                                          version: QrVersions.auto,
                                          size: 65,
                                          padding: EdgeInsets.zero,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 16),

                                // CENTER COLUMN: Details
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 6),
                                      _buildAlignedRow("பெயர்", effectiveName),
                                      const SizedBox(height: 12),
                                      _buildAlignedRow("அலைபேசி", effectiveMobile),
                                      const SizedBox(height: 12),
                                      _buildAlignedRow("முகவரி", effectiveAddress),
                                      const SizedBox(height: 12),
                                      _buildAlignedRow("மாவட்டம்", "மதுரை"), // Placeholder District
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // 2. MEMBER CARD BADGE (Overlapping header)
                      Positioned(
                        top: 48, // Intersects the blue header and white body perfectly
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.black87, width: 1),
                            ),
                            child: const Text(
                              "உறுப்பினர் அட்டை",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                              ),
                            ),
                          ),
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

  // Helper to create the perfectly aligned colon layout
Widget _buildAlignedRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 85, // <-- CHANGED FROM 70 TO 85
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: _textColor,
            ),
          ),
        ),
        Text(
          " :   ",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: _textColor,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: _textColor,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
  Widget _buildProfileImage(BuildContext context, {String? localPath, String? remoteUrl}) {
    Widget fallback() => const Icon(Icons.person, size: 40, color: Colors.grey);

    if (localPath != null && localPath.isNotEmpty) {
      try {
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