import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../services/navigation_service.dart';

class AnnouncementsPage extends StatefulWidget {
  const AnnouncementsPage({super.key});

  @override
  State<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  // Track expanded state for each announcement
  final List<bool> _expandedStates = [];
  List<dynamic> _announcements = [];
  bool _isLoading = true;

  // Replace localhost with your backend IP (e.g., 10.0.2.2 for Android Emulator)
  final String apiUrl = 'http://localhost:4000/api/announcements';

  @override
  void initState() {
    super.initState();
    _fetchAnnouncements();
  }

  Future<void> _fetchAnnouncements() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _announcements = data['data'];
          _expandedStates.clear();
          _expandedStates.addAll(List.filled(_announcements.length, false));
        });
      }
    } catch (e) {
      debugPrint("Error fetching announcements: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAnnouncement(String id) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/$id'));
      if (response.statusCode == 200) {
        _fetchAnnouncements();
      }
    } catch (e) {
      debugPrint("Error deleting announcement: $e");
    }
  }

  void _showFormDialog({Map<String, dynamic>? announcement}) {
    final isEditing = announcement != null;
    final titleCtrl = TextEditingController(text: isEditing ? announcement['title'] : '');
    final descCtrl = TextEditingController(text: isEditing ? announcement['description'] : '');
    final dateCtrl = TextEditingController(text: isEditing ? announcement['date'] : 'MAY 01, 2024');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? 'Edit Announcement' : 'New Announcement'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
              TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'Date (e.g. MAY 01, 2024)')),
              TextField(controller: descCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Description')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final payload = json.encode({
                'title': titleCtrl.text,
                'description': descCtrl.text,
                'date': dateCtrl.text,
              });
              
              try {
                if (isEditing) {
                  await http.put(Uri.parse('$apiUrl/${announcement['id']}'),
                      headers: {'Content-Type': 'application/json'}, body: payload);
                } else {
                  await http.post(Uri.parse(apiUrl),
                      headers: {'Content-Type': 'application/json'}, body: payload);
                }
                if (mounted) Navigator.pop(ctx);
                _fetchAnnouncements();
              } catch (e) {
                debugPrint("Error saving announcement: $e");
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

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
          'Announcements',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        titleSpacing: 0,
      ),

      // 🔹 BODY
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _announcements.isEmpty 
              ? const Center(child: Text("No Announcements yet."))
              : RefreshIndicator(
                  onRefresh: _fetchAnnouncements,
                  child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _announcements.length,
        itemBuilder: (context, index) {
          final item = _announcements[index];
          final desc = (item['description'] ?? '').toString();

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),

            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔸 LEFT CONTENT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // DATE
                      Text(
                        item['date'] ?? 'Unknown Date',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // TITLE
                      Text(
                        item['title'] ?? 'No Title',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // DESCRIPTION
                      Text(
                        _expandedStates[index]
                            ? desc
                            : '${desc.substring(0, desc.length > 50 ? 50 : desc.length)}${desc.length > 50 ? '...' : ''}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // READ MORE / SHOW LESS
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _expandedStates[index] = !_expandedStates[index];
                            });
                          },
                          child: Text(
                            _expandedStates[index] ? 'Show Less' : 'Read More >',
                            style: const TextStyle(
                              color: Color(0xFF1E2A78),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 🔸 RIGHT CHEVRON
                const Padding(
                  padding: EdgeInsets.only(left: 8, top: 4),
                  child: Icon(
                    Icons.chevron_right,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        },
      ),
              ),
    );
  }
}