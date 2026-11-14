import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/paginated_result.dart';
import '../entities/repair_service_entity.dart';
import '../value_objects/repair_service_filter.dart';
import '../value_objects/repair_service_write_context.dart';

abstract class RepairServiceRepository {
  Future<Either<Failure, RepairServiceEntity>> getRepairService(String id);

  Future<Either<Failure, PaginatedResult<RepairServiceEntity>>>
      getRepairServices(
    RepairServiceFilter filter, {
    DocumentSnapshot? startAfter,
  });

  /// Unpaginated, active-only list — feeds dropdowns and filter bars.
  Future<Either<Failure, List<RepairServiceEntity>>> getActiveRepairServices(
      {String? parentId});

  /// Writes also sync `catalog_eligibility/{id}` in the same batch; see
  /// [RepairServiceWriteContext] for the eligibility `source` and the
  /// same-transaction price audit log.
  Future<Either<Failure, RepairServiceEntity>> createRepairService(
    RepairServiceEntity entity, {
    RepairServiceWriteContext context = const RepairServiceWriteContext(),
  });

  Future<Either<Failure, RepairServiceEntity>> updateRepairService(
    RepairServiceEntity entity, {
    RepairServiceWriteContext context = const RepairServiceWriteContext(),
  });

  Future<Either<Failure, void>> archiveRepairService(
    String id, {
    RepairServiceWriteContext context = const RepairServiceWriteContext(),
  });

  Future<Either<Failure, void>> restoreRepairService(
    String id, {
    RepairServiceWriteContext context = const RepairServiceWriteContext(),
  });
}
