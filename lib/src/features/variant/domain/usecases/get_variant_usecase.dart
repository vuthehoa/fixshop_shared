import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/variant_entity.dart';
import '../repositories/variant_repository.dart';

class GetVariantUseCase extends UseCase<VariantEntity, GetVariantParams> {
  final VariantRepository _repository;

  GetVariantUseCase(this._repository);

  @override
  Future<Either<Failure, VariantEntity>> call(GetVariantParams params) {
    return _repository.getVariant(params.id);
  }
}

class GetVariantParams extends Equatable {
  final String id;

  const GetVariantParams(this.id);

  @override
  List<Object> get props => [id];
}
