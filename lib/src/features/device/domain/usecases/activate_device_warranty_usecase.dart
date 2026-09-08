import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/permissions/permission.dart';
import '../../../../core/permissions/permission_resolver.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../entities/device_entity.dart';
import '../repositories/device_repository.dart';

class ActivateDeviceWarrantyUseCase
    extends UseCase<DeviceEntity, ActivateDeviceWarrantyParams> {
  final DeviceRepository _repository;

  ActivateDeviceWarrantyUseCase(this._repository);

  @override
  Future<Either<Failure, DeviceEntity>> call(
      ActivateDeviceWarrantyParams params) {
    if (!PermissionResolver.hasPermission(
        params.actorRole, Permission.manageWarranty)) {
      return Future.value(
        const Left(
          OperationNotAllowedFailure('Bạn không có quyền kích hoạt bảo hành.'),
        ),
      );
    }
    return _repository.activateWarranty(
      params.deviceId,
      warrantyPeriodMonths: params.warrantyPeriodMonths,
    );
  }
}

class ActivateDeviceWarrantyParams extends Equatable {
  final String deviceId;
  final int warrantyPeriodMonths;
  final UserRole actorRole;

  const ActivateDeviceWarrantyParams({
    required this.deviceId,
    required this.warrantyPeriodMonths,
    required this.actorRole,
  });

  @override
  List<Object> get props => [deviceId, warrantyPeriodMonths, actorRole];
}
