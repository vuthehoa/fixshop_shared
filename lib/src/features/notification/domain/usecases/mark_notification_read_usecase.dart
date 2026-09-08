import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

class MarkNotificationReadUseCase
    extends UseCase<NotificationEntity, MarkNotificationReadParams> {
  final NotificationRepository _repository;

  MarkNotificationReadUseCase(this._repository);

  @override
  Future<Either<Failure, NotificationEntity>> call(
      MarkNotificationReadParams params) {
    return _repository.markAsRead(params.id);
  }
}

class MarkNotificationReadParams extends Equatable {
  final String id;

  const MarkNotificationReadParams(this.id);

  @override
  List<Object> get props => [id];
}
