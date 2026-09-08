import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/repair_service_entity.dart';
import '../repositories/repair_service_repository.dart';

class GetRepairServiceUseCase
    extends UseCase<RepairServiceEntity, GetRepairServiceParams> {
  final RepairServiceRepository _repository;

  GetRepairServiceUseCase(this._repository);

  @override
  Future<Either<Failure, RepairServiceEntity>> call(
      GetRepairServiceParams params) {
    return _repository.getRepairService(params.id);
  }
}

class GetRepairServiceParams extends Equatable {
  final String id;

  const GetRepairServiceParams(this.id);

  @override
  List<Object> get props => [id];
}
