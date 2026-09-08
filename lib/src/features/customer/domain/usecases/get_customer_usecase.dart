import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/customer_entity.dart';
import '../repositories/customer_repository.dart';

class GetCustomerUseCase extends UseCase<CustomerEntity, GetCustomerParams> {
  final CustomerRepository _repository;

  GetCustomerUseCase(this._repository);

  @override
  Future<Either<Failure, CustomerEntity>> call(GetCustomerParams params) {
    return _repository.getCustomer(params.id);
  }
}

class GetCustomerParams extends Equatable {
  final String id;

  const GetCustomerParams(this.id);

  @override
  List<Object> get props => [id];
}
