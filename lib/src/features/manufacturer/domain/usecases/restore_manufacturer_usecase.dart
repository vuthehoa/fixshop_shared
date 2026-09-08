import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/permissions/permission.dart';
import '../../../../core/permissions/permission_resolver.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/manufacturer_repository.dart';

class RestoreManufacturerUseCase
    extends UseCase<void, RestoreManufacturerParams> {
  final ManufacturerRepository _repository;

  RestoreManufacturerUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(RestoreManufacturerParams params) {
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
    return _repository.restoreManufacturer(params.id);
  }
}

class RestoreManufacturerParams extends Equatable {
  final String id;
  final UserRole actorRole;

  const RestoreManufacturerParams({
    required this.id,
    required this.actorRole,
  });

  @override
  List<Object> get props => [id, actorRole];
}
