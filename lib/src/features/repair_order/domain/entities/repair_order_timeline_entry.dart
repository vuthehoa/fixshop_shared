import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user_entity.dart';

/// A single narrative event in a repair order's history. Deliberately
/// separate from [ActivityLogEntity] (the CMS-internal audit trail, gated by
/// `isCmsUser()` in Firestore rules): the timeline is embedded on the order
/// document itself so a future Customer App can read it directly without
/// needing access to `activity_logs`.
enum RepairOrderTimelineEntryType {
  created,
  received,
  assigned,
  diagnosisUpdated,
  statusChanged,
  cancelled,
  completed,
  delivered,
  // Sprint 8 — repair execution & testing loop.
  diagnosisStarted,
  diagnosisCompleted,
  repairStarted,
  repairUpdated,
  sentToTesting,
  testingFailed,
  testingPassed;

  String get displayName => switch (this) {
        RepairOrderTimelineEntryType.created => 'Tạo đơn sửa chữa',
        RepairOrderTimelineEntryType.received => 'Tiếp nhận thiết bị',
        RepairOrderTimelineEntryType.assigned => 'Phân công kỹ thuật viên',
        RepairOrderTimelineEntryType.diagnosisUpdated => 'Cập nhật chẩn đoán',
        RepairOrderTimelineEntryType.statusChanged => 'Thay đổi trạng thái',
        RepairOrderTimelineEntryType.cancelled => 'Huỷ đơn',
        RepairOrderTimelineEntryType.completed => 'Hoàn thành sửa chữa',
        RepairOrderTimelineEntryType.delivered => 'Giao trả thiết bị',
        RepairOrderTimelineEntryType.diagnosisStarted => 'Bắt đầu chẩn đoán',
        RepairOrderTimelineEntryType.diagnosisCompleted => 'Hoàn tất chẩn đoán',
        RepairOrderTimelineEntryType.repairStarted => 'Bắt đầu sửa chữa',
        RepairOrderTimelineEntryType.repairUpdated =>
          'Cập nhật tiến độ sửa chữa',
        RepairOrderTimelineEntryType.sentToTesting => 'Gửi kiểm tra',
        RepairOrderTimelineEntryType.testingFailed => 'Kiểm tra không đạt',
        RepairOrderTimelineEntryType.testingPassed => 'Kiểm tra đạt yêu cầu',
      };

  static RepairOrderTimelineEntryType fromName(String? value) =>
      switch (value) {
        'created' => RepairOrderTimelineEntryType.created,
        'received' => RepairOrderTimelineEntryType.received,
        'assigned' => RepairOrderTimelineEntryType.assigned,
        'diagnosisUpdated' => RepairOrderTimelineEntryType.diagnosisUpdated,
        'statusChanged' => RepairOrderTimelineEntryType.statusChanged,
        'cancelled' => RepairOrderTimelineEntryType.cancelled,
        'completed' => RepairOrderTimelineEntryType.completed,
        'delivered' => RepairOrderTimelineEntryType.delivered,
        'diagnosisStarted' => RepairOrderTimelineEntryType.diagnosisStarted,
        'diagnosisCompleted' => RepairOrderTimelineEntryType.diagnosisCompleted,
        'repairStarted' => RepairOrderTimelineEntryType.repairStarted,
        'repairUpdated' => RepairOrderTimelineEntryType.repairUpdated,
        'sentToTesting' => RepairOrderTimelineEntryType.sentToTesting,
        'testingFailed' => RepairOrderTimelineEntryType.testingFailed,
        'testingPassed' => RepairOrderTimelineEntryType.testingPassed,
        _ => RepairOrderTimelineEntryType.statusChanged,
      };
}

class RepairOrderTimelineEntry extends Equatable {
  final RepairOrderTimelineEntryType type;
  final String message;
  final String actorId;
  final UserRole actorRole;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const RepairOrderTimelineEntry({
    required this.type,
    required this.message,
    required this.actorId,
    required this.actorRole,
    required this.timestamp,
    this.metadata,
  });

  factory RepairOrderTimelineEntry.fromMap(Map<String, dynamic> map) {
    return RepairOrderTimelineEntry(
      type: RepairOrderTimelineEntryType.fromName(map['type'] as String?),
      message: map['message'] as String? ?? '',
      actorId: map['actorId'] as String? ?? '',
      actorRole: _roleFromName(map['actorRole'] as String?),
      timestamp: (map['timestamp'] as DateTime?) ?? DateTime.now(),
      metadata: (map['metadata'] as Map?)?.cast<String, dynamic>(),
    );
  }

  static UserRole _roleFromName(String? value) => UserRole.values.firstWhere(
        (r) => r.name == value,
        orElse: () => UserRole.customer,
      );

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'message': message,
      'actorId': actorId,
      'actorRole': actorRole.name,
      'timestamp': timestamp,
      'metadata': metadata,
    };
  }

  @override
  List<Object?> get props =>
      [type, message, actorId, actorRole, timestamp, metadata];
}
