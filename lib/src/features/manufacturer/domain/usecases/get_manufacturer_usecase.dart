import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/manufacturer_entity.dart';
import '../repositories/manufacturer_repository.dart';

class GetManufacturerUseCase
    extends UseCase<ManufacturerEntity, GetManufacturerParams> {
  final ManufacturerRepository _repository;

  GetManufacturerUseCase(this._repository);

  @override
  Future<Either<Failure, ManufacturerEntity>> call(
      GetManufacturerParams params) {
    return _repository.getManufacturer(params.id);
  }
}

class GetManufacturerParams extends Equatable {
  final String id;

  const GetManufacturerParams(this.id);

  @override
  List<Object> get props => [id];
}
