import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/permissions/permission.dart';
import '../../../../core/permissions/permission_resolver.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../entities/repair_order_entity.dart';
import '../repositories/repair_order_repository.dart';

class CancelRepairOrderUseCase
    extends UseCase<RepairOrderEntity, CancelRepairOrderParams> {
  final RepairOrderRepository _repository;

  CancelRepairOrderUseCase(this._repository);

  @override
  Future<Either<Failure, RepairOrderEntity>> call(
      CancelRepairOrderParams params) {
    if (!PermissionResolver.hasPermission(
        params.actor.role, Permission.cancelRepairOrder)) {
      return Future.value(
        const Left(
            OperationNotAllowedFailure('Bạn không có quyền huỷ đơn sửa chữa.')),
      );
    }
    return _repository.cancelRepairOrder(params.id,
        actor: params.actor, reason: params.reason);
  }
}

class CancelRepairOrderParams extends Equatable {
  final String id;
  final UserEntity actor;
  final String? reason;

  const CancelRepairOrderParams({
    required this.id,
    required this.actor,
    this.reason,
  });

  @override
  List<Object?> get props => [id, actor, reason];
}
