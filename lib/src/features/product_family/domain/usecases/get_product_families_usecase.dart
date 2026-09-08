import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/paginated_result.dart';
import '../entities/product_family_entity.dart';
import '../repositories/product_family_repository.dart';
import '../value_objects/product_family_filter.dart';

class GetProductFamiliesUseCase extends UseCase<
    PaginatedResult<ProductFamilyEntity>, GetProductFamiliesParams> {
  final ProductFamilyRepository _repository;

  GetProductFamiliesUseCase(this._repository);

  @override
  Future<Either<Failure, PaginatedResult<ProductFamilyEntity>>> call(
    GetProductFamiliesParams params,
  ) {
    return _repository.getProductFamilies(params.filter,
        startAfter: params.startAfter);
  }
}

class GetProductFamiliesParams extends Equatable {
  final ProductFamilyFilter filter;
  final DocumentSnapshot? startAfter;

  const GetProductFamiliesParams({
    required this.filter,
    this.startAfter,
  });

  @override
  List<Object?> get props => [filter, startAfter];
}
