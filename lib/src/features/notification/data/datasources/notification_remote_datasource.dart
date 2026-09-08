import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/paginated_result.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/value_objects/notification_filter.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<NotificationModel> createNotification(NotificationModel entity);

  Future<PaginatedResult<NotificationModel>> getNotifications(
    NotificationFilter filter, {
    DocumentSnapshot? startAfter,
  });

  Future<NotificationModel> markAsRead(String id);

  Future<bool> hasRecentNotification({
    required String targetId,
    required NotificationType type,
    required DateTime since,
  });
}
