import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/paginated_result.dart';
import '../entities/repair_order_entity.dart';
import '../repositories/repair_order_repository.dart';
import '../value_objects/repair_order_filter.dart';

class GetRepairOrdersUseCase
    extends UseCase<PaginatedResult<RepairOrderEntity>, GetRepairOrdersParams> {
  final RepairOrderRepository _repository;

  GetRepairOrdersUseCase(this._repository);

  @override
  Future<Either<Failure, PaginatedResult<RepairOrderEntity>>> call(
    GetRepairOrdersParams params,
  ) {
    return _repository.getRepairOrders(params.filter,
        startAfter: params.startAfter);
  }
}

class GetRepairOrdersParams extends Equatable {
  final RepairOrderFilter filter;
  final DocumentSnapshot? startAfter;

  const GetRepairOrdersParams({
    required this.filter,
    this.startAfter,
  });

  @override
  List<Object?> get props => [filter, startAfter];
}
