import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/permissions/permission.dart';
import '../../../../core/permissions/permission_resolver.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/model_repository.dart';

class ArchiveModelUseCase extends UseCase<void, ArchiveModelParams> {
  final ModelRepository _repository;

  ArchiveModelUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(ArchiveModelParams params) {
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
    return _repository.archiveModel(params.id);
  }
}

class ArchiveModelParams extends Equatable {
  final String id;
  final UserRole actorRole;

  const ArchiveModelParams({
    required this.id,
    required this.actorRole,
  });

  @override
  List<Object> get props => [id, actorRole];
}
