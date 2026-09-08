import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/service_category_entity.dart';
import '../repositories/service_category_repository.dart';

/// Unpaginated, active-only lookup used by searchable dropdowns and
/// parent-scoped filter bars.
class GetActiveServiceCategoriesUseCase extends UseCase<
    List<ServiceCategoryEntity>, GetActiveServiceCategoriesParams> {
  final ServiceCategoryRepository _repository;

  GetActiveServiceCategoriesUseCase(this._repository);

  @override
  Future<Either<Failure, List<ServiceCategoryEntity>>> call(
    GetActiveServiceCategoriesParams params,
  ) {
    return _repository.getActiveServiceCategories();
  }
}

class GetActiveServiceCategoriesParams extends Equatable {
  const GetActiveServiceCategoriesParams();

  @override
  List<Object?> get props => [];
}
