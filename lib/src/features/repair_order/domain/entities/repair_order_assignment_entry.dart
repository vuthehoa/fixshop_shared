import 'package:equatable/equatable.dart';

/// One row in a repair order's assignment history. Reassignment is allowed —
/// every assignment (initial or reassignment) appends a new entry rather
/// than overwriting the last one, so the full history survives.
class RepairOrderAssignmentEntry extends Equatable {
  final String technicianId;
  final String technicianName;
  final String assignedBy;
  final DateTime assignedAt;

  const RepairOrderAssignmentEntry({
    required this.technicianId,
    required this.technicianName,
    required this.assignedBy,
    required this.assignedAt,
  });

  factory RepairOrderAssignmentEntry.fromMap(Map<String, dynamic> map) {
    return RepairOrderAssignmentEntry(
      technicianId: map['technicianId'] as String? ?? '',
      technicianName: map['technicianName'] as String? ?? '',
      assignedBy: map['assignedBy'] as String? ?? '',
      assignedAt: (map['assignedAt'] as DateTime?) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'technicianId': technicianId,
      'technicianName': technicianName,
      'assignedBy': assignedBy,
      'assignedAt': assignedAt,
    };
  }

  @override
  List<Object?> get props =>
      [technicianId, technicianName, assignedBy, assignedAt];
}
