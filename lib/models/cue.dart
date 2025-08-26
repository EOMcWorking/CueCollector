enum CueType {
  conscious,
  subconscious,
  unconscious,
}

class Cue {
  final String id;
  final String personId;
  final CueType type;
  final String content;
  final String? audioPath;
  final DateTime createdAt;

  Cue({
    required this.id,
    required this.personId,
    required this.type,
    required this.content,
    this.audioPath,
    required this.createdAt,
  });

  factory Cue.fromMap(Map<String, dynamic> map) {
    return Cue(
      id: map['id'],
      personId: map['person_id'],
      type: CueType.values.firstWhere((e) => e.name == map['type']),
      content: map['content'],
      audioPath: map['audio_path'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'person_id': personId,
      'type': type.name,
      'content': content,
      'audio_path': audioPath,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
