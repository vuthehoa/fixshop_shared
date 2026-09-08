import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/service_category_entity.dart';
import '../repositories/service_category_repository.dart';

class CreateServiceCategoryUseCase
    extends UseCase<ServiceCategoryEntity, ServiceCategoryEntity> {
  final ServiceCategoryRepository _repository;

  CreateServiceCategoryUseCase(this._repository);

  @override
  Future<Either<Failure, ServiceCategoryEntity>> call(
      ServiceCategoryEntity params) {
    return _repository.createServiceCategory(params);
  }
}
