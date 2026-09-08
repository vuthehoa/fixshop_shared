import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/repair_service_entity.dart';
import '../repositories/repair_service_repository.dart';

/// Unpaginated, active-only lookup used by searchable dropdowns and
/// parent-scoped filter bars.
class GetActiveRepairServicesUseCase
    extends UseCase<List<RepairServiceEntity>, GetActiveRepairServicesParams> {
  final RepairServiceRepository _repository;

  GetActiveRepairServicesUseCase(this._repository);

  @override
  Future<Either<Failure, List<RepairServiceEntity>>> call(
      GetActiveRepairServicesParams params) {
    return _repository.getActiveRepairServices(parentId: params.parentId);
  }
}

class GetActiveRepairServicesParams extends Equatable {
  final String? parentId;

  const GetActiveRepairServicesParams({this.parentId});

  @override
  List<Object?> get props => [parentId];
}
