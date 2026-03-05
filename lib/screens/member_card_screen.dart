import "dart:io";

import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:qr_flutter/qr_flutter.dart";

import "../config/app_config.dart";
import "../providers/auth_provider.dart";
import "../utils/age_utils.dart";
import "login_screen.dart";

class MemberCardScreen extends StatefulWidget {
  const MemberCardScreen({super.key});

  @override
  State<MemberCardScreen> createState() => _MemberCardScreenState();
}

class _MemberCardScreenState extends State<MemberCardScreen> {
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

    if (!mounted) {
      return;
    }

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
        appBar: AppBar(title: const Text("Session Ended")),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Please login again to view your member card."),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  child: const Text("Go to Login"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final effectivePartyName = memberCard?.partyName ?? AppConfig.partyName;
    final effectiveName = memberCard?.memberName ?? user?.name ?? "";
    final effectiveMemberId = memberCard?.memberId ?? user?.memberId ?? "";
    final effectiveMobile = memberCard?.mobileNumber ?? user?.mobile ?? "";
    final effectiveAddress = memberCard?.address ?? user?.address ?? "";
    final effectiveDob = memberCard?.dob ?? user?.dob ?? DateTime(1970, 1, 1);
    final effectiveAge = memberCard?.age ?? user?.age ?? 0;
    final effectiveProfileImagePath = authProvider.profileImagePath;
    final effectiveProfileImageUrl = memberCard?.profileImageUrl;
    final effectiveQr =
        memberCard?.memberQrPayload ??
        "${AppConfig.partyName}|$effectiveMemberId|$effectiveMobile|$effectiveName";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Member Card"),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<AuthProvider>().fetchMemberCard(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (authProvider.errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  authProvider.errorMessage!,
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.22),
                          ),
                        ),
                        child: ClipOval(
                          child: _buildProfileImage(
                            context,
                            localPath: effectiveProfileImagePath,
                            remoteUrl: effectiveProfileImageUrl,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              effectivePartyName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text("Official Member Identity Card"),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _detailRow("Member Name", effectiveName),
                  _detailRow("Member ID", effectiveMemberId),
                  _detailRow("Mobile Number", effectiveMobile),
                  _detailRow("Address", effectiveAddress),
                  _detailRow("Date of Birth", formatDateLong(effectiveDob)),
                  _detailRow("Age", "$effectiveAge"),
                  const SizedBox(height: 14),
                  Center(
                    child: Column(
                      children: [
                        QrImageView(
                          data: effectiveQr,
                          version: QrVersions.auto,
                          size: 170,
                          backgroundColor: Colors.white,
                        ),
                        const SizedBox(height: 6),
                        const Text("Member QR Code"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (authProvider.isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 14),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value.isEmpty ? "-" : value)),
        ],
      ),
    );
  }

  Widget _buildProfileImage(
    BuildContext context, {
    String? localPath,
    String? remoteUrl,
  }) {
    Widget fallback() => Icon(
      Icons.person,
      size: 32,
      color: Theme.of(context).colorScheme.primary,
    );

    if (localPath != null && localPath.isNotEmpty) {
      return Image.file(
        File(localPath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallback(),
      );
    }

    if (remoteUrl != null && remoteUrl.isNotEmpty) {
      return Image.network(
        remoteUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallback(),
      );
    }

    return Image.asset(
      AppConfig.profileImageAsset,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => fallback(),
    );
  }
}
