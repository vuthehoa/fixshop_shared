import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/permissions/permission.dart';
import '../../../../core/permissions/permission_resolver.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../entities/repair_order_entity.dart';
import '../repositories/repair_order_repository.dart';

/// Same permission tier as completing/delivering an order (Sprint 7) — the
/// testing verdict authorises the order to reach `completed`.
class PassTestingUseCase extends UseCase<RepairOrderEntity, PassTestingParams> {
  final RepairOrderRepository _repository;

  PassTestingUseCase(this._repository);

  @override
  Future<Either<Failure, RepairOrderEntity>> call(PassTestingParams params) {
    if (!PermissionResolver.hasPermission(
        params.actor.role, Permission.completeRepairOrder)) {
      return Future.value(
        const Left(OperationNotAllowedFailure(
            'Bạn không có quyền xác nhận kiểm tra đạt.')),
      );
    }
    return _repository.passTesting(params.id, actor: params.actor);
  }
}

class PassTestingParams extends Equatable {
  final String id;
  final UserEntity actor;

  const PassTestingParams({required this.id, required this.actor});

  @override
  List<Object?> get props => [id, actor];
}
