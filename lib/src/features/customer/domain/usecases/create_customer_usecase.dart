import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/customer_entity.dart';
import '../repositories/customer_repository.dart';

class CreateCustomerUseCase extends UseCase<CustomerEntity, CustomerEntity> {
  final CustomerRepository _repository;

  CreateCustomerUseCase(this._repository);

  @override
  Future<Either<Failure, CustomerEntity>> call(CustomerEntity params) {
    return _repository.createCustomer(params);
  }
}
