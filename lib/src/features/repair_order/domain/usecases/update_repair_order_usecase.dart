import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/repair_order_entity.dart';
import '../repositories/repair_order_repository.dart';

class UpdateRepairOrderUseCase
    extends UseCase<RepairOrderEntity, RepairOrderEntity> {
  final RepairOrderRepository _repository;

  UpdateRepairOrderUseCase(this._repository);

  @override
  Future<Either<Failure, RepairOrderEntity>> call(RepairOrderEntity params) {
    return _repository.updateRepairOrder(params);
  }
}
