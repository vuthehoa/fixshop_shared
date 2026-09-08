import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/device_entity.dart';
import '../repositories/device_repository.dart';

/// Unpaginated, non-archived lookup used by searchable dropdowns — e.g. the
/// device picker Warranty/Repair Order will need starting Sprint 6.
class GetActiveDevicesUseCase
    extends UseCase<List<DeviceEntity>, GetActiveDevicesParams> {
  final DeviceRepository _repository;

  GetActiveDevicesUseCase(this._repository);

  @override
  Future<Either<Failure, List<DeviceEntity>>> call(
      GetActiveDevicesParams params) {
    return _repository.getActiveDevices(customerId: params.customerId);
  }
}

class GetActiveDevicesParams extends Equatable {
  final String? customerId;

  const GetActiveDevicesParams({this.customerId});

  @override
  List<Object?> get props => [customerId];
}
