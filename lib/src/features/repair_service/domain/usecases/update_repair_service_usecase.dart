import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/repair_service_entity.dart';
import '../repositories/repair_service_repository.dart';

class UpdateRepairServiceUseCase
    extends UseCase<RepairServiceEntity, RepairServiceEntity> {
  final RepairServiceRepository _repository;

  UpdateRepairServiceUseCase(this._repository);

  @override
  Future<Either<Failure, RepairServiceEntity>> call(
      RepairServiceEntity params) {
    return _repository.updateRepairService(params);
  }
}
