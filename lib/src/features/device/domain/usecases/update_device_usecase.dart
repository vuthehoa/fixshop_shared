import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/device_entity.dart';
import '../repositories/device_repository.dart';

class UpdateDeviceUseCase extends UseCase<DeviceEntity, DeviceEntity> {
  final DeviceRepository _repository;

  UpdateDeviceUseCase(this._repository);

  @override
  Future<Either<Failure, DeviceEntity>> call(DeviceEntity params) {
    return _repository.updateDevice(params);
  }
}
