import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/permissions/permission.dart';
import '../../../../core/permissions/permission_resolver.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/device_repository.dart';

class ArchiveDeviceUseCase extends UseCase<void, ArchiveDeviceParams> {
  final DeviceRepository _repository;

  ArchiveDeviceUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(ArchiveDeviceParams params) {
    if (!PermissionResolver.hasPermission(
      params.actorRole,
      Permission.manageDevice,
    )) {
      return Future.value(
        const Left(
          OperationNotAllowedFailure('Bạn không có quyền lưu trữ thiết bị.'),
        ),
      );
    }
    return _repository.archiveDevice(params.id);
  }
}

class ArchiveDeviceParams extends Equatable {
  final String id;
  final UserRole actorRole;

  const ArchiveDeviceParams({
    required this.id,
    required this.actorRole,
  });

  @override
  List<Object> get props => [id, actorRole];
}
