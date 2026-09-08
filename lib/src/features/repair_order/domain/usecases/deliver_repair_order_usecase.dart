import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/permissions/permission.dart';
import '../../../../core/permissions/permission_resolver.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../entities/delivery_info.dart';
import '../entities/repair_order_entity.dart';
import '../repositories/repair_order_repository.dart';

/// Same permission tier as [PassTestingUseCase]/completing an order —
/// `completeRepairOrder` already gated the generic path to `delivered` since
/// Sprint 7, so no new permission is introduced here.
class DeliverRepairOrderUseCase
    extends UseCase<RepairOrderEntity, DeliverRepairOrderParams> {
  final RepairOrderRepository _repository;

  DeliverRepairOrderUseCase(this._repository);

  @override
  Future<Either<Failure, RepairOrderEntity>> call(
      DeliverRepairOrderParams params) {
    if (!PermissionResolver.hasPermission(
        params.actor.role, Permission.completeRepairOrder)) {
      return Future.value(
        const Left(OperationNotAllowedFailure(
            'Bạn không có quyền giao trả thiết bị.')),
      );
    }
    return _repository.deliverRepairOrder(
      params.id,
      delivery: params.delivery,
      actor: params.actor,
    );
  }
}

class DeliverRepairOrderParams extends Equatable {
  final String id;
  final DeliveryInfo delivery;
  final UserEntity actor;

  const DeliverRepairOrderParams({
    required this.id,
    required this.delivery,
    required this.actor,
  });

  @override
  List<Object?> get props => [id, delivery, actor];
}
