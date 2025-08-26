enum AssetStatus {
  yetToAcquire,
  onEmi,
  owned,
}

class Asset {
  final String id;
  final String personId;
  final String name;
  final AssetStatus status;
  final double progress;
  final double? totalAmount;
  final double currentAmount;
  final DateTime createdAt;

  Asset({
    required this.id,
    required this.personId,
    required this.name,
    required this.status,
    required this.progress,
    this.totalAmount,
    this.currentAmount = 0.0,
    required this.createdAt,
  });

  factory Asset.fromMap(Map<String, dynamic> map) {
    return Asset(
      id: map['id'],
      personId: map['person_id'],
      name: map['name'],
      status: AssetStatus.values.firstWhere((e) => e.name == map['status']),
      progress: map['progress'],
      totalAmount: map['total_amount'],
      currentAmount: map['current_amount'] ?? 0.0,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'person_id': personId,
      'name': name,
      'status': status.name,
      'progress': progress,
      'total_amount': totalAmount,
      'current_amount': currentAmount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
