import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/permissions/permission.dart';
import '../../../../core/permissions/permission_resolver.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../entities/device_entity.dart';
import '../repositories/device_repository.dart';

class VoidDeviceWarrantyUseCase
    extends UseCase<DeviceEntity, VoidDeviceWarrantyParams> {
  final DeviceRepository _repository;

  VoidDeviceWarrantyUseCase(this._repository);

  @override
  Future<Either<Failure, DeviceEntity>> call(VoidDeviceWarrantyParams params) {
    if (!PermissionResolver.hasPermission(
        params.actorRole, Permission.manageWarranty)) {
      return Future.value(
        const Left(
          OperationNotAllowedFailure('Bạn không có quyền huỷ bảo hành.'),
        ),
      );
    }
    return _repository.voidWarranty(params.deviceId);
  }
}

class VoidDeviceWarrantyParams extends Equatable {
  final String deviceId;
  final UserRole actorRole;

  const VoidDeviceWarrantyParams({
    required this.deviceId,
    required this.actorRole,
  });

  @override
  List<Object> get props => [deviceId, actorRole];
}
