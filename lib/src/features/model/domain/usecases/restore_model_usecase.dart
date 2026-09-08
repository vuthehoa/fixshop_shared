import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/permissions/permission.dart';
import '../../../../core/permissions/permission_resolver.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/model_repository.dart';

class RestoreModelUseCase extends UseCase<void, RestoreModelParams> {
  final ModelRepository _repository;

  RestoreModelUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(RestoreModelParams params) {
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
    return _repository.restoreModel(params.id);
  }
}

class RestoreModelParams extends Equatable {
  final String id;
  final UserRole actorRole;

  const RestoreModelParams({
    required this.id,
    required this.actorRole,
  });

  @override
  List<Object> get props => [id, actorRole];
}
