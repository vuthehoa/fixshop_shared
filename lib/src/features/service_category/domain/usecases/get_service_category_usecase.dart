import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/service_category_entity.dart';
import '../repositories/service_category_repository.dart';

class GetServiceCategoryUseCase
    extends UseCase<ServiceCategoryEntity, GetServiceCategoryParams> {
  final ServiceCategoryRepository _repository;

  GetServiceCategoryUseCase(this._repository);

  @override
  Future<Either<Failure, ServiceCategoryEntity>> call(
      GetServiceCategoryParams params) {
    return _repository.getServiceCategory(params.id);
  }
}

class GetServiceCategoryParams extends Equatable {
  final String id;

  const GetServiceCategoryParams(this.id);

  @override
  List<Object> get props => [id];
}
