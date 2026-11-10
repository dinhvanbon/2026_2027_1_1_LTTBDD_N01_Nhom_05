enum TaskStatus { pending, submitted, approved, rejected }

class TaskModel {
  final String id;
  final String parentId;
  final String childId;
  final String title;
  final String description;
  final String difficulty;
  final int expReward;
  final int rewardAmount;
  final TaskStatus status;
  final DateTime createdAt;
  final DateTime? submittedAt;
  final DateTime? verifiedAt;
  final DateTime? deadlineAt;
  final String? proofImage;
  final String? childNote;

  const TaskModel({
    required this.id,
    required this.parentId,
    required this.childId,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.expReward,
    required this.rewardAmount,
    required this.status,
    required this.createdAt,
    this.submittedAt,
    this.verifiedAt,
    this.deadlineAt,
    this.proofImage,
    this.childNote,
  });

  TaskModel copyWith({
    String? id,
    String? parentId,
    String? childId,
    String? title,
    String? description,
    String? difficulty,
    int? expReward,
    int? rewardAmount,
    TaskStatus? status,
    DateTime? createdAt,
    DateTime? submittedAt,
    DateTime? verifiedAt,
    DateTime? deadlineAt,
    String? proofImage,
    String? childNote,
  }) {
    return TaskModel(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      childId: childId ?? this.childId,
      title: title ?? this.title,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      expReward: expReward ?? this.expReward,
      rewardAmount: rewardAmount ?? this.rewardAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      submittedAt: submittedAt ?? this.submittedAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      deadlineAt: deadlineAt ?? this.deadlineAt,
      proofImage: proofImage ?? this.proofImage,
      childNote: childNote ?? this.childNote,
    );
  }

  factory TaskModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TaskModel(
      id: documentId,
      parentId: map['parentId'] ?? '',
      childId: map['childId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      difficulty: map['difficulty'] ?? 'Dễ',
      expReward: map['expReward'] ?? 0,
      rewardAmount: map['rewardAmount'] ?? 0,
      status: _parseStatus(map['status']),
      createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      submittedAt: map['submittedAt'] != null
          ? (map['submittedAt'] as dynamic).toDate()
          : null,
      verifiedAt: map['verifiedAt'] != null
          ? (map['verifiedAt'] as dynamic).toDate()
          : null,
      deadlineAt: map['deadlineAt'] != null
          ? (map['deadlineAt'] as dynamic).toDate()
          : null,
      proofImage: map['proofImage'],
      childNote: map['childNote'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'parentId': parentId,
      'childId': childId,
      'title': title,
      'description': description,
      'difficulty': difficulty,
      'expReward': expReward,
      'rewardAmount': rewardAmount,
      'status': status.name,
      'createdAt': createdAt,
      'submittedAt': submittedAt,
      'verifiedAt': verifiedAt,
      'deadlineAt': deadlineAt,
      'proofImage': proofImage,
      'childNote': childNote,
    };
  }

  static TaskStatus _parseStatus(dynamic value) {
    switch (value) {
      case 'submitted':
        return TaskStatus.submitted;
      case 'approved':
        return TaskStatus.approved;
      case 'rejected':
        return TaskStatus.rejected;
      default:
        return TaskStatus.pending;
    }
  }

  bool get isExpired {
    if (deadlineAt == null) return false;
    if (status != TaskStatus.pending) return false;
    return DateTime.now().isAfter(deadlineAt!);
  }

  String get deadlineText {
    if (deadlineAt == null) return 'Không có hạn';
    final d = deadlineAt!;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  String get statusText {
    switch (status) {
      case TaskStatus.pending:
        return 'Đang chờ làm';
      case TaskStatus.submitted:
        return 'Chờ phụ huynh xác nhận';
      case TaskStatus.approved:
        return 'Đã xác nhận';
      case TaskStatus.rejected:
        return 'Bị từ chối';
    }
  }
}
