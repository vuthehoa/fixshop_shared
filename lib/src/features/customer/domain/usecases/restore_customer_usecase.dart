import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/permissions/permission.dart';
import '../../../../core/permissions/permission_resolver.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/customer_repository.dart';

class RestoreCustomerUseCase extends UseCase<void, RestoreCustomerParams> {
  final CustomerRepository _repository;

  RestoreCustomerUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(RestoreCustomerParams params) {
    if (!PermissionResolver.hasPermission(
      params.actorRole,
      Permission.manageCustomer,
    )) {
      return Future.value(
        const Left(
          OperationNotAllowedFailure(
            'Bạn không có quyền khôi phục khách hàng.',
          ),
        ),
      );
    }
    return _repository.restoreCustomer(params.id);
  }
}

class RestoreCustomerParams extends Equatable {
  final String id;
  final UserRole actorRole;

  const RestoreCustomerParams({
    required this.id,
    required this.actorRole,
  });

  @override
  List<Object> get props => [id, actorRole];
}
