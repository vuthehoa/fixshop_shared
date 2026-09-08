import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/repair_order_entity.dart';
import '../repositories/repair_order_repository.dart';

class GetRepairOrderUseCase
    extends UseCase<RepairOrderEntity, GetRepairOrderParams> {
  final RepairOrderRepository _repository;

  GetRepairOrderUseCase(this._repository);

  @override
  Future<Either<Failure, RepairOrderEntity>> call(GetRepairOrderParams params) {
    return _repository.getRepairOrder(params.id);
  }
}

class GetRepairOrderParams extends Equatable {
  final String id;

  const GetRepairOrderParams(this.id);

  @override
  List<Object> get props => [id];
}
