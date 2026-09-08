import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product_family_entity.dart';
import '../repositories/product_family_repository.dart';

class GetProductFamilyUseCase
    extends UseCase<ProductFamilyEntity, GetProductFamilyParams> {
  final ProductFamilyRepository _repository;

  GetProductFamilyUseCase(this._repository);

  @override
  Future<Either<Failure, ProductFamilyEntity>> call(
      GetProductFamilyParams params) {
    return _repository.getProductFamily(params.id);
  }
}

class GetProductFamilyParams extends Equatable {
  final String id;

  const GetProductFamilyParams(this.id);

  @override
  List<Object> get props => [id];
}
