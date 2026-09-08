import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product_family_entity.dart';
import '../repositories/product_family_repository.dart';

class CreateProductFamilyUseCase
    extends UseCase<ProductFamilyEntity, ProductFamilyEntity> {
  final ProductFamilyRepository _repository;

  CreateProductFamilyUseCase(this._repository);

  @override
  Future<Either<Failure, ProductFamilyEntity>> call(
      ProductFamilyEntity params) {
    return _repository.createProductFamily(params);
  }
}
