class Activity {
  final String id;
  final String personId;
  final String name;
  final bool isCurrent;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final DateTime createdAt;

  Activity({
    required this.id,
    required this.personId,
    required this.name,
    this.isCurrent = false,
    this.startedAt,
    this.endedAt,
    required this.createdAt,
  });

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'],
      personId: map['person_id'],
      name: map['name'],
      isCurrent: map['is_current'] == 1,
      startedAt: map['started_at'] != null ? DateTime.parse(map['started_at']) : null,
      endedAt: map['ended_at'] != null ? DateTime.parse(map['ended_at']) : null,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'person_id': personId,
      'name': name,
      'is_current': isCurrent ? 1 : 0,
      'started_at': startedAt?.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
