import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/permissions/permission.dart';
import '../../../../core/permissions/permission_resolver.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/product_family_repository.dart';

class ArchiveProductFamilyUseCase
    extends UseCase<void, ArchiveProductFamilyParams> {
  final ProductFamilyRepository _repository;

  ArchiveProductFamilyUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(ArchiveProductFamilyParams params) {
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
    return _repository.archiveProductFamily(params.id);
  }
}

class ArchiveProductFamilyParams extends Equatable {
  final String id;
  final UserRole actorRole;

  const ArchiveProductFamilyParams({
    required this.id,
    required this.actorRole,
  });

  @override
  List<Object> get props => [id, actorRole];
}
