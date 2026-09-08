import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/permissions/permission.dart';
import '../../../../core/permissions/permission_resolver.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/service_category_repository.dart';

class RestoreServiceCategoryUseCase
    extends UseCase<void, RestoreServiceCategoryParams> {
  final ServiceCategoryRepository _repository;

  RestoreServiceCategoryUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(RestoreServiceCategoryParams params) {
    if (!PermissionResolver.hasPermission(
      params.actorRole,
      Permission.manageCatalog,
    )) {
      return Future.value(
        const Left(
          OperationNotAllowedFailure(
            'Bạn không có quyền khôi phục dữ liệu danh mục.',
          ),
        ),
      );
    }
    return _repository.restoreServiceCategory(params.id);
  }
}

class RestoreServiceCategoryParams extends Equatable {
  final String id;
  final UserRole actorRole;

  const RestoreServiceCategoryParams({
    required this.id,
    required this.actorRole,
  });

  @override
  List<Object> get props => [id, actorRole];
}
