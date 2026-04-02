import "dart:io";
import "dart:typed_data";
import "dart:ui" as ui;
import "package:flutter/material.dart";
import "package:flutter/rendering.dart";
import "package:flutter/foundation.dart" show kIsWeb;
import "package:cross_file/cross_file.dart";
import "package:path_provider/path_provider.dart";
import "package:provider/provider.dart";
import "package:qr_flutter/qr_flutter.dart";
import "package:share_plus/share_plus.dart";
import "package:intl/intl.dart";
import "package:gal/gal.dart";

import "../config/app_config.dart";
import "../providers/auth_provider.dart";
import "login_screen.dart";
import '../utils/age_utils.dart';

class MemberCardScreen extends StatefulWidget {
  const MemberCardScreen({super.key});

  @override
  State<MemberCardScreen> createState() => _MemberCardScreenState();
}

class _MemberCardScreenState extends State<MemberCardScreen> {
  final Color _darkBlue = const Color(0xFF1B2A58);
  final Color _goldColor = const Color(0xFFC9A254);
  final Color _cardBackground = const Color(0xFFF7F5F0);
  final Color _textColor = const Color(0xFF1B2A58);

  final GlobalKey _cardKey = GlobalKey();

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

  Future<Uint8List?> _captureCard() async {
    try {
      RenderRepaintBoundary boundary = _cardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint("Error capturing card: $e");
      return null;
    }
  }

