class MoodEntry {
  final int? id;
  final String mood;
  final String note;
  final DateTime date;
  final String? imagePath;

  MoodEntry({
    this.id,
    required this.mood,
    required this.note,
    required this.date,
    this.imagePath,
  });

  // Convert MoodEntry to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mood': mood,
      'note': note,
      'date': date.toIso8601String(),
      'imagePath': imagePath,
    };
  }

  // Create MoodEntry from Map
  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id'],
      mood: map['mood'],
      note: map['note'],
      date: DateTime.parse(map['date']),
      imagePath: map['imagePath'],
    );
  }

  // Copy with method for easy updates
  MoodEntry copyWith({
    int? id,
    String? mood,
    String? note,
    DateTime? date,
    String? imagePath,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      mood: mood ?? this.mood,
      note: note ?? this.note,
      date: date ?? this.date,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
