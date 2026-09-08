import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/device_entity.dart';
import '../repositories/device_repository.dart';

class GetDeviceUseCase extends UseCase<DeviceEntity, GetDeviceParams> {
  final DeviceRepository _repository;

  GetDeviceUseCase(this._repository);

  @override
  Future<Either<Failure, DeviceEntity>> call(GetDeviceParams params) {
    return _repository.getDevice(params.id);
  }
}

class GetDeviceParams extends Equatable {
  final String id;

  const GetDeviceParams(this.id);

  @override
  List<Object> get props => [id];
}
