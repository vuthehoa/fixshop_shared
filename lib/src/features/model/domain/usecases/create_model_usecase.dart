import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/model_entity.dart';
import '../repositories/model_repository.dart';

class CreateModelUseCase extends UseCase<ModelEntity, ModelEntity> {
  final ModelRepository _repository;

  CreateModelUseCase(this._repository);

  @override
  Future<Either<Failure, ModelEntity>> call(ModelEntity params) {
    return _repository.createModel(params);
  }
}
