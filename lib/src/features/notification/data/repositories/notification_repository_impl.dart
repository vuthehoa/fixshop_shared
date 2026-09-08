import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/paginated_result.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/value_objects/notification_filter.dart';
import '../datasources/notification_remote_datasource.dart';
import '../models/notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _dataSource;

  NotificationRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, NotificationEntity>> createNotification(
          NotificationEntity entity) =>
      _run(() =>
          _dataSource.createNotification(NotificationModel.fromEntity(entity)));

  @override
  Future<Either<Failure, PaginatedResult<NotificationEntity>>> getNotifications(
    NotificationFilter filter, {
    DocumentSnapshot? startAfter,
  }) async {
    final result = await _run(
        () => _dataSource.getNotifications(filter, startAfter: startAfter));
    return result.map(
      (page) => PaginatedResult<NotificationEntity>(
        items: page.items,
        lastDocument: page.lastDocument,
        hasMore: page.hasMore,
      ),
    );
  }

  @override
  Future<Either<Failure, NotificationEntity>> markAsRead(String id) =>
      _run(() => _dataSource.markAsRead(id));

  @override
  Future<Either<Failure, bool>> hasRecentNotification({
    required String targetId,
    required NotificationType type,
    required DateTime since,
  }) =>
      _run(() => _dataSource.hasRecentNotification(
          targetId: targetId, type: type, since: since));

  Future<Either<Failure, T>> _run<T>(Future<T> Function() fn) async {
    try {
      return Right(await fn());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
