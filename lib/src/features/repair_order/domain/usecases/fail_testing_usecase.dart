import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/permissions/permission.dart';
import '../../../../core/permissions/permission_resolver.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../entities/repair_order_entity.dart';
import '../repositories/repair_order_repository.dart';

/// Same permission tier as [PassTestingUseCase] — failing is also a testing
/// verdict, not a routine progress update.
class FailTestingUseCase extends UseCase<RepairOrderEntity, FailTestingParams> {
  final RepairOrderRepository _repository;

  FailTestingUseCase(this._repository);

  @override
  Future<Either<Failure, RepairOrderEntity>> call(FailTestingParams params) {
    if (!PermissionResolver.hasPermission(
        params.actor.role, Permission.completeRepairOrder)) {
      return Future.value(
        const Left(OperationNotAllowedFailure(
            'Bạn không có quyền xác nhận kiểm tra không đạt.')),
      );
    }
    return _repository.failTesting(params.id,
        actor: params.actor, notes: params.notes);
  }
}

class FailTestingParams extends Equatable {
  final String id;
  final UserEntity actor;
  final String? notes;

  const FailTestingParams({required this.id, required this.actor, this.notes});

  @override
  List<Object?> get props => [id, actor, notes];
}
