import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/variant_entity.dart';
import '../repositories/variant_repository.dart';

class UpdateVariantUseCase extends UseCase<VariantEntity, VariantEntity> {
  final VariantRepository _repository;

  UpdateVariantUseCase(this._repository);

  @override
  Future<Either<Failure, VariantEntity>> call(VariantEntity params) {
    return _repository.updateVariant(params);
  }
}
