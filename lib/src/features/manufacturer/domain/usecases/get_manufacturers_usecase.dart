import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/paginated_result.dart';
import '../entities/manufacturer_entity.dart';
import '../repositories/manufacturer_repository.dart';
import '../value_objects/manufacturer_filter.dart';

class GetManufacturersUseCase extends UseCase<
    PaginatedResult<ManufacturerEntity>, GetManufacturersParams> {
  final ManufacturerRepository _repository;

  GetManufacturersUseCase(this._repository);

  @override
  Future<Either<Failure, PaginatedResult<ManufacturerEntity>>> call(
    GetManufacturersParams params,
  ) {
    return _repository.getManufacturers(params.filter,
        startAfter: params.startAfter);
  }
}

class GetManufacturersParams extends Equatable {
  final ManufacturerFilter filter;
  final DocumentSnapshot? startAfter;

  const GetManufacturersParams({
    required this.filter,
    this.startAfter,
  });

  @override
  List<Object?> get props => [filter, startAfter];
}
