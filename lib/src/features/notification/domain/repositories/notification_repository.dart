import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/paginated_result.dart';
import '../entities/notification_entity.dart';
import '../value_objects/notification_filter.dart';

abstract class NotificationRepository {
  Future<Either<Failure, NotificationEntity>> createNotification(
      NotificationEntity entity);

  Future<Either<Failure, PaginatedResult<NotificationEntity>>> getNotifications(
    NotificationFilter filter, {
    DocumentSnapshot? startAfter,
  });

  Future<Either<Failure, NotificationEntity>> markAsRead(String id);

  /// Used by the warranty-expiring scan to avoid re-notifying the same
  /// device within the dedupe window — see `ScanWarrantyExpiringNotificationsUseCase`.
  Future<Either<Failure, bool>> hasRecentNotification({
    required String targetId,
    required NotificationType type,
    required DateTime since,
  });
}
