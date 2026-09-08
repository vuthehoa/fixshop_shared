import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/paginated_result.dart';
import '../entities/manufacturer_entity.dart';
import '../value_objects/manufacturer_filter.dart';

abstract class ManufacturerRepository {
  Future<Either<Failure, ManufacturerEntity>> getManufacturer(String id);

  Future<Either<Failure, PaginatedResult<ManufacturerEntity>>> getManufacturers(
    ManufacturerFilter filter, {
    DocumentSnapshot? startAfter,
  });

  /// Unpaginated, active-only list — feeds dropdowns and filter bars.
  Future<Either<Failure, List<ManufacturerEntity>>> getActiveManufacturers();

  Future<Either<Failure, ManufacturerEntity>> createManufacturer(
      ManufacturerEntity entity);

  Future<Either<Failure, ManufacturerEntity>> updateManufacturer(
      ManufacturerEntity entity);

  Future<Either<Failure, void>> archiveManufacturer(String id);

  Future<Either<Failure, void>> restoreManufacturer(String id);
}
