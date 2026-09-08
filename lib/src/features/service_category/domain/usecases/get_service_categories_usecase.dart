import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/paginated_result.dart';
import '../entities/service_category_entity.dart';
import '../repositories/service_category_repository.dart';
import '../value_objects/service_category_filter.dart';

class GetServiceCategoriesUseCase extends UseCase<
    PaginatedResult<ServiceCategoryEntity>, GetServiceCategoriesParams> {
  final ServiceCategoryRepository _repository;

  GetServiceCategoriesUseCase(this._repository);

  @override
  Future<Either<Failure, PaginatedResult<ServiceCategoryEntity>>> call(
    GetServiceCategoriesParams params,
  ) {
    return _repository.getServiceCategories(params.filter,
        startAfter: params.startAfter);
  }
}

class GetServiceCategoriesParams extends Equatable {
  final ServiceCategoryFilter filter;
  final DocumentSnapshot? startAfter;

  const GetServiceCategoriesParams({
    required this.filter,
    this.startAfter,
  });

  @override
  List<Object?> get props => [filter, startAfter];
}
