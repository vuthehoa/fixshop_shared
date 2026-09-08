import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/permissions/permission.dart';
import '../../../../core/permissions/permission_resolver.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../entities/reception_info.dart';
import '../entities/repair_order_entity.dart';
import '../repositories/repair_order_repository.dart';

class UpdateReceptionInfoUseCase
    extends UseCase<RepairOrderEntity, UpdateReceptionInfoParams> {
  final RepairOrderRepository _repository;

  UpdateReceptionInfoUseCase(this._repository);

  @override
  Future<Either<Failure, RepairOrderEntity>> call(
      UpdateReceptionInfoParams params) {
    if (!PermissionResolver.hasPermission(
        params.actor.role, Permission.updateRepairOrder)) {
      return Future.value(
        const Left(
          OperationNotAllowedFailure(
              'Bạn không có quyền cập nhật thông tin tiếp nhận.'),
        ),
      );
    }
    return _repository.updateReceptionInfo(
      params.id,
      reception: params.reception,
      actor: params.actor,
    );
  }
}

class UpdateReceptionInfoParams extends Equatable {
  final String id;
  final ReceptionInfo reception;
  final UserEntity actor;

  const UpdateReceptionInfoParams({
    required this.id,
    required this.reception,
    required this.actor,
  });

  @override
  List<Object?> get props => [id, reception, actor];
}
