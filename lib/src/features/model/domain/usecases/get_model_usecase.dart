import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/model_entity.dart';
import '../repositories/model_repository.dart';

class GetModelUseCase extends UseCase<ModelEntity, GetModelParams> {
  final ModelRepository _repository;

  GetModelUseCase(this._repository);

  @override
  Future<Either<Failure, ModelEntity>> call(GetModelParams params) {
    return _repository.getModel(params.id);
  }
}

class GetModelParams extends Equatable {
  final String id;

  const GetModelParams(this.id);

  @override
  List<Object> get props => [id];
}
