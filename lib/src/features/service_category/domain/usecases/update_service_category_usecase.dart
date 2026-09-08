import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/service_category_entity.dart';
import '../repositories/service_category_repository.dart';

class UpdateServiceCategoryUseCase
    extends UseCase<ServiceCategoryEntity, ServiceCategoryEntity> {
  final ServiceCategoryRepository _repository;

  UpdateServiceCategoryUseCase(this._repository);

  @override
  Future<Either<Failure, ServiceCategoryEntity>> call(
      ServiceCategoryEntity params) {
    return _repository.updateServiceCategory(params);
  }
}
