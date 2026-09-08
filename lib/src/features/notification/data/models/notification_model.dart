import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.type,
    required super.title,
    required super.body,
    required super.customerId,
    required super.customerName,
    super.targetType,
    super.targetId,
    super.createdBy,
    required super.createdAt,
    super.readAt,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      type: NotificationType.fromName(data['type'] as String?),
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      customerId: data['customerId'] as String? ?? '',
      customerName: data['customerName'] as String? ?? '',
      targetType: data['targetType'] as String?,
      targetId: data['targetId'] as String?,
      createdBy: data['createdBy'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readAt: (data['readAt'] as Timestamp?)?.toDate(),
    );
  }

  factory NotificationModel.fromEntity(NotificationEntity entity) {
    return NotificationModel(
      id: entity.id,
      type: entity.type,
      title: entity.title,
      body: entity.body,
      customerId: entity.customerId,
      customerName: entity.customerName,
      targetType: entity.targetType,
      targetId: entity.targetId,
      createdBy: entity.createdBy,
      createdAt: entity.createdAt,
      readAt: entity.readAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type.wireValue,
      'title': title,
      'body': body,
      'customerId': customerId,
      'customerName': customerName,
      'targetType': targetType,
      'targetId': targetId,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'readAt': readAt == null ? null : Timestamp.fromDate(readAt!),
    };
  }
}