  Future<void> _downloadCard() async {
    try {
      final bytes = await _captureCard();
      if (bytes == null) return;

      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/member_card_download.png';
      final file = File(imagePath);
      await file.writeAsBytes(bytes);

      await Gal.putImage(imagePath);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("அடையாள அட்டை கேலரியில் சேமிக்கப்பட்டது! (Card Saved)")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("பதிவிறக்கம் தோல்வியடைந்தது (Failed): $e")),
      );
    }
  }

  Future<void> _shareCard() async {
    try {
      final bytes = await _captureCard();
      if (bytes == null) return;

      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/member_card_share.png';
      final file = File(imagePath);
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(imagePath)],
        text: 'எனது ஆயர் புரட்சி கழகம் அடையாள அட்டை!',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("பகிர முடியவில்லை (Failed to share): $e")),
      );
    }
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

    final effectiveName = memberCard?.memberName ?? user?.name ?? "Loading...";
    final effectiveMemberId = memberCard?.memberId ?? user?.memberId ?? "Loading...";
    final effectiveMobile = memberCard?.mobileNumber ?? user?.mobile ?? "N/A";
    
    // Use data from memberCard object, with fallbacks
    final effectiveFatherName = memberCard?.fatherName ?? "N/A";
    
    final int age = memberCard?.dob != null ? calculateAge(memberCard!.dob!) : 0;
    final effectiveAge = age > 0 ? age.toString() : "N/A";
    
    final effectiveDoj = memberCard?.dateOfJoining != null 
        ? DateFormat('dd MMM yyyy').format(memberCard!.dateOfJoining!) 
        : "N/A";
        
    final effectiveConstituency = memberCard?.constituency ?? "N/A";
    final effectiveDistrict = memberCard?.district ?? "N/A";

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
            onPressed: _downloadCard,
            icon: Icon(Icons.download, color: _darkBlue),
            tooltip: "பதிவிறக்க",
          ),
          IconButton(
            onPressed: _shareCard,
            icon: Icon(Icons.share, color: _darkBlue),
            tooltip: "பகிர",
          ),
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

              Center(
                child: RepaintBoundary(
                  key: _cardKey,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _darkBlue,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _cardBackground,
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: _goldColor, width: 1.5),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 1. HEADER SECTION
                          Container(
                            color: _darkBlue,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            child: Row(
                              children: [
                                _buildLeaderPortraits(),
                                const SizedBox(width: 8),
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
                                          shadows: const [Shadow(blurRadius: 1, color: Colors.black54)],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(height: 2, color: _goldColor),

                          // 2. BODY SECTION (Layout completely fixed)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Left side: Profile Image with FIXED dimensions
                                    Container(
                                      width: 95,
                                      height: 125, // Fixed height prevents it from stretching the text layout
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: _goldColor, width: 2),
                                        color: Colors.grey.shade300,
                                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2))],
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: _buildProfileImage(
                                        context,
                                        localPath: effectiveProfileImagePath,
                                        remoteUrl: effectiveProfileImageUrl,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    
                                    // Right side: Text aligned to the top with standard gaps
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _buildDetailText("Name: ", effectiveName, isBold: true),
                                          const SizedBox(height: 4), // Proper standard spacing
                                          _buildDetailText("Father's Name: ", effectiveFatherName),
                                          const SizedBox(height: 4), // Proper standard spacing
                                          _buildDetailText("Age: ", effectiveAge),
                                          const SizedBox(height: 12), // Space before bottom section
                                          
                                          // Bottom Row: Remaining Details + QR
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    _buildDetailText("Date of Joining: ", effectiveDoj),
                                                    const SizedBox(height: 3),
                                                    _buildDetailText("Constituency: ", effectiveConstituency),
                                                    const SizedBox(height: 3),
                                                    _buildDetailText("District: ", effectiveDistrict),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Container(
                                                padding: const EdgeInsets.all(3),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: Colors.grey.shade300),
                                                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(1, 1))],
                                                ),
                                                child: CustomPaint(
                                                  size: const Size(55, 55),
                                                  painter: QrPainter(
                                                    data: effectiveQr,
                                                    version: QrVersions.auto,
                                                    color: Colors.black,
                                                    emptyColor: Colors.transparent,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(color: Colors.grey.shade400, width: 1),
                                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 2))],
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
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEBEBEB),
                                            borderRadius: const BorderRadius.horizontal(right: Radius.circular(30)),
                                          ),
                                          child: Text(
                                            effectiveMemberId,
                                            style: TextStyle(color: _darkBlue, fontWeight: FontWeight.bold, fontSize: 13),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Container(height: 2, color: _goldColor),

                          // 3. FOOTER SECTION
                          Container(
                            width: double.infinity,
                            color: _darkBlue,
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                            child: Column(
                              children: [
                                const Text(
                                  "இயக்கத்தின் அலுவலகம்: 261, எச்.என்.எச்.சாலை, கோமாப்பாட்டன், சென்னை - 600102",
                                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    _buildInstagramItem("konar_youth_leader"),
                                    _buildDivider(),
                                    _buildSocialItem(Icons.facebook, "konaryouthofficial", Colors.blueAccent),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
              const Text(
                "அட்டையை தெளிவாகப் பார்க்க உங்கள் மொபைலைத் திருப்பவும்",
                style: TextStyle(color: Colors.grey, fontSize: 13),
                textAlign: TextAlign.center,
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

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 12,
      color: Colors.white54,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildDetailText(String label, String value, {bool isBold = false}) {
    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 12.5, color: _textColor, height: 1.4),
        children: [
          TextSpan(text: label, style: const TextStyle(fontWeight: FontWeight.w600)),
          TextSpan(
            text: value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              fontSize: isBold ? 14 : 12.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialItem(IconData icon, String handle, Color iconColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 14),
        const SizedBox(width: 4),
        Flexible(
          child: Text(handle, style: const TextStyle(color: Colors.white, fontSize: 9.5), overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _buildInstagramItem(String handle) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.network(
          'https://cdn-icons-png.flaticon.com/512/3938/3938036.png',
          width: 13,
          height: 13,
          color: Colors.pinkAccent, 
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(handle, style: const TextStyle(color: Colors.white, fontSize: 9.5), overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _buildLeaderPortraits() {
    return SizedBox(
      width: 80,
      height: 26,
      child: Stack(
        children: List.generate(5, (index) {
          return Positioned(
            left: index * 13.0,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _goldColor, width: 1.5),
                color: Colors.grey.shade400,
              ),
              child: const Icon(Icons.person, size: 18, color: Colors.white),
            ),
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