import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/paginated_result.dart';
import '../entities/repair_service_entity.dart';
import '../value_objects/repair_service_filter.dart';

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

  Future<Either<Failure, RepairServiceEntity>> createRepairService(
      RepairServiceEntity entity);

  Future<Either<Failure, RepairServiceEntity>> updateRepairService(
      RepairServiceEntity entity);

  Future<Either<Failure, void>> archiveRepairService(String id);

  Future<Either<Failure, void>> restoreRepairService(String id);
}
