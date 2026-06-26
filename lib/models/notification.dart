class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final String type; // "appointment", "queue", "medicine", "general"
  final bool isRead;
  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });
  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? timestamp,
    String? type,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
    );
  }

  factory AppNotification.fromMap(Map<String, dynamic> map, String docId) {
    return AppNotification(
      id: docId,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      type: map['type'] ?? 'general',
      isRead: map['isRead'] ?? false,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'isRead': isRead,
    };
  }
}
