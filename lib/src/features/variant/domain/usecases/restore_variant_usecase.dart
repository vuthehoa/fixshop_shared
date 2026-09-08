import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/permissions/permission.dart';
import '../../../../core/permissions/permission_resolver.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/variant_repository.dart';

class RestoreVariantUseCase extends UseCase<void, RestoreVariantParams> {
  final VariantRepository _repository;

  RestoreVariantUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(RestoreVariantParams params) {
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
    return _repository.restoreVariant(params.id);
  }
}

class RestoreVariantParams extends Equatable {
  final String id;
  final UserRole actorRole;

  const RestoreVariantParams({
    required this.id,
    required this.actorRole,
  });

  @override
  List<Object> get props => [id, actorRole];
}
