import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/permissions/permission.dart';
import '../../../../core/permissions/permission_resolver.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../entities/repair_execution_info.dart';
import '../entities/repair_order_entity.dart';
import '../repositories/repair_order_repository.dart';

class UpdateRepairExecutionUseCase
    extends UseCase<RepairOrderEntity, UpdateRepairExecutionParams> {
  final RepairOrderRepository _repository;

  UpdateRepairExecutionUseCase(this._repository);

  @override
  Future<Either<Failure, RepairOrderEntity>> call(
      UpdateRepairExecutionParams params) {
    if (!PermissionResolver.hasPermission(
        params.actor.role, Permission.updateRepairOrder)) {
      return Future.value(
        const Left(
          OperationNotAllowedFailure(
              'Bạn không có quyền cập nhật tiến độ sửa chữa.'),
        ),
      );
    }
    return _repository.updateRepairExecution(
      params.id,
      execution: params.execution,
      actor: params.actor,
    );
  }
}

class UpdateRepairExecutionParams extends Equatable {
  final String id;
  final RepairExecutionInfo execution;
  final UserEntity actor;

  const UpdateRepairExecutionParams({
    required this.id,
    required this.execution,
    required this.actor,
  });

  @override
  List<Object?> get props => [id, execution, actor];
}
