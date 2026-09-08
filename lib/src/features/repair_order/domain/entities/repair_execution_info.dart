import 'package:equatable/equatable.dart';

/// The technician's working record for the current repair attempt —
/// embedded on [RepairOrderEntity], not a separate collection.
///
/// Deliberately does NOT duplicate [RepairOrderEntity.diagnosis] (the
/// diagnosis result already has its own field/timeline event) or
/// [RepairOrderEntity.attachments] (already exists at the order level).
///
/// [workStartedAt]/[workCompletedAt] track the *current* repair attempt and
/// are allowed to change across a failed-testing retry loop —
/// [RepairOrderEntity.startedAt] remains the historical record of when
/// repair work *first* began and is never overwritten.
class RepairExecutionInfo extends Equatable {
  final String? repairNotes;
  final String? repairMethod;
  final String? technicianNotes;
  final DateTime? workStartedAt;
  final DateTime? workCompletedAt;
  final String? lastUpdatedBy;
  final DateTime? lastUpdatedAt;

  const RepairExecutionInfo({
    this.repairNotes,
    this.repairMethod,
    this.technicianNotes,
    this.workStartedAt,
    this.workCompletedAt,
    this.lastUpdatedBy,
    this.lastUpdatedAt,
  });

  factory RepairExecutionInfo.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const RepairExecutionInfo();
    return RepairExecutionInfo(
      repairNotes: map['repairNotes'] as String?,
      repairMethod: map['repairMethod'] as String?,
      technicianNotes: map['technicianNotes'] as String?,
      workStartedAt: map['workStartedAt'] as DateTime?,
      workCompletedAt: map['workCompletedAt'] as DateTime?,
      lastUpdatedBy: map['lastUpdatedBy'] as String?,
      lastUpdatedAt: map['lastUpdatedAt'] as DateTime?,
    );
  }

  RepairExecutionInfo copyWith({
    String? repairNotes,
    String? repairMethod,
    String? technicianNotes,
    DateTime? workStartedAt,
    DateTime? workCompletedAt,
    bool clearWorkCompletedAt = false,
    String? lastUpdatedBy,
    DateTime? lastUpdatedAt,
  }) {
    return RepairExecutionInfo(
      repairNotes: repairNotes ?? this.repairNotes,
      repairMethod: repairMethod ?? this.repairMethod,
      technicianNotes: technicianNotes ?? this.technicianNotes,
      workStartedAt: workStartedAt ?? this.workStartedAt,
      workCompletedAt: clearWorkCompletedAt
          ? null
          : (workCompletedAt ?? this.workCompletedAt),
      lastUpdatedBy: lastUpdatedBy ?? this.lastUpdatedBy,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'repairNotes': repairNotes,
      'repairMethod': repairMethod,
      'technicianNotes': technicianNotes,
      'workStartedAt': workStartedAt,
      'workCompletedAt': workCompletedAt,
      'lastUpdatedBy': lastUpdatedBy,
      'lastUpdatedAt': lastUpdatedAt,
    };
  }

  @override
  List<Object?> get props => [
        repairNotes,
        repairMethod,
        technicianNotes,
        workStartedAt,
        workCompletedAt,
        lastUpdatedBy,
        lastUpdatedAt,
      ];
}
