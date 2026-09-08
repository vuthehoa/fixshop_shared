import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product_family_entity.dart';
import '../repositories/product_family_repository.dart';

/// Unpaginated, active-only lookup used by searchable dropdowns and
/// parent-scoped filter bars.
class GetActiveProductFamiliesUseCase
    extends UseCase<List<ProductFamilyEntity>, GetActiveProductFamiliesParams> {
  final ProductFamilyRepository _repository;

  GetActiveProductFamiliesUseCase(this._repository);

  @override
  Future<Either<Failure, List<ProductFamilyEntity>>> call(
      GetActiveProductFamiliesParams params) {
    return _repository.getActiveProductFamilies(parentId: params.parentId);
  }
}

class GetActiveProductFamiliesParams extends Equatable {
  final String? parentId;

  const GetActiveProductFamiliesParams({this.parentId});

  @override
  List<Object?> get props => [parentId];
}
