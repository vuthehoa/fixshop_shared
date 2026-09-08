import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/paginated_result.dart';
import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';
import '../value_objects/notification_filter.dart';

class GetNotificationsUseCase extends UseCase<
    PaginatedResult<NotificationEntity>, GetNotificationsParams> {
  final NotificationRepository _repository;

  GetNotificationsUseCase(this._repository);

  @override
  Future<Either<Failure, PaginatedResult<NotificationEntity>>> call(
    GetNotificationsParams params,
  ) {
    return _repository.getNotifications(params.filter,
        startAfter: params.startAfter);
  }
}

class GetNotificationsParams extends Equatable {
  final NotificationFilter filter;
  final DocumentSnapshot? startAfter;

  const GetNotificationsParams({required this.filter, this.startAfter});

  @override
  List<Object?> get props => [filter, startAfter];
}
