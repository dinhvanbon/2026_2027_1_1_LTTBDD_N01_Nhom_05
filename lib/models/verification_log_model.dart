import 'package:cloud_firestore/cloud_firestore.dart';

/// Model lưu thông tin minh chứng và lịch sử phê duyệt nhiệm vụ.
class VerificationLogModel {
  final String id;
  final String taskId;
  final String childId;
  final String parentId;
  final String status;
  final String? note;
  final String? evidenceUrl;
  final DateTime submittedAt;
  final DateTime? verifiedAt;

  const VerificationLogModel({
    required this.id,
    required this.taskId,
    required this.childId,
    required this.parentId,
    required this.status,
    this.note,
    this.evidenceUrl,
    required this.submittedAt,
    this.verifiedAt,
  });

  factory VerificationLogModel.fromMap(String id, Map<String, dynamic> map) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    return VerificationLogModel(
      id: id,
      taskId: map['taskId']?.toString() ?? '',
      childId: map['childId']?.toString() ?? '',
      parentId: map['parentId']?.toString() ?? '',
      status: map['status']?.toString() ?? 'submitted',
      note: map['note']?.toString(),
      evidenceUrl: map['evidenceUrl']?.toString(),
      submittedAt: parseDate(map['submittedAt']),
      verifiedAt: map['verifiedAt'] != null ? parseDate(map['verifiedAt']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'taskId': taskId,
      'childId': childId,
      'parentId': parentId,
      'status': status,
      'note': note,
      'evidenceUrl': evidenceUrl,
      'submittedAt': Timestamp.fromDate(submittedAt),
      if (verifiedAt != null) 'verifiedAt': Timestamp.fromDate(verifiedAt!),
    };
  }
}
