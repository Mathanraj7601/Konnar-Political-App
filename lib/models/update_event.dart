class UpdateEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String imageUrl;
  final String? videoUrl;

  UpdateEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.imageUrl,
    this.videoUrl,
  });

  factory UpdateEvent.fromJson(Map<String, dynamic> json) {
    return UpdateEvent(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      imageUrl: json['image_url'] ?? '',
      videoUrl: json['video_url'],
    );
  }
}