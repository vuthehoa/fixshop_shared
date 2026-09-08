import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/permissions/permission.dart';
import '../../../../core/permissions/permission_resolver.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/service_category_repository.dart';

class ArchiveServiceCategoryUseCase
    extends UseCase<void, ArchiveServiceCategoryParams> {
  final ServiceCategoryRepository _repository;

  ArchiveServiceCategoryUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(ArchiveServiceCategoryParams params) {
    if (!PermissionResolver.hasPermission(
      params.actorRole,
      Permission.manageCatalog,
    )) {
      return Future.value(
        const Left(
          OperationNotAllowedFailure(
            'Bạn không có quyền lưu trữ dữ liệu danh mục.',
          ),
        ),
      );
    }
    return _repository.archiveServiceCategory(params.id);
  }
}

class ArchiveServiceCategoryParams extends Equatable {
  final String id;
  final UserRole actorRole;

  const ArchiveServiceCategoryParams({
    required this.id,
    required this.actorRole,
  });

  @override
  List<Object> get props => [id, actorRole];
}
