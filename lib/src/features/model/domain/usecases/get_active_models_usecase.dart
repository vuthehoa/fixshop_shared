import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/model_entity.dart';
import '../repositories/model_repository.dart';

/// Unpaginated, active-only lookup used by searchable dropdowns and
/// parent-scoped filter bars.
class GetActiveModelsUseCase
    extends UseCase<List<ModelEntity>, GetActiveModelsParams> {
  final ModelRepository _repository;

  GetActiveModelsUseCase(this._repository);

  @override
  Future<Either<Failure, List<ModelEntity>>> call(
      GetActiveModelsParams params) {
    return _repository.getActiveModels(parentId: params.parentId);
  }
}

class GetActiveModelsParams extends Equatable {
  final String? parentId;

  const GetActiveModelsParams({this.parentId});

  @override
  List<Object?> get props => [parentId];
}
