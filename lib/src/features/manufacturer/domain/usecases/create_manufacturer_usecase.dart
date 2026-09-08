import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/manufacturer_entity.dart';
import '../repositories/manufacturer_repository.dart';

class CreateManufacturerUseCase
    extends UseCase<ManufacturerEntity, ManufacturerEntity> {
  final ManufacturerRepository _repository;

  CreateManufacturerUseCase(this._repository);

  @override
  Future<Either<Failure, ManufacturerEntity>> call(ManufacturerEntity params) {
    return _repository.createManufacturer(params);
  }
}
