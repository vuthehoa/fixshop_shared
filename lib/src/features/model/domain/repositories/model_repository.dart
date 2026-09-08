import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/paginated_result.dart';
import '../entities/model_entity.dart';
import '../value_objects/model_filter.dart';

abstract class ModelRepository {
  Future<Either<Failure, ModelEntity>> getModel(String id);

  Future<Either<Failure, PaginatedResult<ModelEntity>>> getModels(
    ModelFilter filter, {
    DocumentSnapshot? startAfter,
  });

  /// Unpaginated, active-only list — feeds dropdowns and filter bars.
  Future<Either<Failure, List<ModelEntity>>> getActiveModels(
      {String? parentId});

  Future<Either<Failure, ModelEntity>> createModel(ModelEntity entity);

  Future<Either<Failure, ModelEntity>> updateModel(ModelEntity entity);

  Future<Either<Failure, void>> archiveModel(String id);

  Future<Either<Failure, void>> restoreModel(String id);
}
