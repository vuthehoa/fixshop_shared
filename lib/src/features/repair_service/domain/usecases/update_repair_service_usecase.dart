import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/repair_service_entity.dart';
import '../repositories/repair_service_repository.dart';
import '../value_objects/repair_service_write_context.dart';

class UpdateRepairServiceUseCase
    extends UseCase<RepairServiceEntity, RepairServiceEntity> {
  final RepairServiceRepository _repository;

  UpdateRepairServiceUseCase(this._repository);

  /// [context] carries the eligibility `source` and the actor used for the
  /// same-transaction price audit log (update only).
  @override
  Future<Either<Failure, RepairServiceEntity>> call(
    RepairServiceEntity params, {
    RepairServiceWriteContext context = const RepairServiceWriteContext(),
  }) {
    return _repository.updateRepairService(params, context: context);
  }
}
