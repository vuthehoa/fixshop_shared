import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/paginated_result.dart';
import '../entities/model_entity.dart';
import '../repositories/model_repository.dart';
import '../value_objects/model_filter.dart';

class GetModelsUseCase
    extends UseCase<PaginatedResult<ModelEntity>, GetModelsParams> {
  final ModelRepository _repository;

  GetModelsUseCase(this._repository);

  @override
  Future<Either<Failure, PaginatedResult<ModelEntity>>> call(
    GetModelsParams params,
  ) {
    return _repository.getModels(params.filter, startAfter: params.startAfter);
  }
}

class GetModelsParams extends Equatable {
  final ModelFilter filter;
  final DocumentSnapshot? startAfter;

  const GetModelsParams({
    required this.filter,
    this.startAfter,
  });

  @override
  List<Object?> get props => [filter, startAfter];
}
