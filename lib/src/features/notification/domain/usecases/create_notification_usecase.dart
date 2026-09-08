import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

/// Legacy direct Firestore writer. Server migration pending.
/// Manual CMS sends must use sendNotificationToCustomer instead.
class CreateNotificationUseCase
    extends UseCase<NotificationEntity, NotificationEntity> {
  final NotificationRepository _repository;

  CreateNotificationUseCase(this._repository);

  @override
  Future<Either<Failure, NotificationEntity>> call(NotificationEntity params) {
    return _repository.createNotification(params);
  }
}
