import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/manufacturer_entity.dart';
import '../repositories/manufacturer_repository.dart';

/// Unpaginated, active-only lookup used by searchable dropdowns and
/// parent-scoped filter bars.
class GetActiveManufacturersUseCase
    extends UseCase<List<ManufacturerEntity>, GetActiveManufacturersParams> {
  final ManufacturerRepository _repository;

  GetActiveManufacturersUseCase(this._repository);

  @override
  Future<Either<Failure, List<ManufacturerEntity>>> call(
      GetActiveManufacturersParams params) {
    return _repository.getActiveManufacturers();
  }
}

class GetActiveManufacturersParams extends Equatable {
  const GetActiveManufacturersParams();

  @override
  List<Object?> get props => [];
}
