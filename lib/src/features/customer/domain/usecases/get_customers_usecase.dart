import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/paginated_result.dart';
import '../entities/customer_entity.dart';
import '../repositories/customer_repository.dart';
import '../value_objects/customer_filter.dart';

class GetCustomersUseCase
    extends UseCase<PaginatedResult<CustomerEntity>, GetCustomersParams> {
  final CustomerRepository _repository;

  GetCustomersUseCase(this._repository);

  @override
  Future<Either<Failure, PaginatedResult<CustomerEntity>>> call(
    GetCustomersParams params,
  ) {
    return _repository.getCustomers(params.filter,
        startAfter: params.startAfter);
  }
}

class GetCustomersParams extends Equatable {
  final CustomerFilter filter;
  final DocumentSnapshot? startAfter;

  const GetCustomersParams({
    required this.filter,
    this.startAfter,
  });

  @override
  List<Object?> get props => [filter, startAfter];
}
