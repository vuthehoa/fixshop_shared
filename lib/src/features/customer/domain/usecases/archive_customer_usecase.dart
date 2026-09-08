import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/permissions/permission.dart';
import '../../../../core/permissions/permission_resolver.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/customer_repository.dart';

class ArchiveCustomerUseCase extends UseCase<void, ArchiveCustomerParams> {
  final CustomerRepository _repository;

  ArchiveCustomerUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(ArchiveCustomerParams params) {
    if (!PermissionResolver.hasPermission(
      params.actorRole,
      Permission.manageCustomer,
    )) {
      return Future.value(
        const Left(
          OperationNotAllowedFailure(
            'Bạn không có quyền lưu trữ khách hàng.',
          ),
        ),
      );
    }
    return _repository.archiveCustomer(params.id);
  }
}

class ArchiveCustomerParams extends Equatable {
  final String id;
  final UserRole actorRole;

  const ArchiveCustomerParams({
    required this.id,
    required this.actorRole,
  });

  @override
  List<Object> get props => [id, actorRole];
}
