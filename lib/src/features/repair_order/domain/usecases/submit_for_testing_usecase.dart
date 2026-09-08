import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/permissions/permission.dart';
import '../../../../core/permissions/permission_resolver.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../entities/repair_order_entity.dart';
import '../repositories/repair_order_repository.dart';

class SubmitForTestingUseCase
    extends UseCase<RepairOrderEntity, SubmitForTestingParams> {
  final RepairOrderRepository _repository;

  SubmitForTestingUseCase(this._repository);

  @override
  Future<Either<Failure, RepairOrderEntity>> call(
      SubmitForTestingParams params) {
    if (!PermissionResolver.hasPermission(
        params.actor.role, Permission.updateRepairOrder)) {
      return Future.value(
        const Left(OperationNotAllowedFailure(
            'Bạn không có quyền gửi thiết bị đi kiểm tra.')),
      );
    }
    return _repository.submitForTesting(params.id, actor: params.actor);
  }
}

class SubmitForTestingParams extends Equatable {
  final String id;
  final UserEntity actor;

  const SubmitForTestingParams({required this.id, required this.actor});

  @override
  List<Object?> get props => [id, actor];
}
