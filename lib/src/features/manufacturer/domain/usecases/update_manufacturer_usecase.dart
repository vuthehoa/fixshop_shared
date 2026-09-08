import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/manufacturer_entity.dart';
import '../repositories/manufacturer_repository.dart';

class UpdateManufacturerUseCase
    extends UseCase<ManufacturerEntity, ManufacturerEntity> {
  final ManufacturerRepository _repository;

  UpdateManufacturerUseCase(this._repository);

  @override
  Future<Either<Failure, ManufacturerEntity>> call(ManufacturerEntity params) {
    return _repository.updateManufacturer(params);
  }
}
