import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/customer_entity.dart';
import '../value_objects/customer_filter.dart';

/// Extension point for exporting the customer list to an external file
/// (e.g. Excel/CSV), respecting the same filter currently applied on screen.
/// Not implemented in Sprint 4 — this interface only reserves the
/// architecture for a future sprint.
abstract class CustomerExportService {
  Future<Either<Failure, List<int>>> exportToFile(
    CustomerFilter filter,
    List<CustomerEntity> items,
  );
}
