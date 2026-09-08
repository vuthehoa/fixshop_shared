import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/permissions/permission.dart';
import '../../../../core/permissions/permission_resolver.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../entities/repair_order_entity.dart';
import '../repositories/repair_order_repository.dart';

class StartDiagnosisUseCase
    extends UseCase<RepairOrderEntity, StartDiagnosisParams> {
  final RepairOrderRepository _repository;

  StartDiagnosisUseCase(this._repository);

  @override
  Future<Either<Failure, RepairOrderEntity>> call(StartDiagnosisParams params) {
    if (!PermissionResolver.hasPermission(
        params.actor.role, Permission.updateRepairOrder)) {
      return Future.value(
        const Left(OperationNotAllowedFailure(
            'Bạn không có quyền bắt đầu chẩn đoán.')),
      );
    }
    return _repository.startDiagnosis(params.id, actor: params.actor);
  }
}

class StartDiagnosisParams extends Equatable {
  final String id;
  final UserEntity actor;

  const StartDiagnosisParams({required this.id, required this.actor});

  @override
  List<Object?> get props => [id, actor];
}
