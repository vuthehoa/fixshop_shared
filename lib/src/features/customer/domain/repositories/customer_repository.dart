import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/paginated_result.dart';
import '../entities/customer_entity.dart';
import '../value_objects/customer_filter.dart';

abstract class CustomerRepository {
  Future<Either<Failure, CustomerEntity>> getCustomer(String id);

  Future<Either<Failure, PaginatedResult<CustomerEntity>>> getCustomers(
    CustomerFilter filter, {
    DocumentSnapshot? startAfter,
  });

  /// Unpaginated, active-only list — feeds dropdowns (e.g. the Device
  /// owner picker in Sprint 5).
  Future<Either<Failure, List<CustomerEntity>>> getActiveCustomers();

  Future<Either<Failure, CustomerEntity>> createCustomer(CustomerEntity entity);

  Future<Either<Failure, CustomerEntity>> updateCustomer(CustomerEntity entity);

  Future<Either<Failure, void>> archiveCustomer(String id);

  Future<Either<Failure, void>> restoreCustomer(String id);
}
