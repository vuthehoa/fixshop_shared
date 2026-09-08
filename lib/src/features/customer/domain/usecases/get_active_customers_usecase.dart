import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/customer_entity.dart';
import '../repositories/customer_repository.dart';

/// Unpaginated, active-only lookup used by searchable dropdowns — e.g. the
/// Device owner picker in Sprint 5.
class GetActiveCustomersUseCase
    extends UseCase<List<CustomerEntity>, GetActiveCustomersParams> {
  final CustomerRepository _repository;

  GetActiveCustomersUseCase(this._repository);

  @override
  Future<Either<Failure, List<CustomerEntity>>> call(
      GetActiveCustomersParams params) {
    return _repository.getActiveCustomers();
  }
}

class GetActiveCustomersParams extends Equatable {
  const GetActiveCustomersParams();

  @override
  List<Object?> get props => [];
}
