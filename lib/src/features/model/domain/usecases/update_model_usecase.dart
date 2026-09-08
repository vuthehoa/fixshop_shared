import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/model_entity.dart';
import '../repositories/model_repository.dart';

class UpdateModelUseCase extends UseCase<ModelEntity, ModelEntity> {
  final ModelRepository _repository;

  UpdateModelUseCase(this._repository);

  @override
  Future<Either<Failure, ModelEntity>> call(ModelEntity params) {
    return _repository.updateModel(params);
  }
}
