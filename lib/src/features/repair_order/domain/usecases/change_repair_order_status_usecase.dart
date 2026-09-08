import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/permissions/permission.dart';
import '../../../../core/permissions/permission_resolver.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../entities/repair_order_entity.dart';
import '../repositories/repair_order_repository.dart';

/// Generic forward transitions — everything except `received` (see
/// `ReceiveRepairOrderUseCase`), `assigned` (see
/// `AssignRepairOrderTechnicianUseCase`) and `cancelled` (see
/// `CancelRepairOrderUseCase`), each of which needs extra fields beyond a
/// bare status change.
class ChangeRepairOrderStatusUseCase
    extends UseCase<RepairOrderEntity, ChangeRepairOrderStatusParams> {
  final RepairOrderRepository _repository;

  ChangeRepairOrderStatusUseCase(this._repository);

  @override
  Future<Either<Failure, RepairOrderEntity>> call(
      ChangeRepairOrderStatusParams params) {
    final requiredPermission = params.to == RepairOrderStatus.completed ||
            params.to == RepairOrderStatus.delivered
        ? Permission.completeRepairOrder
        : Permission.updateRepairOrder;

    if (!PermissionResolver.hasPermission(
        params.actor.role, requiredPermission)) {
      return Future.value(
        const Left(OperationNotAllowedFailure(
            'Bạn không có quyền thay đổi trạng thái này.')),
      );
    }
    return _repository.changeStatus(params.id,
        to: params.to, actor: params.actor);
  }
}

class ChangeRepairOrderStatusParams extends Equatable {
  final String id;
  final RepairOrderStatus to;
  final UserEntity actor;

  const ChangeRepairOrderStatusParams({
    required this.id,
    required this.to,
    required this.actor,
  });

  @override
  List<Object?> get props => [id, to, actor];
}
