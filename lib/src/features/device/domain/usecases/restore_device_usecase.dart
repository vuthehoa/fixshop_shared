import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/permissions/permission.dart';
import '../../../../core/permissions/permission_resolver.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/device_repository.dart';

class RestoreDeviceUseCase extends UseCase<void, RestoreDeviceParams> {
  final DeviceRepository _repository;

  RestoreDeviceUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(RestoreDeviceParams params) {
    if (!PermissionResolver.hasPermission(
      params.actorRole,
      Permission.manageDevice,
    )) {
      return Future.value(
        const Left(
          OperationNotAllowedFailure('Bạn không có quyền khôi phục thiết bị.'),
        ),
      );
    }
    return _repository.restoreDevice(params.id);
  }
}

class RestoreDeviceParams extends Equatable {
  final String id;
  final UserRole actorRole;

  const RestoreDeviceParams({
    required this.id,
    required this.actorRole,
  });

  @override
  List<Object> get props => [id, actorRole];
}
