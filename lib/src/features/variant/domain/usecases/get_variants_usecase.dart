import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/paginated_result.dart';
import '../entities/variant_entity.dart';
import '../repositories/variant_repository.dart';
import '../value_objects/variant_filter.dart';

class GetVariantsUseCase
    extends UseCase<PaginatedResult<VariantEntity>, GetVariantsParams> {
  final VariantRepository _repository;

  GetVariantsUseCase(this._repository);

  @override
  Future<Either<Failure, PaginatedResult<VariantEntity>>> call(
    GetVariantsParams params,
  ) {
    return _repository.getVariants(params.filter,
        startAfter: params.startAfter);
  }
}

class GetVariantsParams extends Equatable {
  final VariantFilter filter;
  final DocumentSnapshot? startAfter;

  const GetVariantsParams({
    required this.filter,
    this.startAfter,
  });

  @override
  List<Object?> get props => [filter, startAfter];
}
