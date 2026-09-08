import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/permissions/permission.dart';
import '../../../../core/permissions/permission_resolver.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../entities/repair_order_entity.dart';
import '../repositories/repair_order_repository.dart';

class AssignRepairOrderTechnicianUseCase
    extends UseCase<RepairOrderEntity, AssignRepairOrderTechnicianParams> {
  final RepairOrderRepository _repository;

  AssignRepairOrderTechnicianUseCase(this._repository);

  @override
  Future<Either<Failure, RepairOrderEntity>> call(
    AssignRepairOrderTechnicianParams params,
  ) {
    if (!PermissionResolver.hasPermission(
        params.actor.role, Permission.assignRepairOrder)) {
      return Future.value(
        const Left(OperationNotAllowedFailure(
            'Bạn không có quyền phân công kỹ thuật viên.')),
      );
    }
    return _repository.assignTechnician(
      params.id,
      technicianId: params.technicianId,
      technicianName: params.technicianName,
      actor: params.actor,
    );
  }
}

class AssignRepairOrderTechnicianParams extends Equatable {
  final String id;
  final String technicianId;
  final String technicianName;
  final UserEntity actor;

  const AssignRepairOrderTechnicianParams({
    required this.id,
    required this.technicianId,
    required this.technicianName,
    required this.actor,
  });

  @override
  List<Object?> get props => [id, technicianId, technicianName, actor];
}
