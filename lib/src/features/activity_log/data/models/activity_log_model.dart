import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/activity_log_entity.dart';

class ActivityLogModel extends ActivityLogEntity {
  const ActivityLogModel({
    required super.id,
    required super.actorId,
    required super.actorRole,
    required super.action,
    super.targetId,
    super.targetType,
    super.metadata,
    required super.timestamp,
  });

  factory ActivityLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ActivityLogModel(
      id: doc.id,
      actorId: data['actorId'] as String? ?? '',
      actorRole: _parseRole(data['actorRole'] as String?),
      action: data['action'] as String? ?? '',
      targetId: data['targetId'] as String?,
      targetType: data['targetType'] as String?,
      metadata: data['metadata'] as Map<String, dynamic>?,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory ActivityLogModel.fromEntity(ActivityLogEntity entity) {
    return ActivityLogModel(
      id: entity.id,
      actorId: entity.actorId,
      actorRole: entity.actorRole,
      action: entity.action,
      targetId: entity.targetId,
      targetType: entity.targetType,
      metadata: entity.metadata,
      timestamp: entity.timestamp,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'actorId': actorId,
      'actorRole': actorRole.name,
      'action': action,
      'targetId': targetId,
      'targetType': targetType,
      'metadata': metadata,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  static UserRole _parseRole(String? value) => switch (value) {
        'admin' => UserRole.admin,
        'manager' => UserRole.manager,
        'reception' => UserRole.reception,
        'technician' => UserRole.technician,
        _ => UserRole.customer,
      };
}
