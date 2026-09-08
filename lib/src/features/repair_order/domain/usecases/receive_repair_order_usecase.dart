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

class ReceiveRepairOrderUseCase
    extends UseCase<RepairOrderEntity, ReceiveRepairOrderParams> {
  final RepairOrderRepository _repository;

  ReceiveRepairOrderUseCase(this._repository);

  @override
  Future<Either<Failure, RepairOrderEntity>> call(
      ReceiveRepairOrderParams params) {
    if (!PermissionResolver.hasPermission(
        params.actor.role, Permission.updateRepairOrder)) {
      return Future.value(
        const Left(OperationNotAllowedFailure(
            'Bạn không có quyền tiếp nhận thiết bị.')),
      );
    }
    return _repository.receiveDevice(
      params.id,
      reception: params.reception,
      actor: params.actor,
    );
  }
}

class ReceiveRepairOrderParams extends Equatable {
  final String id;
  final ReceptionInfo reception;
  final UserEntity actor;

  const ReceiveRepairOrderParams({
    required this.id,
    required this.reception,
    required this.actor,
  });

  @override
  List<Object?> get props => [id, reception, actor];
}
