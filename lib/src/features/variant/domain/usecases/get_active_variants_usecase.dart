import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/variant_entity.dart';
import '../repositories/variant_repository.dart';

/// Unpaginated, active-only lookup used by searchable dropdowns and
/// parent-scoped filter bars.
class GetActiveVariantsUseCase
    extends UseCase<List<VariantEntity>, GetActiveVariantsParams> {
  final VariantRepository _repository;

  GetActiveVariantsUseCase(this._repository);

  @override
  Future<Either<Failure, List<VariantEntity>>> call(
      GetActiveVariantsParams params) {
    return _repository.getActiveVariants(parentId: params.parentId);
  }
}

class GetActiveVariantsParams extends Equatable {
  final String? parentId;

  const GetActiveVariantsParams({this.parentId});

  @override
  List<Object?> get props => [parentId];
}
