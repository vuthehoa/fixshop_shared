import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/paginated_result.dart';
import '../entities/device_entity.dart';
import '../repositories/device_repository.dart';
import '../value_objects/device_filter.dart';

class GetDevicesUseCase
    extends UseCase<PaginatedResult<DeviceEntity>, GetDevicesParams> {
  final DeviceRepository _repository;

  GetDevicesUseCase(this._repository);

  @override
  Future<Either<Failure, PaginatedResult<DeviceEntity>>> call(
    GetDevicesParams params,
  ) {
    return _repository.getDevices(params.filter, startAfter: params.startAfter);
  }
}

class GetDevicesParams extends Equatable {
  final DeviceFilter filter;
  final DocumentSnapshot? startAfter;

  const GetDevicesParams({
    required this.filter,
    this.startAfter,
  });

  @override
  List<Object?> get props => [filter, startAfter];
}
