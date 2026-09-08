import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/permissions/permission.dart';
import '../../../../core/permissions/permission_resolver.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../entities/repair_order_entity.dart';
import '../repositories/repair_order_repository.dart';

class UpdateRepairOrderDiagnosisUseCase
    extends UseCase<RepairOrderEntity, UpdateRepairOrderDiagnosisParams> {
  final RepairOrderRepository _repository;

  UpdateRepairOrderDiagnosisUseCase(this._repository);

  @override
  Future<Either<Failure, RepairOrderEntity>> call(
      UpdateRepairOrderDiagnosisParams params) {
    if (!PermissionResolver.hasPermission(
        params.actor.role, Permission.updateRepairOrder)) {
      return Future.value(
        const Left(OperationNotAllowedFailure(
            'Bạn không có quyền cập nhật chẩn đoán.')),
      );
    }
    return _repository.updateDiagnosis(
      params.id,
      diagnosis: params.diagnosis,
      actor: params.actor,
    );
  }
}

class UpdateRepairOrderDiagnosisParams extends Equatable {
  final String id;
  final String diagnosis;
  final UserEntity actor;

  const UpdateRepairOrderDiagnosisParams({
    required this.id,
    required this.diagnosis,
    required this.actor,
  });

  @override
  List<Object?> get props => [id, diagnosis, actor];
}
