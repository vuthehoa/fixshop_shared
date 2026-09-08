import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/paginated_result.dart';
import '../entities/repair_service_entity.dart';
import '../repositories/repair_service_repository.dart';
import '../value_objects/repair_service_filter.dart';

class GetRepairServicesUseCase extends UseCase<
    PaginatedResult<RepairServiceEntity>, GetRepairServicesParams> {
  final RepairServiceRepository _repository;

  GetRepairServicesUseCase(this._repository);

  @override
  Future<Either<Failure, PaginatedResult<RepairServiceEntity>>> call(
    GetRepairServicesParams params,
  ) {
    return _repository.getRepairServices(params.filter,
        startAfter: params.startAfter);
  }
}

class GetRepairServicesParams extends Equatable {
  final RepairServiceFilter filter;
  final DocumentSnapshot? startAfter;

  const GetRepairServicesParams({
    required this.filter,
    this.startAfter,
  });

  @override
  List<Object?> get props => [filter, startAfter];
}
