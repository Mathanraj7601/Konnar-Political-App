class Announcement {
  final String id;
  final String title;
  final String description;
  final DateTime date;

  Announcement({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
    );
  }
}